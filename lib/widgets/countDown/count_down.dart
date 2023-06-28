import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/timer_model.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import '../../theme/color_pallet.dart';

import 'custom_timer_counter.dart';

class CountDown extends StatefulWidget {
  final TimerClass timerData;
  final Function remove;
  // final int index;

  const CountDown({
    super.key,
    required this.remove,
    required this.timerData,
    //required this.index,
  });

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown>
    with SingleTickerProviderStateMixin {
  //

  late CustomTimerController _timerController;

  bool isPaused = false;
  //
  final _winNotifyPlugin = WindowsNotification(
    applicationId: "Timer",
  );

  @override
  void initState() {
    super.initState();
    //Window Notification
    _winNotifyPlugin
        .initNotificationCallBack((notification, status, argruments) {
      if (kDebugMode) {
        print("aargs: $argruments");
      }
      if (argruments == "dismiss") {
        _winNotifyPlugin.removeNotificationId("timer1", "timers");
      }
    });
    if (kDebugMode) {
      //print(widget.timerData.duration);
    }
    //Timer

    _timerController = CustomTimerController(
      vsync: this,
      begin: widget.timerData.duration,
      end: const Duration(),
      initialState: CustomTimerState.reset,
      interval: CustomTimerInterval.milliseconds,
    );
    _timerController.start();
    _timerController.state.addListener(() {
      //=======ondone event===============
      //reset the pause/play button
      setState(() {
        isPaused = true;
      });
      // make a notification
      // When Timer finished
      if (_timerController.state.value.index == 3) {
        _timerController.reset();
        sendMyOwnTemplate();
      }
    });
  }

  // ?Notification template
  sendMyOwnTemplate() {
    String template = '''
<?xml version="1.0" encoding="utf-8"?>
<toast launch="reminderLaunchArg" scenario="reminder" activationType="protocol" useButtonStyle="true">
  <audio src="ms-winsoundevent:Notification.Reminder" loop="true"/>
  <visual>
    <binding template="ToastGeneric">
      <text>${widget.timerData.title}</text>
      <text>Timer Done</text>
    </binding>
  </visual>

  <actions>
    <action activationType="system" arguments="dismiss" content="" hint-buttonStyle="Critical"/>
  </actions>
</toast>
''';

    NotificationMessage message =
        NotificationMessage.fromCustomTemplate("timer1", group: "timers");
    _winNotifyPlugin.showNotificationCustomTemplate(message, template);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight / 3,
      width: screenwidth / 3,
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
            blurRadius: 50,
            spreadRadius: 50,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                widget.timerData.title,
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: 20,
                ),
              ),
            ),
            //Counter
            customTimeCounter(_timerController),
            // =========action buttons================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //==reset
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        ColorsPallet().yaleBlue),
                  ),
                  onPressed: () {
                    _timerController.reset();
                  },
                  child: const Icon(Icons.restore),
                ),
                const SizedBox(width: 20),
                //==pause/play
                isPaused
                    ? ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              ColorsPallet().yaleBlue),
                        ),
                        onPressed: () {
                          _timerController.start();
                          setState(() {
                            isPaused = false;
                          });
                        },
                        child: const Icon(Icons.play_arrow),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              ColorsPallet().yaleBlue),
                        ),
                        onPressed: () {
                          _timerController.pause();
                          setState(() {
                            isPaused = true;
                          });
                        },
                        child: const Icon(Icons.pause),
                      ),
                //delete
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        ColorsPallet().orenge.withOpacity(0.5)),
                  ),
                  onPressed: () {
                    widget.remove();
                  },
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
