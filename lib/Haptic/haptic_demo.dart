import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

class HapticDemo extends StatefulWidget {
  const HapticDemo({super.key});

  @override
  State<HapticDemo> createState() => _HapticDemoState();
}

class _HapticDemoState extends State<HapticDemo>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;

  List<dynamic> haptics = [];
  Set<int> triggered = {};
  Timer? timer;

  bool _hasVibrator = false;
  bool _hasCustomVibrations = false;
  bool _isPlaying = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    initVideo();
    loadHaptics();
    _checkVibrationCapabilities();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkVibrationCapabilities() async {
    _hasVibrator = (await Vibration.hasVibrator());
    _hasCustomVibrations = (await Vibration.hasCustomVibrationsSupport());

    if (mounted && !_hasCustomVibrations) {
      // Delay to ensure the widget is fully built before showing the dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUnsupportedWarning();
      });
    }
  }

  void _showUnsupportedWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2028),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2D35), width: 1),
        ),
        title: Row(
          children: const [
            Icon(Icons.info_outline_rounded, color: Color(0xFFE8C96D), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'LIMITED HAPTICS',
                style: TextStyle(
                  fontFamily: 'Courier',
                  color: Color(0xFFE8C96D),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your device does not fully support advanced custom vibration patterns. You will experience basic fallback vibrations instead.',
          style: TextStyle(color: Color(0xFF8A8F9A), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'UNDERSTOOD',
              style: TextStyle(
                fontFamily: 'Courier',
                color: Color(0xFFE8C96D),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
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
      if (!_controller.value.isPlaying) return;
      final position = _controller.value.position.inMilliseconds;
      for (var event in haptics) {
        final time = event['time'];
        if (!triggered.contains(time) && position >= time) {
          triggered.add(time);
          if (_hasVibrator) {
            if (_hasCustomVibrations) {
              Vibration.vibrate(
                pattern: List<int>.from(event['pattern']),
                intensities: List<int>.from(event['intensities']),
                sharpness: event['sharpness'] ?? 0.1,
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
    setState(() => _isPlaying = true);
  }

  void pause() {
    _controller.pause();
    timer?.cancel();
    Vibration.cancel();
    setState(() => _isPlaying = false);
  }

  // ── Opens fullscreen landscape and starts playback ──────────────────────────
  void _playInFullscreen() {
    if (!_isPlaying) {
      _controller.play();
      triggered.clear();
      startSync();
      setState(() => _isPlaying = true);
    }
    _openFullscreen();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenVideoPage(
          controller: _controller,
          isPlaying: _isPlaying,
          onPlay: play,
          onPause: pause,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      _buildInstructionBanner(), // ← NEW
                      const Spacer(),
                      _buildVideoCard(),
                      const Spacer(),
                      _buildControls(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Instruction Banner ───────────────────────────────────────────────────────
  Widget _buildInstructionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2D35), width: 1),
        ),
        child: Row(
          children: [
            // Icon accent
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8C96D).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: Color(0xFFE8C96D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Instructions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FOR BEST EXPERIENCE',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      color: Color(0xFFE8C96D),
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                
                  Text(
                    '🎧  Wear headphones for immersive audio',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Color(0xFF8A8F9A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '✋  Hold your phone firmly in hand',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Color(0xFF8A8F9A),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // Logo / Brand mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8C96D), Color(0xFFB87333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.vibration, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'HAPTIC',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8C96D),
                  letterSpacing: 4,
                ),
              ),
              Text(
                'CINEMA',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: Color(0xFF5A6070),
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Fullscreen button
          GestureDetector(
            onTap: _openFullscreen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2A2D35), width: 1),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF111318),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.fullscreen,
                    color: Color(0xFFE8C96D),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'FULL',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      color: Color(0xFF8A8F9A),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: const Color(0xFFE8C96D).withOpacity(0.04),
              blurRadius: 60,
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Video
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: const Color(0xFF0E1016),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE8C96D),
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                    ),

              // Cinematic top vignette
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Tap to play overlay → opens fullscreen directly
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isPlaying ? pause : _playInFullscreen,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),

              // Cinematic letterbox bars
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 2, color: Colors.black),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(height: 2, color: Colors.black),
              ),

              // LIVE / Playing indicator
              if (_isPlaying)
                Positioned(
                  top: 14,
                  right: 14,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFE8C96D).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8C96D),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PLAYING',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 9,
                                color: Color(0xFFE8C96D),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Film strip decoration
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              20,
              (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i % 2 == 0
                        ? const Color(0xFF1E2028)
                        : const Color(0xFF2A2D35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Play / Pause button → play opens fullscreen
        GestureDetector(
          onTap: _isPlaying ? pause : _playInFullscreen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isPlaying
                  ? const LinearGradient(
                      colors: [Color(0xFF1E2028), Color(0xFF14161C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE8C96D), Color(0xFFB87333)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: _isPlaying
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFB87333).withOpacity(0.0),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color(0xFFE8C96D).withOpacity(0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFB87333).withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
              border: Border.all(
                color: _isPlaying
                    ? const Color(0xFF2A2D35)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: _isPlaying ? const Color(0xFF5A6070) : Colors.black,
              size: 36,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          _isPlaying ? 'TAP TO PAUSE' : 'TAP TO PLAY',
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 10,
            color: Color(0xFF3A3F4A),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ─── Fullscreen Landscape Video Page ───────────────────────────────────────────

class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const _FullscreenVideoPage({
    required this.controller,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
  });

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  bool _showControls = true;
  Timer? _hideTimer;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlay() {
    if (_isPlaying) {
      widget.onPause();
    } else {
      widget.onPlay();
    }
    setState(() => _isPlaying = !_isPlaying);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    // Restore portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            Center(
              child: widget.controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: widget.controller.value.aspectRatio,
                      child: VideoPlayer(widget.controller),
                    )
                  : const SizedBox.shrink(),
            ),

            // Overlay controls (animated in/out)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  // Top gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top bar: back button + title
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF2A2D35), width: 1),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFFE8C96D),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'HAPTIC CINEMA',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            color: Color(0xFFE8C96D),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Play/Pause
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(
                              color: const Color(0xFFE8C96D).withOpacity(0.6),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFE8C96D).withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFFE8C96D),
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Bottom: fullscreen exit hint
                  Positioned(
                    bottom: 16,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF2A2D35), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.fullscreen_exit,
                                color: Color(0xFF8A8F9A), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'EXIT',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 9,
                                color: Color(0xFF8A8F9A),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}