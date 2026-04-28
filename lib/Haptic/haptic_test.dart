import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class HapticTestScreen extends StatelessWidget {
  const HapticTestScreen({super.key});

  Future<void> vibrateSimple() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500, amplitude: 100);
    }
  }

  Future<void> vibrateStrong() async {
    if (await Vibration.hasAmplitudeControl()) {
      Vibration.vibrate(duration: 300, amplitude: 255);
    } else {
      Vibration.vibrate(duration: 300);
    }
  }
Future<void> engineStart() async {
  await Vibration.vibrate(
    pattern: [0, 150],
    intensities: [0, 255],
  );
}
Future<void> engineRamp() async {
  await Vibration.vibrate(
    pattern: [0, 60, 20, 80, 20, 100, 20, 120],
    intensities: [0, 180, 0, 200, 0, 220, 0, 240],
  );
}
void engineIdle() async {
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(
      pattern: [0, 40, 30, 40, 30],
      intensities: [0, 120, 0, 140, 0],
      repeat: 0,
    );
  }
}
void stopEngine() {
  Vibration.cancel();
}
Future<void> startEngineRealistic() async {
  // 💥 1. Ignition Kick
  await Vibration.vibrate(
    pattern: [0, 180],
    intensities: [0, 255],
  );

  await Future.delayed(Duration(milliseconds: 120));

  // ⚡ 2. Engine Struggle (irregular pulses)
  await Vibration.vibrate(
    pattern: [0, 70, 40, 90, 60, 70],
    intensities: [0, 200, 0, 220, 0, 180],
  );

  await Future.delayed(Duration(milliseconds: 200));

  // 🔄 3. Ramp Up (non-linear acceleration)
  await Vibration.vibrate(
    pattern: [
      0, 50, 30, 70, 25, 90, 20, 110, 15, 130
    ],
    intensities: [
      0, 180,
      0, 200,
      0, 220,
      0, 240,
      0, 255
    ],
  );

  await Future.delayed(Duration(milliseconds: 300));

  // 🏎️ 4. Smooth Idle Loop
  engineIdle();
}
  Future<void> vibratePattern() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(
        pattern: [0, 100, 50, 200, 50, 300],
        intensities: [0, 180, 0, 255, 0, 200],
      );
    }
  }

  Future<void> stopVibration() async {
    Vibration.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haptic Controller"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: vibrateSimple,
              child: const Text("Simple Vibration"),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: vibrateStrong,
              child: const Text("Strong Vibration"),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: vibratePattern,
              child: const Text("Pattern Vibration"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: vibratePattern,
              child: const Text("Pattern Vibration"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: startEngineRealistic,
              child: const Text("Start Engine"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: stopEngine,
              child: const Text("Stop Engine"),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: stopVibration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}