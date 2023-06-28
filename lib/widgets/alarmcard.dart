import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/db_model.dart';

import 'package:high_quality_clock/theme/color_pallet.dart';
import 'package:high_quality_clock/widgets/alarm_selector.dart';
import 'package:scheduled_timer/scheduled_timer.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import '../models/alarm_model.dart';
import '../models/date_formatter.dart';

class AlarmCard extends StatefulWidget {
  final int index;
  final AlarmModel data;
  final Function delete;
  final Function update;
  const AlarmCard(
      {super.key,
      required this.data,
      required this.delete,
      required this.update,
      required this.index});

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard> {
  late AlarmModel data;
  late ScheduledTimer scheduledTimer;
  final _winNotifyPluginAlarms = WindowsNotification(
    applicationId: "Alarm",
  );

  @override
  void initState() {
    super.initState();
    data = widget.data;
    setSchedule(data);
    //Window Notification
    _winNotifyPluginAlarms
        .initNotificationCallBack((notification, status, argruments) {
      if (kDebugMode) {
        print("aargs: $argruments");
      }
      if (argruments == "dismiss") {
        _winNotifyPluginAlarms.removeNotificationId("alarm1", "alarms");
        setState(() {
          data.isActive = false;
        });
      }
    });
  }

  // ?Notification template
  sendToastMessage() {
    String template = '''
<?xml version="1.0" encoding="utf-8"?>
<toast launch="reminderLaunchArg" scenario="reminder" activationType="protocol" useButtonStyle="true">
  <audio src="ms-winsoundevent:Notification.Reminder" loop="true"/>
  <visual>
    <binding template="ToastGeneric">
      <text>${data.title}</text>
      <text style="font-style: italic">${data.alarmTime.hour}:${data.alarmTime.minute}</text>
    </binding>
  </visual>

  <actions>
    <input id="idSnoozeTime" type="selection" defaultInput="5">
      <selection id="1" content="1 minute" />
      <selection id="5" content="5 minutes" />
      <selection id="15" content="15 minutes" />
      <selection id="60" content="1 hour" />
      <selection id="120" content="2 hours" />
    </input>
    <action activationType="system" arguments="snooze" hint-inputId="idSnoozeTime" content="" />
    <action activationType="system" arguments="dismiss" content="" hint-buttonStyle="Critical"/>
  </actions>

</toast>
''';

    NotificationMessage message =
        NotificationMessage.fromCustomTemplate("alarm1", group: "alarmsC");
    _winNotifyPluginAlarms.showNotificationCustomTemplate(message, template);
  }

  //?alarm schedule
  setSchedule(AlarmModel value) {
    DateTime now = DateTime.now();
    scheduledTimer = ScheduledTimer(
      id: value.id.toString(),
      defaultScheduledTime: DateTime(
        now.year,
        now.month,
        now.day,
        value.alarmTime.hour,
        value.alarmTime.minute,
      ),
      onExecute: () {
        final dayname = getDayName(DateTime.now().weekday);
        if (value.repeats == dayname ||
            value.repeats == "روز" && data.isActive) {
          sendToastMessage();
        }
      },
      onMissedSchedule: () {
        int nowInMinutes = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
        int alarmInMinutes = value.alarmTime.hour * 60 + value.alarmTime.minute;
        if (value.isActive && nowInMinutes > alarmInMinutes) {
          // setState(() {
          //   data.isActive = false;
          // });

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Center(
          //       child: RichText(
          //         textDirection: TextDirection.rtl,
          //         text: TextSpan(
          //           style: const TextStyle(
          //             fontSize: 20,
          //           ),
          //           children: <TextSpan>[
          //             const TextSpan(
          //               text: "شما هشدار ",
          //             ),
          //             TextSpan(
          //               text: value.title,
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 decorationStyle: TextDecorationStyle.solid,
          //                 decoration: TextDecoration.underline,
          //                 decorationThickness: 2,
          //                 decorationColor: ColorsPallet().orenge,
          //               ),
          //             ),
          //             const TextSpan(
          //               text: " را از دست دادید ",
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // );
        }
      },
    );
  }

  getDayName(int dayNumber) {
    String dayname;
    switch (dayNumber) {
      case 1:
        dayname = "دو شنبه";
        break;
      case 2:
        dayname = "سه شنبه";
        break;
      case 3:
        dayname = "چهار شنبه";
        break;
      case 4:
        dayname = "پنج شنبه";
        break;
      case 5:
        dayname = "جمعه";
        break;
      case 6:
        dayname = "شنبه";
        break;
      case 7:
        dayname = "یکشنبه";
        break;
      default:
        dayname = "";
    }
    return dayname;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 170,
        child: Container(
          decoration: data.isActive
              ? BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsPallet().tuftsBlue,
                      blurRadius: 5,
                      spreadRadius: 0,
                    )
                  ],
                )
              : null,
          child: Card(
            color: ColorsPallet().ghostWhite_3,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  //alarm time and active/deactiv
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          //Time
                          Text(
                            DateFormater(data.alarmTime).getTime(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          //title
                          Text(
                            widget.data.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: data.isActive
                                  ? ColorsPallet().tuftsBlue
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          //Date
                          Text(
                            "هر ${data.repeats}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: "Tahoma",
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        activeColor: ColorsPallet().tuftsBlue,
                        value: data.isActive,
                        onChanged: (value) {
                          setState(() {
                            data.isActive = value;
                          });

                          DbModel().updateAlarm(data);
                        },
                      )
                    ],
                  ),
                  //action buttons

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //delete
                      IconButton(
                        onPressed: () {
                          // delete from ui
                          widget.delete(data, widget.index);
                          DbModel().deleteAlarm(data.id);
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 10),
                      //update
                      IconButton(
                        onPressed: () {
                          // update the ui
                          showDialog(
                            barrierColor:
                                ColorsPallet().richBlack.withOpacity(0.9),
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.transparent,
                              content: AlarmSelector(
                                isAddingAlarm: false,
                                alarmModel: data,
                              ),
                            ),
                          ).then((value) {
                            if (value != null) {
                              scheduledTimer.stop();
                              scheduledTimer.schedule(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  value.alarmTime.hour,
                                  value.alarmTime.minute,
                                ),
                              );
                              scheduledTimer.start();
                              widget.update(value, widget.index);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.update,
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
