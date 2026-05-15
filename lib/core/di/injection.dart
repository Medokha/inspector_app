import 'package:inspector_app/core/network/http_client_factory.dart';
import 'package:inspector_app/core/database/database_service.dart';
import 'package:inspector_app/core/sync/sync_service.dart';
import 'package:inspector_app/features/tasks/presentation/controller/report_controller.dart';
import 'package:inspector_app/features/profile/presentation/controller/reports_controller.dart';

import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inspector_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:inspector_app/features/auth/presentation/controller/login_controller.dart';
import 'package:inspector_app/features/auth/presentation/controller/session_controller.dart';
import 'package:inspector_app/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:inspector_app/features/counter/domain/usecases/increment_counter.dart';
import 'package:inspector_app/features/counter/presentation/controller/counter_controller.dart';
import 'package:inspector_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:inspector_app/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:inspector_app/features/home/presentation/controller/home_controller.dart';
import 'package:inspector_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:inspector_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:inspector_app/features/profile/data/datasources/profile_remote_data_source.dart';
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
import 'package:inspector_app/features/tasks/data/datasources/tasks_remote_data_source.dart';
import 'package:inspector_app/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_task_details_usecase.dart';
import 'package:inspector_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
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

final _authLocalDataSource = AuthLocalDataSource();
final _dbService = DatabaseService();
SessionController? _sessionController;
SyncService? _syncService;

SyncService getSyncService() {
  if (_syncService != null) return _syncService!;
  
  final client = createHttpClient();
  final tasksRemote = TasksRemoteDataSource(client, _authLocalDataSource);
  _syncService = SyncService(_dbService, tasksRemote);
  _syncService!.init();
  return _syncService!;
}

SessionController createSessionController() {
  final client = createHttpClient();
  final remote = AuthRemoteDataSource(client);
  final repository = AuthRepositoryImpl(remote, _authLocalDataSource);
  
  _sessionController ??= SessionController(
    repository: repository,
    localDataSource: _authLocalDataSource,
  );
  return _sessionController!;
}

LoginController createLoginController() {
  final client = createHttpClient();
  final remote = AuthRemoteDataSource(client);
  final repository = AuthRepositoryImpl(remote, _authLocalDataSource);
  final useCase = LoginUseCase(repository);
  return LoginController(
    loginUseCase: useCase,
    sessionController: createSessionController(),
  );
}

HomeController createHomeController() {
  final client = createHttpClient();
  final notificationRemote = NotificationsRemoteDataSource(client, _authLocalDataSource);
  final notificationRepo = NotificationsRepositoryImpl(notificationRemote);
  
  final tasksRemote = TasksRemoteDataSource(client, _authLocalDataSource);
  final tasksRepo = TasksRepositoryImpl(tasksRemote);
  
  final repository = HomeRepositoryImpl(notificationRepo, tasksRepo);
  final useCase = GetHomeOverviewUseCase(repository);
  return HomeController(getOverview: useCase);
}

TasksController createTasksController() {
  final client = createHttpClient();
  final remote = TasksRemoteDataSource(client, _authLocalDataSource);
  final repository = TasksRepositoryImpl(remote);
  return TasksController(
    getTasks: GetTasksUseCase(repository),
  );
}

TaskDetailsController createTaskDetailsController() {
  final client = createHttpClient();
  final remote = TasksRemoteDataSource(client, _authLocalDataSource);
  final repository = TasksRepositoryImpl(remote);
  final useCase = GetTaskDetailsUseCase(repository);
  return TaskDetailsController(getTaskDetails: useCase);
}
 
ReportController createReportController(String taskId) {
  return ReportController(
    taskId: taskId,
    db: _dbService,
    syncService: getSyncService(),
  );
}

NotificationsController createNotificationsController() {
  final client = createHttpClient();
  final remote = NotificationsRemoteDataSource(client, _authLocalDataSource);
  final repository = NotificationsRepositoryImpl(remote);
  final getItems = GetNotificationsUseCase(repository);
  final getUnread = GetUnreadNotificationsUseCase(repository);
  return NotificationsController(getNotifications: getItems, getUnreadCount: getUnread, repository: repository);
}

RouteController createRouteController() {
  final client = createHttpClient();
  final remote = TasksRemoteDataSource(client, _authLocalDataSource);
  final repository = RouteRepositoryImpl(remote);
  final useCase = GetRouteStopsUseCase(repository);
  return RouteController(getStops: useCase);
}

ProfileController createProfileController() {
  final client = createHttpClient();
  final remote = ProfileRemoteDataSource(client, _authLocalDataSource);
  final repository = ProfileRepositoryImpl(remote);
  final useCase = GetProfileOverviewUseCase(repository);
  return ProfileController(getOverview: useCase);
}

ReportsController createReportsController() {
  final client = createHttpClient();
  final remote = ProfileRemoteDataSource(client, _authLocalDataSource);
  final repository = ProfileRepositoryImpl(remote);
  return ReportsController(repository: repository);
}

final _settingsRepository = SettingsRepositoryImpl();
SettingsController? _settingsController;

SettingsController createSettingsController() {
  _settingsController ??= SettingsController(
    getSettings: GetSettingsUseCase(_settingsRepository),
    updateSettings: UpdateSettingsUseCase(_settingsRepository),
  );
  return _settingsController!;
}
