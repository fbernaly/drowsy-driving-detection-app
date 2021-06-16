import 'face_processor.dart';

class DrivingEvent {
  final DateTime startTime;
  final Duration duration;
  final List<ClosedEyesEvent> events;

  DrivingEvent(this.startTime, this.duration, this.events);

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration.inMilliseconds,
      'events': events.map((event) => event.toJson()).toList()
    };
  }

  Duration totalClosedEyesDuration() {
    var duration = Duration();
    for (final event in events) {
      duration += event.duration;
    }
    return duration;
  }

  DrivingEvent.fromJson(Map<String, dynamic> json)
      : startTime = DateTime.fromMillisecondsSinceEpoch(json['startTime']),
        duration = Duration(milliseconds: json['duration']),
        events = ClosedEyesEvent.fromJsonList(json['events']);

  @override
  String toString() {
    return 'DrivingEvent{startTime: $startTime, duration: $duration, events: $events}';
  }
}

class ClosedEyesEvent {
  final DateTime startTime;
  final Duration duration;
  final DrowsinessLevel level;

  ClosedEyesEvent(this.startTime, this.duration, this.level);

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration.inMilliseconds,
      'level': level.index,
    };
  }

  ClosedEyesEvent.fromJson(Map<String, dynamic> json)
      : startTime = DateTime.fromMillisecondsSinceEpoch(json['startTime']),
        duration = Duration(milliseconds: json['duration']),
        level = DrowsinessLevel.values[json['level']];

  static List<ClosedEyesEvent> fromJsonList(dynamic json) {
    List<ClosedEyesEvent> events = [];
    for (final event in json) {
      events.add(ClosedEyesEvent.fromJson(event));
    }
    return events;
  }

  @override
  String toString() {
    return 'ClosedEyesEvent{startTime: $startTime, duration: $duration, level: $level}';
  }
}
