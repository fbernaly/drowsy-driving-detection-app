import 'package:json_store/json_store.dart';

import 'events.dart';

class Storage {
  final List<ClosedEyesEvent> events = [];
  final DateTime startTime = DateTime.now();

  Future store() async {
    final duration = DateTime.now().difference(startTime);
    final driving = DrivingEvent(startTime, duration, events);
    JsonStore jsonStore = JsonStore();
    await jsonStore.setItem(
        'driving-${driving.startTime.millisecondsSinceEpoch}',
        driving.toJson());
  }

  static Future<List<DrivingEvent>> fetch() async {
    JsonStore jsonStore = JsonStore();
    List<Map<String, dynamic>>? json = await jsonStore.getListLike('driving-%');
    List<DrivingEvent> drivings = json != null
        ? json.map((drivingJson) => DrivingEvent.fromJson(drivingJson)).toList()
        : [];
    return drivings;
  }

  static Future delete(DrivingEvent driving) async {
    JsonStore jsonStore = JsonStore();
    await jsonStore
        .deleteItem('driving-${driving.startTime.millisecondsSinceEpoch}');
  }
}
