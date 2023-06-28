import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/timer_model.dart';
import 'package:path/path.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'alarm_model.dart';

class DbModel {
  String tbAlarmsName = 'alarmsTable';
  String tbTimersName = 'timersTable';

  //open Db
  openDb() async {
    String p =
        join(await databaseFactoryFfi.getDatabasesPath(), 'HQTdataBase.db');

    // for delete db for some reasen
    // Future<void> deleteDatabase(String path) =>
    //     databaseFactoryFfi.deleteDatabase(path);
    // deleteDatabase(p);

    final db = await databaseFactoryFfi.openDatabase(
      p,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(''' 
        CREATE TABLE $tbAlarmsName (
          id INTEGER PRIMARY KEY AUTOINCREMENT ,
          title TEXT,
          alarmTime TEXT,
          repeats TEXT,
          isActive INTEGER);

        CREATE TABLE $tbTimersName (
          id INTEGER PRIMARY KEY AUTOINCREMENT ,
          title TEXT,
          duration TEXT); ''');
        },
      ),
    );

    return db;
  }

// ?+++++++++++++++++++++++++++++++ Alarm Table +++++++++++++++++++++++++++++++
  //******insert*********
  insertToDb(
      String title, TimeOfDay alarmTime, String repeats, bool isActive) async {
    final Database db = await openDb();

    int i = await db.insert(
      tbAlarmsName,
      <String, Object?>{
        'title': title,
        'alarmTime': "${alarmTime.hour}:${alarmTime.minute}",
        'repeats': repeats,
        'isActive': isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return i;
  }

  //******Get data*********
  Future<List<AlarmModel>> getData() async {
    //

    try {
      final Database db = await openDb();
      final maps = await db.query(tbAlarmsName, orderBy: 'id DESC');

      return List.generate(
        maps.length,
        (i) => AlarmModel(
          id: int.parse(maps[i]['id'].toString()),
          alarmTime: TimeOfDay(
            hour: int.parse(maps[i]['alarmTime'].toString().split(":")[0]),
            minute: int.parse(maps[i]['alarmTime'].toString().split(":")[1]),
          ),
          isActive: maps[i]['isActive'] == 1 ? true : false,
          title: maps[i]['title'].toString(),
          repeats: maps[i]['repeats'].toString(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("some erro");
      }
      return [];
    }
  }

  //******delete alarm*********
  deleteAlarm(int id) async {
    final Database db = await openDb();

    final result =
        await db.delete(tbAlarmsName, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //******update alarm*********
  updateAlarm(AlarmModel am) async {
    final Database db = await openDb();

    final result = await db.update(
      tbAlarmsName,
      <String, Object?>{
        'id': am.id,
        'title': am.title,
        'alarmTime': "${am.alarmTime.hour}:${am.alarmTime.minute}",
        'repeats': am.repeats,
        'isActive': am.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [am.id],
    );

    return result;
  }

// ?+++++++++++++++++++++++++++++++ Alarm Table END +++++++++++++++++++++++++++++++
//
// ?+++++++++++++++++++++++++++++++ Timer Table +++++++++++++++++++++++++++++++

  //* insert to timer table
  insertToTimer(TimerClass tm) async {
    final Database db = await openDb();

    int id = await db.insert(
      tbTimersName,
      <String, Object>{
        'title': tm.title,
        'duration': tm.duration.inSeconds.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  //* get data from timer table
  Future<List<TimerClass>> getDataTimers() async {
    try {
      final Database db = await openDb();

      final maps = await db.query(tbTimersName);

      return List.generate(
        maps.length,
        (i) => TimerClass(
          id: int.parse(maps[i]['id'].toString()),
          title: maps[i]['title'].toString(),
          duration:
              Duration(seconds: int.parse(maps[i]['duration'].toString())),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("some error in timers table");
      }
      return [];
    }
  }

  //* delete timer from timer table
  deleteTimer(int id) async {
    try {
      final Database db = await openDb();

      await db.delete(tbTimersName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      if (kDebugMode) {
        print("some error in delete timer");
      }
    }
  }
}
