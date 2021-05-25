import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobile/models/video_info.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // Now we're ready to play
    try {
      print("hi how are you?");
      var videoInfo = VideoInfo.fromMap(params);

      await AudioServiceBackground.setMediaItem(
        MediaItem(
          id: videoInfo.code,
          album: '',
          title: videoInfo.title,
        ),
      );
      var r =
          await _audioPlayer.play('file://' + params['path'], isLocal: true);
      _audioPlayer.seek(Duration(seconds: 0));

      await AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        position: Duration.zero,
        playing: true,
        processingState: AudioProcessingState.ready,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> onPlay() async {
    try {
      await _audioPlayer.resume();

      AudioServiceBackground.setState(
          controls: [MediaControl.pause, MediaControl.stop],
          position:
              Duration(milliseconds: await _audioPlayer.getCurrentPosition()),
          playing: true,
          processingState: AudioProcessingState.ready);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    await _audioPlayer.seek(position);
    await _audioPlayer.resume();
    await AudioServiceBackground.setState(position: position);
  }

  @override
  Future<void> onPause() async {
    try {
      AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready,
      );
      await _audioPlayer.pause();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> onStop() async {
    // Stop playing audio
    await _audioPlayer.stop();
    await AudioServiceBackground.setState(
      controls: [],
      playing: false,
      processingState: AudioProcessingState.stopped,
    );
    // Shut down this background task
    await super.onStop();
  }
}
