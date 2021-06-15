import 'package:flutter/material.dart';

import 'face_detector_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Hello...'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startDriving,
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text('Start Driving'),
        icon: const Icon(Icons.directions_car),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startDriving() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const FaceDetectorScreen()));
  }
}
