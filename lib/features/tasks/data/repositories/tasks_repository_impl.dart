import 'package:http/http.dart' as http;
import 'package:inspector_app/core/config/api_config.dart';
import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/api_mappers.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_details_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_entity.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_step_entity.dart';
import 'package:inspector_app/features/tasks/domain/repositories/tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<TaskEntity>> getTasks({
    String? date,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
      if (date != null && date.isNotEmpty) 'date': date,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final json = JsonMap.map(await _api.get('/api/Tasks', query: query));
    return JsonMap.mapList(json['items']).map(ApiMappers.task).toList();
  }

  @override
  Future<TaskDetailsEntity> getTaskDetails(String id) async {
    final json = JsonMap.map(await _api.get('/api/Tasks/$id'));
    final task = ApiMappers.task(json);
    final status = task.status;
    final started = json['startedAt'] != null;
    final completed = status == TaskStatus.completed;
    final lat = JsonMap.asDouble(json['latitude']) ?? task.latitude;
    final lng = JsonMap.asDouble(json['longitude']) ?? task.longitude;
    final generalCondition = JsonMap.str(json['generalCondition']);
    final hasReportData = generalCondition.isNotEmpty || json['qualityScore'] != null;

    List<TaskPhotoEntity> photos = JsonMap.mapList(json['photos']).map((p) {
      final rawUrl = JsonMap.str(p['url']);
      final absolute = rawUrl.startsWith('http')
          ? rawUrl
          : '${ApiConfig.baseUrl}${rawUrl.startsWith('/') ? rawUrl : '/$rawUrl'}';
      final fileName = JsonMap.str(p['fileName']);
      return TaskPhotoEntity(
        id: JsonMap.str(p['id']),
        url: absolute,
        description: JsonMap.str(p['description']).isEmpty ? null : JsonMap.str(p['description']),
        fileName: fileName.isEmpty ? null : fileName,
      );
    }).toList();

    if (photos.isEmpty && ((json['photosCount'] as num?)?.toInt() ?? 0) > 0) {
      try {
        final media = await _api.get('/api/Tasks/$id/media');
        photos = JsonMap.mapList(media).map((p) {
          final rawUrl = JsonMap.str(p['url']);
          final absolute = rawUrl.startsWith('http')
              ? rawUrl
              : '${ApiConfig.baseUrl}${rawUrl.startsWith('/') ? rawUrl : '/$rawUrl'}';
          final fileName = JsonMap.str(p['fileName']);
          return TaskPhotoEntity(
            id: JsonMap.str(p['id']),
            url: absolute,
            description: JsonMap.str(p['description']).isEmpty ? null : JsonMap.str(p['description']),
            fileName: fileName.isEmpty ? null : fileName,
          );
        }).toList();
      } catch (_) {}
    }

    return TaskDetailsEntity(
      task: task,
      code: JsonMap.str(json['id']).replaceAll('-', '').toUpperCase().substring(
            0,
            JsonMap.str(json['id']).replaceAll('-', '').length.clamp(0, 8),
          ),
      plannedDate: ApiMappers.dateLabel(json['dueDate']),
      stageLabel: _stageLabel(status),
      description: JsonMap.str(json['description']).isEmpty ? null : JsonMap.str(json['description']),
      latitude: lat,
      longitude: lng,
      steps: <TaskStepEntity>[
        TaskStepEntity(
          title: 'بيانات الموقع',
          status: JsonMap.str(json['locationName']).isNotEmpty || lat != null
              ? TaskStepStatus.done
              : TaskStepStatus.pending,
          timeLabel: JsonMap.str(json['locationName']).isNotEmpty ? 'تم إدخالها' : 'معلقة',
        ),
        TaskStepEntity(
          title: 'تفقد الموقع',
          status: completed
              ? TaskStepStatus.done
              : (started || status == TaskStatus.inProgress ? TaskStepStatus.inProgress : TaskStepStatus.pending),
          timeLabel: completed ? 'مكتمل' : (started || status == TaskStatus.inProgress ? 'جارية' : 'معلقة'),
        ),
        TaskStepEntity(
          title: 'رفع التقرير',
          status: hasReportData || completed ? TaskStepStatus.done : TaskStepStatus.pending,
          timeLabel: hasReportData || completed ? 'تم الرفع' : 'معلقة',
        ),
      ],
      mapHint: lat != null && lng != null ? 'اضغط لفتح الخريطة' : 'لا توجد إحداثيات لهذه المهمة',
      inspectorNote: JsonMap.str(json['reportNotes']).isEmpty
          ? (JsonMap.str(json['rejectionReason']).isEmpty ? null : JsonMap.str(json['rejectionReason']))
          : JsonMap.str(json['reportNotes']),
      report: hasReportData
          ? TaskReportEntity(
              generalCondition: generalCondition.isEmpty ? '—' : generalCondition,
              qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 0,
              hasViolations: json['hasViolations'] == true,
              reportNotes: JsonMap.str(json['reportNotes']).isEmpty ? null : JsonMap.str(json['reportNotes']),
              rejectionReason:
                  JsonMap.str(json['rejectionReason']).isEmpty ? null : JsonMap.str(json['rejectionReason']),
              photos: photos,
            )
          : null,
    );
  }

  @override
  Future<void> startTask(String id, {double? latitude, double? longitude}) async {
    await _api.patch('/api/Tasks/$id/status', body: <String, String>{'status': 'in_progress'});
    if (latitude != null && longitude != null) {
      await _api.patch(
        '/api/Tasks/$id/location-check',
        body: <String, num>{'latitude': latitude, 'longitude': longitude},
      );
    }
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? taskId,
  }) {
    return _api.post(
      '/api/Inspectors/me/location',
      body: <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        if (taskId != null && taskId.isNotEmpty) 'taskId': taskId,
      },
    );
  }

  @override
  Future<void> submitReport({
    required String taskId,
    required String generalCondition,
    required int qualityScore,
    required bool hasViolations,
    String? reportNotes,
    List<String> photoPaths = const <String>[],
    List<({List<int> bytes, String filename})> photoFiles = const <({List<int> bytes, String filename})>[],
  }) async {
    // Web لا يدعم MultipartFile.fromPath — نرفع بالبايتات.
    for (final photo in photoFiles) {
      await _api.postMultipart(
        '/api/Tasks/$taskId/media',
        files: <http.MultipartFile>[
          http.MultipartFile.fromBytes(
            'File',
            photo.bytes,
            filename: photo.filename.isEmpty ? 'photo.jpg' : photo.filename,
          ),
        ],
      );
    }

    for (final path in photoPaths) {
      if (path.isEmpty || path.startsWith('blob:')) continue;
      await _api.postMultipart(
        '/api/Tasks/$taskId/media',
        files: <http.MultipartFile>[
          await http.MultipartFile.fromPath('File', path),
        ],
      );
    }

    await _api.post(
      '/api/Tasks/$taskId/report',
      body: <String, dynamic>{
        'generalCondition': generalCondition,
        'qualityScore': qualityScore,
        'hasViolations': hasViolations,
        'reportNotes': reportNotes,
      },
    );
  }

  String _stageLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'جارية';
      case TaskStatus.returned:
        return 'معادة';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.delayed:
        return 'متأخرة';
      case TaskStatus.pending:
        return 'معلقة';
    }
  }
}
