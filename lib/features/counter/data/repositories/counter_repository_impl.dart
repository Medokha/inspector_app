import 'package:inspector_app/features/counter/domain/entities/counter.dart';
import 'package:inspector_app/features/counter/domain/repositories/counter_repository.dart';

class CounterRepositoryImpl implements CounterRepository {
  CounterRepositoryImpl({Counter? initialCounter})
      : _counter = initialCounter ?? const Counter(0);

  Counter _counter;

  @override
  Counter get() => _counter;

  @override
  Counter save(Counter counter) {
    _counter = counter;
    return _counter;
  }
}
