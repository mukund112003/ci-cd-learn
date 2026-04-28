import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

class HapticVideoScreen extends StatefulWidget {
  const HapticVideoScreen({super.key});

  @override
  State<HapticVideoScreen> createState() => _HapticVideoScreenState();
}

class _HapticVideoScreenState extends State<HapticVideoScreen> {
  late VideoPlayerController _controller;

  List<dynamic> haptics = [];
  Set<int> triggered = {};
  Timer? timer;

 bool _hasVibrator = false;
  bool _hasCustomVibrations = false;

  @override
  void initState() {
    super.initState();
    initVideo();
    loadHaptics();
    _checkVibrationCapabilities();
  }

  // Future<void> initVideo() async {
  //   _controller = VideoPlayerController.asset('assets/dhurandhar.mp4');
  //   await _controller.initialize();
  //   setState(() {});
  // }

  // Future<void> loadHaptics() async {
  //   try {
  //     final jsonString = await rootBundle.loadString('assets/haptics.json');
  //     haptics = jsonDecode(jsonString);
  //   } catch (e) {
  //     print("=======================================================");
  //     debugPrint(e.toString());
  //     print("=======================================================");
  //   }
  // }

  // void startSync() {
  //   timer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
  //     final position = _controller.value.position.inMilliseconds;
  //     for (var event in haptics) {
  //       final time = event['time'];

  //       if (!triggered.contains(time) &&
  //           position >= time &&
  //           position < time + 80) {
  //         if (await Vibration.hasVibrator()) {
  //           print("=======================================================");
  //           print("${event['comment']}");
  //           print("=======================================================");
  //           Vibration.vibrate(
  //             pattern: List<int>.from(event['pattern']),
  //             intensities: List<int>.from(event['intensities']),
  //           );
  //         }

  //         triggered.add(time);
  //       }
  //     }
  //   });
  // }

Future<void> _checkVibrationCapabilities() async {
    _hasVibrator = (await Vibration.hasVibrator());
    _hasCustomVibrations = (await Vibration.hasCustomVibrationsSupport());
  }

  Future<void> initVideo() async {
    _controller = VideoPlayerController.asset('assets/dhurandhar.mp4');
    await _controller.initialize();
    setState(() {});
  }

  Future<void> loadHaptics() async {
    try {
      final jsonString = await rootBundle.loadString('assets/haptics.json');
      haptics = jsonDecode(jsonString);
    } catch (e) {
      debugPrint("Error loading JSON: ${e.toString()}");
    }
  }

void startSync() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Don't process if the video isn't actually playing
      if (!_controller.value.isPlaying) return;

      final position = _controller.value.position.inMilliseconds;
      
