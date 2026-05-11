import 'package:inspector_app/features/counter/domain/entities/counter.dart';

abstract class CounterRepository {
  Counter get();
  Counter save(Counter counter);
}
