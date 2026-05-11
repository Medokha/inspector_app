import 'package:inspector_app/features/counter/domain/entities/counter.dart';

class IncrementCounter {
  Counter call(Counter counter) => counter.increment();
}
