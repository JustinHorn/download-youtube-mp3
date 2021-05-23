import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // Now we're ready to play
    print(params);
    try {
      var r =
          await _audioPlayer.play('file://' + params['path'], isLocal: true);
      _audioPlayer.seek(Duration(seconds: 0));
      print(r);
    } catch (e) {
      print(e);
    } finally {
      AudioServiceBackground.setState(
          controls: [MediaControl.pause, MediaControl.stop],
          playing: true,
          processingState: AudioProcessingState.connecting);
    }
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.ready);
    await _audioPlayer.resume();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
    await _audioPlayer.pause();
  }

  @override
  Future<void> onStop() async {
    // Stop playing audio
    await _audioPlayer.stop();
    await AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped);
    // Shut down this background task
    await super.onStop();
  }
}
