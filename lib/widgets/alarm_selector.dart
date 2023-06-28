import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/alarm_model.dart';
import 'package:high_quality_clock/models/db_model.dart';

import '../theme/color_pallet.dart';

class AlarmSelector extends StatefulWidget {
  final bool isAddingAlarm;
  final AlarmModel? alarmModel;
  const AlarmSelector({
    super.key,
    required this.isAddingAlarm,
    this.alarmModel,
  });

  @override
  State<AlarmSelector> createState() => _AlarmSelectorState();
}

List<String> list = [
  "روز",
  "شنبه",
  "یکشنبه",
  "دوشنبه",
  "سه شنبه",
  "چهار شنبه",
  "پنج شنبه",
  "جمعه",
];

List<DropdownMenuItem<String>> dropdownList = List.generate(
  list.length,
  (i) => DropdownMenuItem(
    value: list[i],
    child: Text("هر ${list[i]}"),
  ),
);

class _AlarmSelectorState extends State<AlarmSelector> {
  TimeOfDay? time;
  String title = "";
  final TextEditingController _textEditingController = TextEditingController();
  Color timeSelectColor = ColorsPallet().oxfordBlue;
  Color titleBorderColor = ColorsPallet().tuftsBlue;
  String? dropDownValue = dropdownList.first.value;
  //
  @override
  void initState() {
    super.initState();
    widget.alarmModel != null
        ? _textEditingController.text = widget.alarmModel!.title
        : null;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 100),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          widget.isAddingAlarm
              ? Text("اضافه کردن هشدار",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .apply(color: ColorsPallet().ghostWhite_3))
              : Text("بروزرسانی هشدار",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .apply(color: ColorsPallet().ghostWhite_3)),
          // Title
          TextField(
            controller: _textEditingController,
            onChanged: (value) => setState(() {
              title = value;
              titleBorderColor = ColorsPallet().tuftsBlue;
            }),
            textAlign: TextAlign.center,
            maxLength: 18,
            textDirection: TextDirection.rtl,
            cursorColor: ColorsPallet().ghostWhite,
            decoration: InputDecoration(
              counterStyle: const TextStyle(color: Colors.white),
              hintText: "عنوان",
              hintStyle:
                  TextStyle(color: ColorsPallet().ghostWhite.withOpacity(0.8)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: titleBorderColor,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(width: 2, color: ColorsPallet().tuftsBlue),
              ),
            ),
            style: TextStyle(color: ColorsPallet().ghostWhite, fontSize: 18),
          ),
          // Time select
          TextButton(
            style: ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all<Color>(ColorsPallet().tuftsBlue),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(width: 1, color: ColorsPallet().tuftsBlue),
                ),
              ),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(20)),
              backgroundColor: time == null
                  ? MaterialStateProperty.all<Color>(timeSelectColor)
                  : null,
            ),
            onPressed: () async {
              await showTimePicker(
                context: context,
                initialTime: widget.alarmModel != null
                    ? widget.alarmModel!.alarmTime
                    : TimeOfDay.now(),
              ).then((value) => setState(() => time = value));
            },
            child: time != null
                ? Text(
                    "${time!.hour} : ${time!.minute} ${time!.period.name}",
                    style: TextStyle(
                      color: ColorsPallet().ghostWhite,
                      fontSize: 20,
                    ),
                  )
                : Text(
                    style: TextStyle(
                      color: ColorsPallet().ghostWhite,
                      fontSize: 20,
                    ),
                    widget.alarmModel == null
                        ? "انتخاب زمان"
                        : "${widget.alarmModel!.alarmTime.hour} : ${widget.alarmModel!.alarmTime.minute} ${widget.alarmModel!.alarmTime.period.name}",
                  ),
          ),

          // Reapet week
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: DropdownButton(
              value: dropDownValue,
              isExpanded: true,
              alignment: Alignment.center,
              style: TextStyle(color: ColorsPallet().ghostWhite),
              dropdownColor: ColorsPallet().yaleBlue,
              items: dropdownList,
              onChanged: (value) {
                setState(() => dropDownValue = value);
              },
            ),
          ),

          // Submit and Cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // submit
              ElevatedButton(
                onPressed: () async {
                  if (_textEditingController.text != "" &&
                          widget.alarmModel != null ||
                      time != null) {
                    int i;
                    //***** */ update or insert the data to db
                    //insert
                    if (time != null && widget.isAddingAlarm == true) {
                      i = await DbModel()
                          .insertToDb(title, time!, dropDownValue!, true);
                      // send the data to ui
                      if (context.mounted) {
                        Navigator.of(context).pop(
                          AlarmModel(
                            id: i,
                            alarmTime: time!,
                            isActive: true,
                            title: title,
                            repeats: dropDownValue!,
                          ),
                        );
                      }
                    } else if (widget.isAddingAlarm == false) {
                      if (_textEditingController.text == "") {
                        title = widget.alarmModel!.title;
                      }

                      i = await DbModel().updateAlarm(AlarmModel(
                        id: widget.alarmModel!.id,
                        alarmTime: time ?? widget.alarmModel!.alarmTime,
                        isActive: true,
                        title: title == "" ? widget.alarmModel!.title : title,
                        repeats: dropDownValue!,
                      ));

                      // send the data to ui
                      if (context.mounted) {
                        Navigator.of(context).pop(
                          AlarmModel(
                            id: i,
                            alarmTime: time ?? widget.alarmModel!.alarmTime,
                            isActive: true,
                            title:
                                title == "" ? widget.alarmModel!.title : title,
                            repeats: dropDownValue!,
                          ),
                        );
                      }
                    }
                  } else {
                    setState(() {
                      timeSelectColor = ColorsPallet().orenge;
                      if (_textEditingController.text == "") {
                        titleBorderColor = ColorsPallet().orenge;
                      }
                    });
                  }
                },
                child: const Text("ok"),
              ),
              //cancel
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(ColorsPallet().yaleBlue),
                ),
                child: const Text("cancel"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
