import 'dart:io';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

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
      home: TestWidget('Music Player'),
    );
  }
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  print(
      'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
}

class TestWidget extends HookWidget {
  final String title;

  TestWidget(this.title);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);

    final donwload = () async {
      var localPath = (await getApplicationDocumentsDirectory()).path +
          Platform.pathSeparator +
          'Download';
      final savedDir = Directory(localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        await savedDir.create();
      }

      var taskId = await FlutterDownloader.enqueue(
        url: 'http://localhost:3000/parseVideo/32si5cfrCNc',
        savedDir: localPath,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );

      final tasks = await FlutterDownloader.loadTasks();
      await FlutterDownloader.open(taskId: taskId);
      print(tasks.toString());
    };

    final open = () async {
      FlutterDownloader.open(
          taskId: "com.example.mobile.download.background.1621179136.349398.1");
      // final tasks = await FlutterDownloader.loadTasks();
    };

    useEffect(() {
      AudioManager.instance.onEvents((events, args) {
        print("$events, $args");
      });
      return () => {};
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${counter.value}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              open();
              print('opneing');
            },
            tooltip: 'open',
            child: Icon(Icons.open_in_browser),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              await AudioManager.instance.playOrPause();
              print('played');
            },
            tooltip: 'play',
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final tasks = await FlutterDownloader.loadTasks();
              final first = tasks.first;
              tasks.forEach((element) {
                print(element.filename);
              });
              final path =
                  first.savedDir + Platform.pathSeparator + first.filename;

              print(await File(path).exists());
              print(path);
              print("______");
              AudioManager.instance
                  .start("file://" + path, 'Ching Chang Chong')
                  .then((err) {
                print(err);
              });
            },
            tooltip: 'Start',
            child: Icon(Icons.star),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              donwload();
            },
            tooltip: 'Increment',
            child: Icon(Icons.file_download),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
