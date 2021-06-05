import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile/database.dart';
import 'package:mobile/models/video_info.dart';
import 'package:mobile/music_tile.dart';
import 'package:path_provider/path_provider.dart';

import '../get_video_info.dart';
import 'audioplayer_page.dart';

class HomePage extends HookWidget {
  final String title;

  HomePage(this.title);

  ReceivePort _port = ReceivePort();

  @override
  Widget build(BuildContext context) {
    final inputText = useState("");

    final videoInfos = useState<List<VideoInfo>>([]);
    final audioplayer = useState<AudioPlayer>(AudioPlayer());

    final progress = useState(0.0);
    final status = useState<DownloadTaskStatus>(DownloadTaskStatus.undefined);

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
      _bindBackgroundIsolate(progress, status);
      return () {
        _unbindBackgroundIsolate();
      };
    }, []);

    useEffect(() {
      () async {
        if (progress.value == 100.0 &&
            status.value == DownloadTaskStatus.complete) {
          videoInfos.value = await DatabaseHelper.getVideoInfos();
        }
      }();
      return () {};
    }, [progress.value, status.value]);

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
                      decoration: InputDecoration(hintText: "Enter Video Code"),
                      onChanged: (t) => inputText.value = t,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () => download(inputText.value),
                  )
                ],
              ),
              Text(progress.value.toString()),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: videoInfos.value
                    .map((info) => MusicTile(
                          videoInfo: info,
                          onPlay: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioPlayerScreen(info),
                              ),
                            );
                          },
                          onDelete: () async {
                            await FlutterDownloader.remove(
                                taskId: info.taskId, shouldDeleteContent: true);
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
    );
  }

  void _bindBackgroundIsolate(progress, status) {
    print('binding');
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate(progress, status);
      return;
    }

    print('success!');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus _status = data[1];
      int _progress = data[2];

      status.value = _status ?? DownloadTaskStatus.undefined;
      progress.value = _progress.toDouble() ?? 0.0;
      print('progress $_progress');
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
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
      data = await getVideoInfo(videoId);
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
