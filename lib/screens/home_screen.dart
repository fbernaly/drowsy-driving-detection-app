import 'package:drowsy_driving_detection_app/model/storage.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';

import 'face_detector_screen.dart';
import '../model/events.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DrivingEvent> _drivings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FocusDetector(
        onFocusGained: _onFocusGained,
        child: Center(child: Text('Drivings: ${_drivings.length}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startDriving,
        backgroundColor: Theme.of(context).primaryColor,
        label: Text('Start Driving'),
        icon: Icon(Icons.directions_car),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startDriving() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const FaceDetectorScreen()));
  }

  void _onFocusGained() async {
    _drivings = await Storage.fetch();
    setState(() {});
  }
}
