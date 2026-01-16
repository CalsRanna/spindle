import 'package:signals/signals.dart';

class HomeViewModel {
  final counter = Signal(0);

  void increment() {
    counter.value++;
  }

  void decrement() {
    counter.value--;
  }

  void dispose() {
    counter.dispose();
  }
}
