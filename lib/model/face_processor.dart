import 'package:drowsy_driving_detection_app/model/events.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:just_audio/just_audio.dart';

enum DrowsinessLevel { level0, level1, level2, level3 }

class FaceProcessor {
  final Function(DrowsinessLevel level) onDetection;
  final Function(ClosedEyesEvent event) onEventEnded;
  final AudioPlayer playerLevel1 = AudioPlayer();
  final AudioPlayer playerLevel2 = AudioPlayer();
  final AudioPlayer playerLevel3 = AudioPlayer();
  var _busy = false;
  DateTime? _date;
  DrowsinessLevel currentLevel = DrowsinessLevel.level0;

  FaceProcessor({required this.onDetection, required this.onEventEnded}) {
    playerLevel1.setAsset('assets/audio/error.mp3');
    playerLevel2.setAsset('assets/audio/boing.mp3');
    playerLevel3.setAsset('assets/audio/whistle.mp3');
  }

  void dispose() {
    playerLevel1.dispose();
    playerLevel2.dispose();
    playerLevel3.dispose();
  }

  Future processFace(List<Face> faces) async {
    if (faces.isEmpty) {
      _endEvent();
      return;
    }
    final face = faces.first;
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;
    if (leftEyeOpenProbability == null || rightEyeOpenProbability == null) {
      _endEvent();
      return;
    }
    const min = 0.3;
    if (leftEyeOpenProbability < min || rightEyeOpenProbability < min) {
      if (_date == null) {
        _startEvent();
      }

      final duration = DateTime.now().difference(_date!).inMilliseconds;

      var player = playerLevel3;
      if (duration < 500) {
        // Level 0
        _notifyChange(DrowsinessLevel.level0);
        return;
      } else if (duration < 2500) {
        // Level 1
        player = playerLevel1;
        player.setVolume(10);
        _notifyChange(DrowsinessLevel.level1);
      } else if (duration < 5000) {
        // Level 2
        player = playerLevel2;
        player.setVolume(25);
        _notifyChange(DrowsinessLevel.level2);
      } else {
        // Level 3
        player = playerLevel3;
        player.setVolume(100);
        _notifyChange(DrowsinessLevel.level3);
      }

      if (_busy) return;
      _busy = true;

      await player.play();
      await player.stop();

      _busy = false;
    } else {
      _endEvent();
    }
  }

  void _startEvent() {
    _date = DateTime.now();
  }

  void _endEvent() {
    if (_date != null) {
      ClosedEyesEvent? event;
      if (currentLevel != DrowsinessLevel.level0) {
        final duration = DateTime.now().difference(_date!);
        event = ClosedEyesEvent(_date!, duration, currentLevel);
      }
      _date = null;
      _notifyChange(DrowsinessLevel.level0);
      if (event != null) {
        onEventEnded(event);
      }
    }
  }

  void _notifyChange(DrowsinessLevel level) {
    if (currentLevel != level) {
      currentLevel = level;
      onDetection(level);
    }
  }
}
