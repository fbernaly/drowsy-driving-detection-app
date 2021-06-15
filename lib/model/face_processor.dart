import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:just_audio/just_audio.dart';

class FaceProcessor {
  late final AudioPlayer playerLevel1;
  late final AudioPlayer playerLevel2;
  late final AudioPlayer playerLevel3;
  var _busy = false;
  DateTime? _date;

  FaceProcessor() {
    playerLevel1 = AudioPlayer();
    playerLevel1.setAsset('assets/audio/error.mp3');
    playerLevel2 = AudioPlayer();
    playerLevel2.setAsset('assets/audio/boing.mp3');
    playerLevel3 = AudioPlayer();
    playerLevel3.setAsset('assets/audio/whistle.mp3');
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
        return;
      } else if (duration < 2500) {
        // Level 1
        player = playerLevel1;
        player.setVolume(10);
      } else if (duration < 5000) {
        // Level 2
        player = playerLevel2;
        player.setVolume(25);
      } else {
        // Level 3
        player = playerLevel3;
        player.setVolume(100);
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
      final duration = DateTime.now().difference(_date!);
      print('event duration: $duration');
      _date = null;
    }
  }
}
