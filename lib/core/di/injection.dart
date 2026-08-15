import 'package:inspector_app/core/network/api_client.dart';
import 'package:inspector_app/core/network/http_client_factory.dart';
import 'package:inspector_app/core/notifications/inspector_realtime_service.dart';

import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_session.dart';
import 'package:inspector_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inspector_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:inspector_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:inspector_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:inspector_app/features/auth/presentation/controller/login_controller.dart';
import 'package:inspector_app/features/auth/presentation/controller/reset_password_controller.dart';
import 'package:inspector_app/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:inspector_app/features/counter/domain/usecases/increment_counter.dart';
import 'package:inspector_app/features/counter/presentation/controller/counter_controller.dart';
import 'package:inspector_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:inspector_app/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:inspector_app/features/home/presentation/controller/home_controller.dart';
import 'package:inspector_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:inspector_app/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:inspector_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:inspector_app/features/profile/domain/usecases/get_profile_overview_usecase.dart';
import 'package:inspector_app/features/profile/presentation/controller/profile_controller.dart';
import 'package:inspector_app/features/route_map/data/repositories/route_repository_impl.dart';
import 'package:inspector_app/features/route_map/domain/usecases/get_route_stops_usecase.dart';
import 'package:inspector_app/features/route_map/presentation/controller/route_controller.dart';
import 'package:inspector_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:inspector_app/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:inspector_app/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:inspector_app/features/settings/presentation/controller/settings_controller.dart';
import 'package:inspector_app/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:inspector_app/features/tasks/data/services/inspector_tracking_service.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/start_task_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/submit_task_report_usecase.dart';
import 'package:inspector_app/features/tasks/presentation/controller/report_controller.dart';
import 'package:inspector_app/features/tasks/presentation/controller/task_details_controller.dart';
import 'package:inspector_app/features/tasks/presentation/controller/tasks_controller.dart';

CounterController createCounterController() {
  final repository = CounterRepositoryImpl();
  final incrementCounter = IncrementCounter();
  return CounterController(
    repository: repository,
    incrementCounter: incrementCounter,
  );
}

final _authSession = AuthSession();
final _apiClient = ApiClient(createHttpClient(), _authSession);
final _authRepository = AuthRepositoryImpl(AuthRemoteDataSource(_apiClient), _authSession);
final _tasksRepository = TasksRepositoryImpl(_apiClient);
final _trackingService = InspectorTrackingService(_tasksRepository);
final _realtimeService = InspectorRealtimeService(_apiClient, _authSession);
final _notificationsRepository = NotificationsRepositoryImpl(_apiClient);

LoginController createLoginController() {
  return LoginController(loginUseCase: LoginUseCase(_authRepository));
}

ResetPasswordController createResetPasswordController() {
  return ResetPasswordController(resetPasswordUseCase: ResetPasswordUseCase(_authRepository));
}

Future<void> restoreSession() => _authSession.restore();

Future<void> startInspectorRealtime() => _realtimeService.start();

Future<void> logout() async {
  _trackingService.stop();
  await _realtimeService.stop();
  await LogoutUseCase(_authRepository)();
}

AuthSession currentAuthSession() => _authSession;

InspectorRealtimeService inspectorRealtimeService() => _realtimeService;

HomeController createHomeController() {
  final repository = HomeRepositoryImpl(_apiClient);
  final useCase = GetHomeOverviewUseCase(repository);
  return HomeController(
    getOverview: useCase,
    tracking: _trackingService,
    realtime: _realtimeService,
  );
}

TasksController createTasksController() {
  final useCase = GetTasksUseCase(_tasksRepository);
  return TasksController(getTasks: useCase);
}

TaskDetailsController createTaskDetailsController() {
  return TaskDetailsController(
    getTaskDetails: GetTaskDetailsUseCase(_tasksRepository),
    startTask: StartTaskUseCase(_tasksRepository),
    tracking: _trackingService,
  );
}

ReportController createReportController() {
  return ReportController(
    submitReport: SubmitTaskReportUseCase(_tasksRepository),
    tracking: _trackingService,
  );
}

NotificationsController createNotificationsController() {
  return NotificationsController(
    getNotifications: GetNotificationsUseCase(_notificationsRepository),
    getUnreadCount: GetUnreadNotificationsUseCase(_notificationsRepository),
    markRead: MarkNotificationReadUseCase(_notificationsRepository),
    markAllRead: MarkAllNotificationsReadUseCase(_notificationsRepository),
    realtime: _realtimeService,
  );
}

RouteController createRouteController() {
  final repository = RouteRepositoryImpl(_apiClient);
  final useCase = GetRouteStopsUseCase(repository);
  return RouteController(getStops: useCase);
}

ProfileController createProfileController() {
  final repository = ProfileRepositoryImpl(_apiClient, _authSession);
  final useCase = GetProfileOverviewUseCase(repository);
  return ProfileController(getOverview: useCase);
}

final _settingsRepository = SettingsRepositoryImpl(_apiClient);
SettingsController? _settingsController;

SettingsController createSettingsController() {
  _settingsController ??= SettingsController(
    getSettings: GetSettingsUseCase(_settingsRepository),
    updateSettings: UpdateSettingsUseCase(_settingsRepository),
  );
  return _settingsController!;
}
