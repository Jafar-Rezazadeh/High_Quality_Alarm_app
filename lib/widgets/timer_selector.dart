import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/db_model.dart';
import 'package:number_selection/number_selection.dart';

import '../models/timer_model.dart';
import '../theme/color_pallet.dart';

class TimerSelector extends StatefulWidget {
  const TimerSelector({
    super.key,
  });

  @override
  State<TimerSelector> createState() => _TimerSelectorState();
}

class _TimerSelectorState extends State<TimerSelector> {
  String title = "";
  int hourValue = 0;
  int minuteValue = 0;
  int secondValue = 0;
  final TextEditingController _textEditingController = TextEditingController();
  //
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 320,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            controller: _textEditingController,
            onChanged: (value) => setState(() => title = value),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            autofocus: true,
            maxLength: 18,
            decoration: InputDecoration(
              counterStyle: TextStyle(color: ColorsPallet().ghostWhite),
              border: const UnderlineInputBorder(),
              hintText: "عنوان",
              hintStyle: TextStyle(
                color: ColorsPallet().ghostWhite_2,
                fontSize: 20,
              ),
            ),
            style: TextStyle(
              color: ColorsPallet().ghostWhite,
              fontSize: 20,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Hour
              SizedBox(
                height: 100,
                child: NumberSelection(
                  theme: NumberSelectionTheme(
                    backgroundColor: ColorsPallet().yaleBlue,
                    draggableCircleColor:
                        ColorsPallet().tuftsBlue.withOpacity(0.5),
                    numberColor: ColorsPallet().ghostWhite,
                    iconsColor: Colors.white,
                  ),
                  minValue: 0,
                  maxValue: 23,
                  direction: Axis.vertical,
                  onChanged: (value) => setState(() => hourValue = value),
                ),
              ),
              const SizedBox(
                width: 20,
                child: Center(
                  child: Text(
                    ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              //minute
              SizedBox(
                height: 100,
                child: NumberSelection(
                  theme: NumberSelectionTheme(
                    backgroundColor: ColorsPallet().yaleBlue,
                    draggableCircleColor:
                        ColorsPallet().tuftsBlue.withOpacity(0.5),
                    numberColor: ColorsPallet().ghostWhite,
                    iconsColor: Colors.white,
                  ),
                  minValue: 0,
                  maxValue: 59,
                  direction: Axis.vertical,
                  onChanged: (value) => setState(() => minuteValue = value),
                ),
              ),
              const SizedBox(
                width: 20,
                child: Center(
                  child: Text(
                    ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              //second
              SizedBox(
                height: 100,
                child: NumberSelection(
                  theme: NumberSelectionTheme(
                    backgroundColor: ColorsPallet().yaleBlue,
                    draggableCircleColor:
                        ColorsPallet().tuftsBlue.withOpacity(0.5),
                    numberColor: ColorsPallet().ghostWhite,
                    iconsColor: Colors.white,
                  ),
                  minValue: 0,
                  maxValue: 59,
                  direction: Axis.vertical,
                  onChanged: (value) => setState(() => secondValue = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // submit/cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //submit
              ElevatedButton(
                onPressed: () async {
                  TimerClass tm = TimerClass(
                    title: title,
                    duration: Duration(
                        hours: hourValue,
                        minutes: minuteValue,
                        seconds: secondValue),
                  );
                  // insert in to db
                  int id = await DbModel().insertToTimer(tm);
                  tm.id = id;
                  if (context.mounted) {
                    Navigator.of(context).pop(tm);
                  }
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorsPallet().ghostWhite,
                  ),
                ),
              ),
              //cancel
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "cancel",
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
