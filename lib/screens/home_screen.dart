import 'package:drowsy_driving_detection_app/model/storage.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';

import 'face_detector_screen.dart';
import '../model/events.dart';

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
            ],
          ),
        ),
      ),
    );
  }

  void _startDriving() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const FaceDetectorScreen()));
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