      for (var event in haptics) {
        final time = event['time'];

        // Fix: Removed the restrictive "time + 80" window.
        // As long as the video has passed the timestamp and it hasn't fired yet, it will fire.
        if (!triggered.contains(time) && position >= time) {
          
          // Add to triggered immediately to prevent double-firing in the next loop
          triggered.add(time);

          if (_hasVibrator) {
            if (_hasCustomVibrations) {
              Vibration.vibrate(
                pattern: List<int>.from(event['pattern']),
                intensities: List<int>.from(event['intensities']),
              );
            } else {
              Vibration.vibrate();
            }
          }
        }
      }
    });
  }
  void play() {
    _controller.play();
    triggered.clear();
    startSync();
  }

  void pause() {
    _controller.pause();
    timer?.cancel();
    Vibration.cancel();
  }

  void gun2() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          //   // [Delay, Vibrate, Delay, Vibrate]
          //   pattern: [0, 30, 20, 50, 150, 30, 20, 50, 100, 90, 20, 50],
          //   intensities: [0, 255, 0, 120, 0, 255, 0, 120, 0, 180, 0, 90],
          // );
          // [Delay, Vibrate, Delay, Vibrate]
          pattern: [0, 30, 20, 50, 150, 30, 20, 50],
          intensities: [0, 255, 0, 120, 0, 255, 0, 120],
        );
      } else {
        // Fallback for older devices that don't support custom intensities
        Vibration.vibrate();
      }
    }
  }

  void oneShotMchineGun() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 25, 20, 25, 20, 25, 20, 25, 20, 25, 20, 25],

          intensities: [0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void launcher() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 100, 20, 50, 20, 50],
          intensities: [0, 255, 0, 200, 0, 150],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void lighter() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 20, 15, 30, 15, 20],
          intensities: [0, 255, 0, 120, 0, 60],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void threeGunShot() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 30, 20, 50, 150, 30, 20, 50, 90, 30, 20, 50],
          intensities: [0, 255, 0, 120, 0, 255, 0, 120, 0, 255, 0, 120],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

 void fire() async {
    // Note: I'm using the cached variables from the previous fix to keep your app fast!
    if (_hasVibrator) {
      if (_hasCustomVibrations) {
        Vibration.vibrate(
          // Pattern: [Wait, Vibrate, Wait, Vibrate...]
          // The vibrate times are extremely short (15-25ms) to feel like small pops.
          // The wait times vary (80-200ms) to create an organic, unpredictable crackle.
          // Total duration is exactly 1485ms (just under 1.5 seconds).
          pattern: [
            0, 20, 100, 15, 150, 25, 80, 15, 200, 20, 120, 15, 100, 20, 150, 25, 80, 15, 200, 20, 100, 15
          ],
          
          // Intensities: [0, Low, 0, Lower, 0, Slightly Higher...]
          // Values max out at 45 (out of 255) to keep it strictly in the background.
          intensities: [
            0, 30, 0, 20, 0, 40, 0, 15, 0, 35, 0, 25, 0, 30, 0, 45, 0, 20, 0, 35, 0, 15
          ],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }
  void simpleBass() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 140, 10, 20],
          intensities: [0, 160, 0, 30],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void doubleBass() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 70, 170, 70, 100],
          intensities: [0, 150, 0, 150, 180],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void doubleShotMachineGun() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 100, 30, 30, 20, 30],
          intensities: [0, 255, 0, 255, 0, 100],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void pistolShot() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 30, 20, 50],
          intensities: [0, 255, 0, 120],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void chain() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [
            0,
            20,
            30,
            15,
            40,
            20,
            30,
            25,
            30,
            20,
            25,
            15,
            35,
            20,
            30,
            15,
            40,
            20,
            35,
            15,
            45,
            20,
            40,
            15,
            50,
            20,
            45,
          ],
          intensities: [
            0,
            30,
            0,
            40,
            0,
            35,
            0,
            45,
            0,
            50,
            0,
            40,
            0,
            55,
            0,
            45,
            0,
            60,
            0,
            50,
            0,
            65,
            0,
            55,
            0,
            70,
            0,
          ],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  void blast() async {
    if (await Vibration.hasVibrator() == true) {
      if (await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(
          pattern: [0, 130, 20, 100, 20, 70, 20, 30],
          intensities: [0, 255, 0, 200, 0, 150, 0, 100],
        );
      } else {
        Vibration.vibrate();
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1016),
      appBar: AppBar(
        title: const Text(
          'HAPTIC VIDEO TEST',
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8C96D),
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF111318),
        iconTheme: const IconThemeData(color: Color(0xFFE8C96D)),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // INSTRUCTION BANNER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2028),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2D35)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111318),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.headphones_rounded,
                    color: Color(0xFFE8C96D),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'OPTIMAL EXPERIENCE',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8C96D),
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Please wear headphones and hold your phone firmly in your hand.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A8F9A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_controller.value.isInitialized) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2D35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                final maxDuration = value.duration.inMilliseconds.toDouble();
                final currentPosition = value.position.inMilliseconds
                    .toDouble()
                    .clamp(0.0, maxDuration);

                String formatDuration(Duration d) {
                  final minutes = d.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  final seconds = d.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0');
                  return d.inHours > 0
                      ? '${d.inHours}:$minutes:$seconds'
                      : '$minutes:$seconds';
                }

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFE8C96D),
                        inactiveTrackColor: const Color(0xFF2A2D35),
                        thumbColor: const Color(0xFFE8C96D),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(disabledThumbRadius: 0, enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: currentPosition,
                        min: 0.0,
                        max: maxDuration > 0 ? maxDuration : 1.0,
                        onChanged: (double newValue) {
                          _controller.seekTo(
                            Duration(milliseconds: newValue.toInt()),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(value.position),
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              color: Color(0xFF8A8F9A),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatDuration(value.duration),
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              color: Color(0xFF8A8F9A),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 32),

          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModernButton(
                icon: Icons.play_arrow_rounded,
                label: "PLAY",
                onPressed: play,
                isPrimary: true,
              ),
              const SizedBox(width: 20),
              _buildModernButton(
                icon: Icons.pause_rounded,
                label: "PAUSE",
                onPressed: pause,
                isPrimary: false,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF2A2D35)),
          const SizedBox(height: 24),

          // Action Buttons
          const Center(
            child: Text(
              'HAPTIC TESTS',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: Color(0xFF5A6070),
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
               _buildHapticButton("Gun 2 Shot", gun2),
               _buildHapticButton("Machine", oneShotMchineGun),
               _buildHapticButton("Launcher", launcher),
               _buildHapticButton("Lighter", lighter),
               _buildHapticButton("Three Gun Shot", threeGunShot),
               _buildHapticButton("Double Shot Machine Gun", doubleShotMachineGun),
               _buildHapticButton("Pistol shot", pistolShot),
               _buildHapticButton("Fire", fire),
               _buildHapticButton("Chain", chain),
               _buildHapticButton("Simple Bass", simpleBass),
               _buildHapticButton("Double Bass", doubleBass),
               _buildHapticButton("Blast", blast),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildModernButton({required IconData icon, required String label, required VoidCallback onPressed, required bool isPrimary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontSize: 13,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary ? Colors.black : const Color(0xFFE8C96D),
        backgroundColor: isPrimary ? const Color(0xFFE8C96D) : const Color(0xFF1E2028),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: isPrimary ? 8 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFF2A2D35)),
        ),
      ),
    );
  }

  Widget _buildHapticButton(String label, VoidCallback onPressed) {
    return ActionChip(
      onPressed: onPressed,
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A8F9A),
        ),
      ),
      backgroundColor: const Color(0xFF111318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF2A2D35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
