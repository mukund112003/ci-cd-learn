class HapticEvent {
  final int time;
  final List<int> pattern;
  final List<int> amplitudes;

  HapticEvent({
    required this.time,
    required this.pattern,
    required this.amplitudes,
  });

  factory HapticEvent.fromJson(Map<String, dynamic> json) {
    return HapticEvent(
      time: json['time'],
      pattern: List<int>.from(json['pattern']),
      amplitudes: List<int>.from(json['amp']),
    );
  }
}