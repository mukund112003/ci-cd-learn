import 'dart:async';

import 'package:Haptic/Haptic/haptic_model.dart';
import 'package:vibration/vibration.dart';

class HapticEngine {
  final List<HapticEvent> events;
  final Set<int> triggered = {};
  Timer? _timer;

  HapticEngine(this.events);

  void start(int Function() getPosition) {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      final position = getPosition();

      for (var event in events) {
        if (!triggered.contains(event.time) &&
            position >= event.time &&
            position < event.time + 80) {

          if (await Vibration.hasVibrator() ) {
            Vibration.vibrate(
              pattern: event.pattern,
              intensities: event.amplitudes,
            );
          }

          triggered.add(event.time);
        }
      }
    });
  }

  void stop() {
    _timer?.cancel();
    Vibration.cancel();
  }

  void reset() {
    triggered.clear();
  }
}