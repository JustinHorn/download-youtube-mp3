import 'dart:io';

import 'package:audio_manager/audio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile/database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'models/video_info.dart';
import 'music_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  FlutterDownloader.registerCallback(downloadCallback);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage('Music Player'),
    );
  }
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  print(
      'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
}

class HomePage extends HookWidget {
  final String title;

  HomePage(this.title);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    final inputText = useState("");

    final videoInfos = useState<List<VideoInfo>>([]);

    useEffect(() {
      AudioManager.instance.onEvents((events, args) {
        print("$events, $args");
      });
      () async {
        videoInfos.value = await DatabaseHelper.getVideoInfos();
      }();
      return () => {};
    }, []);

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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: videoInfos.value
                    .map((info) => MusicTile(
                          videoInfo: info,
                          onPlay: () => loadSongByTaskId(info.taskId),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await AudioManager.instance.playOrPause();
              print('played');
            },
            tooltip: 'play',
            child: Icon(AudioManager.instance.isPlaying
                ? Icons.pause
                : Icons.play_arrow),
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
  }

  loadSongByTaskId(taskId) async {
    var tasks = await FlutterDownloader.loadTasks();
    var task = tasks.firstWhere((element) => element.taskId == taskId);

    final path = join(task.savedDir, task.filename);
    AudioManager.instance.stop();

    AudioManager.instance.start("file://" + path, 'Ching Chang Chong');
  }

  download(String videoId) async {
    if (await DatabaseHelper.doesCodeAlreadyExist(videoId))
      throw Exception('Video with Code has already been downloaded!');
    var data;

    try {
      var response = await Dio().get("http://localhost:3000/info/$videoId");
      data = response.data;
    } catch (e) {
      print(e);
      return;
    }

    var localPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        'Download';
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
    var videoInfo = VideoInfo.fromJSON(data);
    await DatabaseHelper.insertVideoInfo(videoInfo);
  }
}
