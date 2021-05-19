import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class MusicTile extends StatelessWidget {
  final DownloadTask downloadTask;
  final Function onPlay;
  final Function onDelete;

  const MusicTile({Key key, this.downloadTask, this.onPlay, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(8.0),
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Music Name'),
          Text(downloadTask.filename),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: onPlay,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
