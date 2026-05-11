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
