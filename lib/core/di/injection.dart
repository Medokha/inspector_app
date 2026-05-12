import 'package:inspector_app/core/network/http_client_factory.dart';

import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inspector_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:inspector_app/features/auth/presentation/controller/login_controller.dart';
import 'package:inspector_app/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:inspector_app/features/counter/domain/usecases/increment_counter.dart';
import 'package:inspector_app/features/counter/presentation/controller/counter_controller.dart';
import 'package:inspector_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:inspector_app/features/home/domain/usecases/get_home_overview_usecase.dart';
import 'package:inspector_app/features/home/presentation/controller/home_controller.dart';
import 'package:inspector_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:inspector_app/features/notifications/domain/usecases/get_unread_notifications_usecase.dart';
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

LoginController createLoginController() {
  final client = createHttpClient();
  final remote = AuthRemoteDataSource(client);
  final repository = AuthRepositoryImpl(remote);
  final useCase = LoginUseCase(repository);
  return LoginController(loginUseCase: useCase);
}

HomeController createHomeController() {
  final repository = HomeRepositoryImpl();
  final useCase = GetHomeOverviewUseCase(repository);
  return HomeController(getOverview: useCase);
}

TasksController createTasksController() {
  final repository = TasksRepositoryImpl();
  final useCase = GetTasksUseCase(repository);
  return TasksController(getTasks: useCase);
}

TaskDetailsController createTaskDetailsController() {
  final repository = TasksRepositoryImpl();
  final useCase = GetTaskDetailsUseCase(repository);
  return TaskDetailsController(getTaskDetails: useCase);
}

NotificationsController createNotificationsController() {
  final repository = NotificationsRepositoryImpl();
  final getItems = GetNotificationsUseCase(repository);
  final getUnread = GetUnreadNotificationsUseCase(repository);
  return NotificationsController(getNotifications: getItems, getUnreadCount: getUnread);
}

RouteController createRouteController() {
  final repository = RouteRepositoryImpl();
  final useCase = GetRouteStopsUseCase(repository);
  return RouteController(getStops: useCase);
}

ProfileController createProfileController() {
  final repository = ProfileRepositoryImpl();
  final useCase = GetProfileOverviewUseCase(repository);
  return ProfileController(getOverview: useCase);
}

SettingsController createSettingsController() {
  final repository = SettingsRepositoryImpl();
  final getSettings = GetSettingsUseCase(repository);
  final updateSettings = UpdateSettingsUseCase(repository);
  return SettingsController(getSettings: getSettings, updateSettings: updateSettings);
}
