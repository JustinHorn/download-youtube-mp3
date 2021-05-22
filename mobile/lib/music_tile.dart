import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mobile/models/video_info.dart';

class MusicTile extends StatelessWidget {
  final VideoInfo videoInfo;
  final Function onPlay;
  final Function onDelete;

  const MusicTile({Key key, this.videoInfo, this.onPlay, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(8.0),
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              videoInfo.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
