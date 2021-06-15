import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.onImage,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraDescription? _camera;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();

    _loadAvailableCameras();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _controller?.value.isInitialized == false) {
      return Container();
    }
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    var quarterTurns = 0;
    if (Platform.isAndroid && currentOrientation == Orientation.landscape) {
      quarterTurns = 2;
    }
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: CameraPreview(_controller!),
    );
  }

  Future _loadAvailableCameras() async {
    List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw ("There are not cameras available");
    }

    for (final camera in cameras) {
      if (camera.lensDirection == widget.initialDirection) {
        _camera = camera;
      }
    }

    if (_camera == null) {
      throw ("Camera ${widget.initialDirection} is not available");
    }

    _startLiveFeed();
  }

  Future _startLiveFeed() async {
    if (_camera == null) {
      throw ("Camera ${widget.initialDirection} is not available");
    }
    _controller = CameraController(
      _camera!,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    if (_camera == null) {
      return;
    }
    var imageRotation =
        InputImageRotationMethods.fromRawValue(_camera!.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;
    if (Platform.isAndroid && mounted) {
      final orientation = await NativeDeviceOrientationCommunicator()
          .orientation(useSensor: false);
      switch (orientation) {
        case NativeDeviceOrientation.portraitUp:
          imageRotation = InputImageRotation.Rotation_270deg;
          break;
        case NativeDeviceOrientation.landscapeLeft:
          imageRotation = InputImageRotation.Rotation_0deg;
          break;
        case NativeDeviceOrientation.landscapeRight:
          imageRotation = InputImageRotation.Rotation_180deg;
          break;
        default:
          break;
      }
    }

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}
