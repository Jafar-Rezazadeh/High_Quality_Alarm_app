import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/timer_model.dart';
import 'package:high_quality_clock/theme/color_pallet.dart';

bool isSnakebarfired = false;

Widget historyWidget(Function removeHistory, Function addTimer,
    Function removeTimer, TimerClass tm, bool isActive, BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
    height: 100,
    width: 150,
    decoration: BoxDecoration(
      color: ColorsPallet().oxfordBlue,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: ColorsPallet().tuftsBlue,
          blurRadius: 10,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: ColorsPallet().tuftsBlue.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 20,
        ),
      ],
    ),
    child: ElevatedButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (isActive) {
            return ColorsPallet().yaleBlue.withOpacity(0.3);
          } else {
            return ColorsPallet().yaleBlue;
          }
        }),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (isActive) {
            return Colors.grey;
          } else {
            return Colors.white;
          }
        }),
      ),
      onPressed: isActive
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: ColorsPallet().orenge.withOpacity(0.4),
                content: const Center(
                  child: Text("لطفا ابتدا تایمر فعال را پاک کنید"),
                ),
              ));
              isSnakebarfired = true;
            }
          : () async {
              await removeTimer();
              addTimer(tm);
            },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tm.title, style: const TextStyle(fontSize: 13)),
            Text(formatToTime(tm.duration),
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            IconButton(
              color: Colors.white,
              hoverColor: ColorsPallet().orenge,
              splashRadius: 20,
              onPressed: () {
                removeHistory(tm);
              },
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    ),
  );
}

formatToTime(Duration duration) {
  String hh = duration.inHours.toString().padLeft(2, '0');
  String mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return "$hh:$mm:$ss";
}
