import 'dart:io';

import 'package:drowsy_driving_detection_app/model/location_manager.dart';
import 'package:drowsy_driving_detection_app/model/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'face_detector_screen.dart';
import '../model/events.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DrivingEvent> drivings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FocusDetector(
        onFocusGained: _onFocusGained,
        child: SafeArea(
          child: _body(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startDriving,
        backgroundColor: Theme.of(context).primaryColor,
        label: Text('Start Driving'),
        icon: Icon(Icons.directions_car),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Drivings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
              child: ListView.builder(
            itemCount: drivings.length,
            itemBuilder: (context, index) {
              return _drivingCard(drivings[index]);
            },
          ))
        ],
      ),
    );
  }

  Widget _drivingCard(DrivingEvent drivingEvent) {
    final markers = <LatLng>[];
    for (final event in drivingEvent.events) {
      if (event.locationData != null &&
          event.locationData?.longitude != null &&
          event.locationData?.latitude != null) {
        markers.add(LatLng(
            event.locationData!.latitude!, event.locationData!.longitude!));
      }
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat.yMMMMd().add_jm().format(drivingEvent.startTime),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    child: Icon(Icons.delete_forever),
                    onTap: () => _delete(drivingEvent),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text('Duration: ${drivingEvent.duration.localizedString()}'),
              SizedBox(height: 8),
              Text(
                  'Closing eyes events: ${drivingEvent.events.length} ${drivingEvent.totalClosedEyesDuration().inSeconds > 0 ? 'during ${drivingEvent.totalClosedEyesDuration().localizedString()}' : ''}'),
              if (markers.isNotEmpty)
                InkWell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Show Map',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  onTap: () => _showMarkers(markers),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDriving() async {
    final dailyResults = await LocationManager().getDailyResults();
    if (dailyResults == null ||
        dailyResults.sunrise == null ||
        dailyResults.sunset == null) {
      return;
    }
    final now = DateTime.now();
    final isBeforeSunrise = dailyResults.sunrise!.isAfter(now);
    final isAfterSunset = now.isAfter(dailyResults.sunset!);
    final recommended = !isBeforeSunrise && !isAfterSunset;
    void openDrivingScreen() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const FaceDetectorScreen()));
    }

    if (!recommended) {
      const title = 'Driver drowsiness detection alert';
      final message =
          'Driver drowsiness detection is not recommended ${isBeforeSunrise ? 'before sunrise' : ''}${isAfterSunset ? 'after sunset' : ''}';
      const cancel = 'Don\'t Allow';
      const ok = 'Allow';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (Platform.isAndroid) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openDrivingScreen();
                  },
                  child: Text(ok),
                ),
              ],
            );
          } else {
            return CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                    openDrivingScreen();
                  },
                ),
              ],
            );
          }
        },
      );
    } else {
      openDrivingScreen();
    }
  }

  void _showMarkers(List<LatLng> markers) async {
    final location = await LocationManager().getLocation();

    if (location == null ||
        location.latitude == null ||
        location.longitude == null) {
      return null;
    }

    final widget = MapScreen(
      currentLocation: LatLng(location.latitude!, location.longitude!),
      markers: markers,
    );

    if (Platform.isAndroid) {
      showBarModalBottomSheet(
          context: context,
          builder: (context) {
            return widget;
          });
    } else {
      showCupertinoModalBottomSheet(
          context: context,
          builder: (context) {
            return widget;
          });
    }
  }

  void _onFocusGained() async {
    drivings = await Storage.fetch();
    drivings.sort((a, b) => -a.startTime.compareTo(b.startTime));
    setState(() {});
  }

  void _delete(DrivingEvent driving) async {
    await Storage.delete(driving);
    _onFocusGained();
  }
}

extension DurationExtension on Duration {
  String localizedString() {
    var output = '';
    if (inHours > 0) {
      output += '$inHours hour${inHours > 1 ? 's' : ''} ';
    }
    final min = inMinutes % 60;
    if (min > 0) {
      output += '$min min${inMinutes > 1 ? 's' : ''} ';
    }
    final sec = inSeconds % 60;
    if (sec > 0) {
      output += '$sec sec${inSeconds > 1 ? 's' : ''}';
    }
    return output.isNotEmpty ? output : '0:00:00';
  }
}
