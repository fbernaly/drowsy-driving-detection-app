import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';

import 'views/camera_view.dart';
import 'painters/face_detector_painter.dart';
import '../model/events.dart';
import '../model/face_processor.dart';
import '../model/location_manager.dart';
import '../model/storage.dart';

class FaceDetectorScreen extends StatefulWidget {
  const FaceDetectorScreen({Key? key}) : super(key: key);

  @override
  _FaceDetectorScreenState createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
  FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));
  bool isBusy = false;
  CustomPaint? customPaint;
  final storage = Storage();
  late final FaceProcessor processor = FaceProcessor(
    onDetection: (level) => setState(() {}),
    onEventEnded: _addClosedEyesEvent,
  );

  @override
  void dispose() {
    faceDetector.close();
    processor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () {
          storage.store();
          Navigator.pop(context);
        },
        label: const Text('Stop Driving'),
        icon: const Icon(Icons.stop),
      ),
    );
  }

  Widget body(BuildContext context) {
    var backgroundColor = Colors.black;
    var showAnimation = false;
    switch (processor.currentLevel) {
      case DrowsinessLevel.level0:
        backgroundColor = Colors.black;
        showAnimation = false;
        break;
      case DrowsinessLevel.level1:
        backgroundColor = Colors.yellow;
        showAnimation = true;
        break;
      case DrowsinessLevel.level2:
        backgroundColor = Colors.orange;
        showAnimation = true;
        break;
      case DrowsinessLevel.level3:
        backgroundColor = Colors.red;
        showAnimation = true;
        break;
    }
    return Container(
      color: backgroundColor,
      child: Center(
        child: Stack(
          children: [
            CameraView(
              onImage: (inputImage) => processImage(inputImage),
              initialDirection: CameraLensDirection.front,
            ),
            if (customPaint != null) customPaint!,
            if (showAnimation) _buzzerAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buzzerAnimation() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.black,
              Colors.transparent,
            ],
          ),
        ),
        child: Lottie.asset(
          'assets/animations/buzzer.json',
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    processor.processFace(faces);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null &&
        mounted) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation,
          MediaQuery.of(context).size);
      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _addClosedEyesEvent(ClosedEyesEvent event) async {
    event.locationData = await LocationManager().getLocation();
    storage.events.add(event);
  }
}
