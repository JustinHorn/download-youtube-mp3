import 'dart:io';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';

void main() {
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

class TestWidget extends HookWidget {
  final String title;

  TestWidget(this.title);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
  final path = await _localPath;
  File('$path/counter.txt').
  return File('$path/counter.txt');
}

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);

    final donwload = () => {};

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
              await AudioManager.instance.playOrPause();
              print('played');
            },
            tooltip: 'play',
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              AudioManager.instance
                  .start('http://localhost:3000/parseVideo/32si5cfrCNc',
                      'Ching Chang Chong')
                  .then((err) {
                print(err);
              });
            },
            tooltip: 'Start',
            child: Icon(Icons.star),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => counter.value++,
            tooltip: 'Increment',
            child: Icon(Icons.file_download),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
