import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

class HapticEditorScreen extends StatefulWidget {
  const HapticEditorScreen({super.key});

  @override
  State<HapticEditorScreen> createState() => _HapticEditorScreenState();
}

class _HapticEditorScreenState extends State<HapticEditorScreen> {
  late VideoPlayerController controller;

  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  int get currentTime =>
      controller.value.position.inMilliseconds;

  void addEvent() {
    final time = currentTime;

    final event = {
      "time": time,
      "pattern": [0, 80],
      "amp": [0, 200]
    };

    setState(() {
      events.add(event);
      events.sort((a, b) => a['time'].compareTo(b['time']));
    });
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }

  void vibrateEvent(Map event) {
    Vibration.vibrate(
      pattern: List<int>.from(event['pattern']),
      intensities: List<int>.from(event['amp']),
    );
  }

  String exportJson() {
    return const JsonEncoder.withIndent('  ').convert(events);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haptic Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final json = exportJson();

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Haptics JSON"),
                  content: SingleChildScrollView(
                    child: Text(json),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          /// 🎬 VIDEO
          if (controller.value.isInitialized)
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),

          /// ⏱ CONTROLS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => controller.play(),
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => controller.pause(),
              ),
              Text("$currentTime ms"),
            ],
          ),

          /// ➕ ADD EVENT
          ElevatedButton(
            onPressed: addEvent,
            child: const Text("Add Haptic Here"),
          ),

          const Divider(),

          /// 📋 EVENT LIST
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return ListTile(
                  title: Text("Time: ${event['time']} ms"),
                  subtitle: Text("Amp: ${event['amp']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.vibration),
                        onPressed: () => vibrateEvent(event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteEvent(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}