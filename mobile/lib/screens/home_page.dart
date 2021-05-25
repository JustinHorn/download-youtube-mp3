import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile/database.dart';
import 'package:mobile/models/video_info.dart';
import 'package:mobile/music_tile.dart';
import 'package:path_provider/path_provider.dart';

import 'audioplayer_page.dart';

class HomePage extends HookWidget {
  final String title;

  HomePage(this.title);

  @override
  Widget build(BuildContext context) {
    final inputText = useState("");

    final videoInfos = useState<List<VideoInfo>>([]);
    final audioplayer = useState<AudioPlayer>(AudioPlayer());

    useEffect(() {
      audioplayer.value.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
      });
      audioplayer.value.onPlayerError.listen((error) {
        print(error);
      });

      () async {
        videoInfos.value = await DatabaseHelper.getVideoInfos();
      }();
      return () => {};
    }, []);
    return StreamBuilder<PlaybackState>(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;
        final hasSound =
            snapshot.data?.processingState == AudioProcessingState.ready ??
                false;
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(
            child: Container(
              height: double.infinity,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          decoration:
                              InputDecoration(hintText: "Enter Video Code"),
                          onChanged: (t) => inputText.value = t,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () => download(inputText.value),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: videoInfos.value
                        .map((info) => MusicTile(
                              videoInfo: info,
                              onPlay: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AudioPlayerScreen(info),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await FlutterDownloader.remove(
                                    taskId: info.taskId,
                                    shouldDeleteContent: true);
                                await DatabaseHelper.deleteVideoInfo(info.code);
                                videoInfos.value =
                                    await DatabaseHelper.getVideoInfos();
                              },
                            ))
                        .toList(),
                  ),
                  SizedBox(
                    height: 0,
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasSound)
                FloatingActionButton(
                  onPressed: () async {
                    await audioplayer.value.pause();
                  },
                  tooltip: 'play',
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () async {
                  videoInfos.value = await DatabaseHelper.getVideoInfos();
                },
                tooltip: 'Increment',
                child: Icon(Icons.repeat),
              ),
            ],
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }

  download(String videoId) async {
    if (await DatabaseHelper.doesCodeAlreadyExist(videoId)) {
      var fileData = await DatabaseHelper.getVideoInfo(videoId);

      var tasks = await FlutterDownloader.loadTasks();
      var task =
          tasks.firstWhere((element) => element.taskId == fileData.taskId);
      if (task.status == DownloadTaskStatus.failed) {
        var info = fileData.toMap();

        info['taskId'] = await FlutterDownloader.retry(taskId: task.taskId);
        await DatabaseHelper.updateVideoInfo(VideoInfo.fromMap(info));
      } else {
        throw Exception('Video with Code has already been downloaded!');
      }
      return;
    }
    var data;

    try {
      var response = await Dio().get("---/info/$videoId");
      data = response.data;
    } catch (e) {
      print(e);
      return;
    }

    var localPath = Platform.isIOS
        ? (await getApplicationDocumentsDirectory()).path +
            Platform.pathSeparator +
            'Download'
        : (await getApplicationDocumentsDirectory()).path;
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }

    var taskId = await FlutterDownloader.enqueue(
      url: data['audioURL'],
      fileName: videoId + ".mp3",
      savedDir: localPath,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );

    data['taskId'] = taskId;
    var videoInfo = VideoInfo.fromMap(data);
    await DatabaseHelper.insertVideoInfo(videoInfo);
  }
}
