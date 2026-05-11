class Counter {
  const Counter(this.value);

  final int value;

  Counter increment() => Counter(value + 1);
}
