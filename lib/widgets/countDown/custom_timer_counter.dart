import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';

import '../../theme/color_pallet.dart';

double fontsize = 25;
Widget customTimeCounter(timerController) {
  return CustomTimer(
    controller: timerController,
    builder: (state, time) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //hour
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorsPallet().yaleBlue,
              boxShadow: [
                BoxShadow(
                  color: ColorsPallet().yaleBlue,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                time.hours,
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: fontsize,
                ),
              ),
            ),
          ),
          //
          Container(
            height: 50,
            width: 20,
            margin: const EdgeInsets.only(bottom: 5),
            child: Center(
              child: Text(":",
                  style: TextStyle(
                    color: ColorsPallet().ghostWhite,
                    fontSize: 20,
                  )),
            ),
          ),
          //minutes
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorsPallet().yaleBlue,
              boxShadow: [
                BoxShadow(
                  color: ColorsPallet().yaleBlue,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                time.minutes,
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: fontsize,
                ),
              ),
            ),
          ),
          //
          Container(
            height: 50,
            width: 20,
            margin: const EdgeInsets.only(bottom: 5),
            child: Center(
              child: Text(":",
                  style: TextStyle(
                    color: ColorsPallet().ghostWhite,
                    fontSize: 20,
                  )),
            ),
          ),
          //secounds
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorsPallet().yaleBlue,
              boxShadow: [
                BoxShadow(
                  color: ColorsPallet().yaleBlue,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                time.seconds,
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: fontsize,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
