import 'dart:io';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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

    final downloads = useState<List<DownloadTask>>([]);

    useEffect(() {
      AudioManager.instance.onEvents((events, args) {
        print("$events, $args");
      });
      () async {
        var tasks = await FlutterDownloader.loadTasks();
        downloads.value = tasks;
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
                children: downloads.value
                    .map((dT) => MusicTile(
                          downloadTask: dT,
                          onPlay: () => loadSongByFileName(dT.filename),
                          onDelete: () async {
                            await deleteTask(dT.taskId);
                            downloads.value =
                                await FlutterDownloader.loadTasks();
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
              downloads.value = await FlutterDownloader.loadTasks();
            },
            tooltip: 'Increment',
            child: Icon(Icons.repeat),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  loadSongByFileName(fileName) async {
    var localPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        'Download';
    final path = localPath + Platform.pathSeparator + fileName;
    AudioManager.instance.stop();

    AudioManager.instance.start("file://" + path, 'Ching Chang Chong');
  }

  deleteTask(taskId) async {
    var tasks = await FlutterDownloader.loadTasks();
    FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
  }

  download(String videoId) async {
    var localPath = (await getApplicationDocumentsDirectory()).path +
        Platform.pathSeparator +
        'Download';
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }

    var taskId = await FlutterDownloader.enqueue(
      url: 'http://localhost:3000/parseVideo/' + videoId,
      fileName: videoId + ".mp3",
      savedDir: localPath,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );

    final tasks = await FlutterDownloader.loadTasks();
    await FlutterDownloader.open(taskId: taskId);
    print(tasks.toString());
  }
}
