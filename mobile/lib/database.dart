import 'dart:async';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mobile/models/video_info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> getDataBase() async {
    return await openDatabase(join(await getDatabasesPath(), 'video_info.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE VideoInfo(code TEXT PRIMARY KEY,title TEXT,thumbnail TEXT, seconds INTEGER, audioURL TEXT, taskId TEXT)');
    }, version: 1);
  }

  static Future<void> insertVideoInfo(VideoInfo videoInfo) async {
    final db = await getDataBase();

    await db.insert('VideoInfo', videoInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  static Future<List<VideoInfo>> getVideoInfos() async {
    final db = await DatabaseHelper.getDataBase();

    final data = await db.query('VideoInfo');

    return data.map((d) => VideoInfo.fromJSON(d)).toList();
  }

  static Future<void> deleteVideoInfo(String code) async {
    final db = await DatabaseHelper.getDataBase();

    await db.delete("VideoInfo", where: 'code = ?', whereArgs: [code]);
  }

  static Future<bool> doesCodeAlreadyExist(String code) async {
    var infos = await getVideoInfos();

    return infos.any((element) => element.code == code);
  }
}
