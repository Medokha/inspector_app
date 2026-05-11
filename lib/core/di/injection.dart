import 'package:inspector_app/core/network/http_client_factory.dart';

import 'package:inspector_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inspector_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inspector_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:inspector_app/features/auth/presentation/controller/login_controller.dart';
import 'package:inspector_app/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:inspector_app/features/counter/domain/usecases/increment_counter.dart';
import 'package:inspector_app/features/counter/presentation/controller/counter_controller.dart';

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
