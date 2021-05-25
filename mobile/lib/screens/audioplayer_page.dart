import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile/models/video_info.dart';
import 'package:path/path.dart';

import '../audioplayer_backgroundtask.dart';
import '../seekbar.dart';

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerScreen extends HookWidget {
  final VideoInfo videoInfo;

  AudioPlayerScreen(this.videoInfo);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      () async {
        var tasks = await FlutterDownloader.loadTasks();
        var task =
            tasks.firstWhere((element) => element.taskId == videoInfo.taskId);
        print(task);

        final path = join(task.savedDir, task.filename);

        AudioService.start(
          backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
          params: {'path': path, ...videoInfo.toMap()},
        );
      }();
      return () {};
    }, []);

    print('seconds: ${videoInfo.seconds}');

    return Scaffold(
      appBar: AppBar(
        title: Text(videoInfo.title),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(videoInfo.thumbnail),
              StreamBuilder(
                stream: AudioService.positionStream,
                builder: (context, snasphsot) {
                  final position = snasphsot.data ?? Duration.zero;
                  return SeekBar(
                    position: position,
                    duration: Duration(seconds: videoInfo.seconds),
                    onChangeEnd: (value) {
                      AudioService.seekTo(value);
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 0),
                  ElevatedButton(child: Text("Play"), onPressed: play),
                  ElevatedButton(child: Text("Pause"), onPressed: pause),
                  ElevatedButton(
                      child: Text("Stop"), onPressed: () => stop(context)),
                  SizedBox(width: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  play() => AudioService.play();

  pause() => AudioService.pause();

  stop(context) {
    AudioService.stop();
    Navigator.pop(context);
  }
}
