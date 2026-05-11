import 'package:flutter/foundation.dart';

import 'package:inspector_app/features/counter/domain/entities/counter.dart';
import 'package:inspector_app/features/counter/domain/repositories/counter_repository.dart';
import 'package:inspector_app/features/counter/domain/usecases/increment_counter.dart';

class CounterController extends ChangeNotifier {
  CounterController({
    required CounterRepository repository,
    required IncrementCounter incrementCounter,
  })  : _repository = repository,
        _incrementCounter = incrementCounter,
        _counter = repository.get();

  final CounterRepository _repository;
  final IncrementCounter _incrementCounter;

  Counter _counter;

  int get value => _counter.value;

  void increment() {
    _counter = _incrementCounter(_counter);
    _counter = _repository.save(_counter);
    notifyListeners();
  }
}
