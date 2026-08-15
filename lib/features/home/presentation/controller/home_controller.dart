import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';
import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/entities/task_status.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required GetHomeOverviewUseCase getOverview,
    required InspectorTrackingService tracking,
    required InspectorRealtimeService realtime,
  })  : _getOverview = getOverview,
        _tracking = tracking,
        _realtime = realtime;

  final GetHomeOverviewUseCase _getOverview;
  final InspectorTrackingService _tracking;
  final InspectorRealtimeService _realtime;

  HomeOverview? _overview;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;
  StreamSubscription<InspectorIncomingNotification>? _notificationSubscription;

  HomeOverview? get overview => _overview;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _overview = await _getOverview();
      _realtime.setUnreadBadge(_overview!.unreadNotifications);
      await _syncTracking();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncTracking() async {
    final inProgress = _overview?.activeTasks
        .where((task) => task.status == TaskStatus.inProgress)
        .toList();
    if (inProgress == null || inProgress.isEmpty) return;
    final task = inProgress.first;
    await _tracking.start(
      task.id,
      taskTitle: task.title,
      siteLat: task.latitude,
      siteLng: task.longitude,
    );
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  void startListeningToNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = _realtime.incoming.listen((_) {
      load();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
