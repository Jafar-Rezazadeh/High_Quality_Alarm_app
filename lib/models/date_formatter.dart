import 'package:flutter/material.dart';

class DateFormater {
  TimeOfDay dateTime;

  DateFormater(this.dateTime);

  getTime() {
    final d = dateTime;

    String jm = "";
    if (d.hour < 12) {
      jm = "ق.ظ";
    } else {
      jm = "ب.ظ";
    }
    if (d.hour.toString().length == 1 && d.minute.toString().length == 1) {
      return "0${d.hour}:0${d.minute} $jm";
    } else if (d.hour.toString().length == 1) {
      return "0${d.hour}:${d.minute} $jm";
    } else if (d.minute.toString().length == 1) {
      return "${d.hour}:0${d.minute} $jm";
    } else {
      return "${d.hour}:${d.minute} $jm";
    }
  }
}
