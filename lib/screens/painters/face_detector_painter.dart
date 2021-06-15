import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces, this.imageSize, this.rotation, this.screenSize);

  final List<Face> faces;
  final Size imageSize;
  final Size screenSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;

    for (final Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, screenSize, imageSize),
          translateY(face.boundingBox.top, rotation, screenSize, imageSize),
          translateX(face.boundingBox.right, rotation, screenSize, imageSize),
          translateY(face.boundingBox.bottom, rotation, screenSize, imageSize),
        ),
        paint,
      );

      void paintContour(FaceContourType type) {
        final faceContour = face.getContour(type);
        if (faceContour?.positionsList != null) {
          for (Offset point in faceContour!.positionsList) {
            canvas.drawCircle(
                Offset(
                  translateX(point.dx, rotation, screenSize, imageSize),
                  translateY(point.dy, rotation, screenSize, imageSize),
                ),
                1,
                paint);
          }
        }
      }

      paintContour(FaceContourType.face);
      paintContour(FaceContourType.leftEyebrowTop);
      paintContour(FaceContourType.leftEyebrowBottom);
      paintContour(FaceContourType.rightEyebrowTop);
      paintContour(FaceContourType.rightEyebrowBottom);
      paintContour(FaceContourType.leftEye);
      paintContour(FaceContourType.rightEye);
      paintContour(FaceContourType.upperLipTop);
      paintContour(FaceContourType.upperLipBottom);
      paintContour(FaceContourType.lowerLipTop);
      paintContour(FaceContourType.lowerLipBottom);
      paintContour(FaceContourType.noseBridge);
      paintContour(FaceContourType.noseBottom);
      paintContour(FaceContourType.leftCheek);
      paintContour(FaceContourType.rightCheek);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}

double translateX(
    double x, InputImageRotation rotation, Size screenSize, Size imageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_0deg:
    case InputImageRotation.Rotation_180deg:
      return (imageSize.width - x) * screenSize.height / imageSize.height;
    case InputImageRotation.Rotation_90deg:
      if (screenSize.height > screenSize.width) {
        return x * screenSize.width / imageSize.width;
      } else {
        return x * screenSize.height / imageSize.height;
      }
    case InputImageRotation.Rotation_270deg:
      return screenSize.width - x * screenSize.width / imageSize.height;
    default:
      return x;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size screenSize, Size imageSize) {
  switch (rotation) {
    case InputImageRotation.Rotation_90deg:
      if (screenSize.height > screenSize.width) {
        return y * screenSize.width / imageSize.width;
      } else {
        return y * screenSize.height / imageSize.height;
      }
    case InputImageRotation.Rotation_270deg:
      return y * screenSize.width / imageSize.height;
    default:
      return y * screenSize.height / imageSize.height;
  }
}
