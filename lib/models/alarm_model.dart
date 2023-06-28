import 'package:flutter/material.dart';

class AlarmModel {
  int id;
  TimeOfDay alarmTime;
  String repeats;
  String title;
  bool isActive;

  AlarmModel({
    required this.id,
    required this.alarmTime,
    required this.isActive,
    required this.title,
    required this.repeats,
  });
}
