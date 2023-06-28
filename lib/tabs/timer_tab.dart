import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:high_quality_clock/models/db_model.dart';

import 'package:high_quality_clock/theme/color_pallet.dart';
import 'package:high_quality_clock/widgets/countDown/timer_history.dart';

import 'package:high_quality_clock/widgets/timer_selector.dart';

import '../models/timer_model.dart';
import '../widgets/countDown/count_down.dart';
import '../widgets/countDown/custom_timer_counter.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab>
    with AutomaticKeepAliveClientMixin {
  TimerClass? timerData;
  Widget? countdownwidget;
  List<TimerClass> _listTimers = [];

  String txt = "TimerTab";
  bool isThereAlarm = true;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    _listTimers = await DbModel().getDataTimers();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    super.build(context);
    return Scaffold(
      key: _scaffoldkey,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                countdownwidget == null
                    ? ".برای اضافه کردن تایمر کلیک کنید"
                    : "برای اضافه کردن ابتدا تامیر فعال را پاک کنید",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: countdownwidget == null
                  ? () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          backgroundColor: Colors.transparent,
                          content: TimerSelector(),
                        ),
                      ).then(
                        (value) => {
                          if (value != null)
                            {
                              //
                              addTimerHistory(value),
                              // print(value),
                              addTimer(value),
                            },
                        },
                      );
                    }
                  : null,
              backgroundColor: countdownwidget == null
                  ? ColorsPallet().tuftsBlue
                  : ColorsPallet().tuftsBlue.withOpacity(0.5),
              foregroundColor: ColorsPallet().yaleBlue,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 120),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: countdownwidget ?? fakeTimer(),
              ),
            ),
            Container(
              height: screenHeight / 3.5,
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: FutureBuilder(
                future: DbModel().getDataTimers(),
                builder: (context, AsyncSnapshot<List<TimerClass>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    snapshot.data!.map((e) => addTimerHistory(e));
                    return RawScrollbar(
                      controller: _scrollController,
                      thumbColor: ColorsPallet().ghostWhite_2,
                      thickness: 10,
                      thumbVisibility: true,
                      // trackVisibility: true,
                      radius: const Radius.circular(10),
                      trackRadius: const Radius.circular(10),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _listTimers.length,
                        itemBuilder: (context, index) => historyWidget(
                          removeTimerHistory,
                          addTimer,
                          removeTimer,
                          _listTimers[index],
                          countdownwidget == null ? false : true,
                          context,
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(
                      child: Text(
                        "There is some Error",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  addTimer(TimerClass value) {
    setState(() {
      countdownwidget = CountDown(
        timerData: value,
        remove: removeTimer,
      );
    });
  }

  removeTimer() {
    setState(() {
      countdownwidget = null;
    });
  }

  addTimerHistory(TimerClass tm) {
    // print(tm.id.toString() + tm.title);

    _listTimers.add(tm);
  }

  removeTimerHistory(TimerClass tm) async {
    setState(() {
      _listTimers.removeWhere(
        (element) => element.id == tm.id,
      );
    });
    try {
      DbModel().deleteTimer(tm.id!);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Widget fakeTimer() {
    //
    double screenHeight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    //
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "",
              style: TextStyle(
                color: ColorsPallet().ghostWhite,
                fontSize: 20,
              ),
            ),
          ),
          Row(
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
                    "00",
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
                    "00",
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
                    "00",
                    style: TextStyle(
                      color: ColorsPallet().ghostWhite,
                      fontSize: fontsize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //==reset
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(ColorsPallet().yaleBlue),
                ),
                onPressed: null,
                child: const Icon(Icons.restore),
              ),
              const SizedBox(width: 20),
              //==pause/play
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(ColorsPallet().yaleBlue),
                ),
                onPressed: null,
                child: const Icon(Icons.play_arrow),
              ),

              //delete
              const SizedBox(width: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      ColorsPallet().orenge.withOpacity(0.5)),
                ),
                onPressed: null,
                child: const Icon(Icons.clear),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Mixen
  @override
  bool get wantKeepAlive => true;
}
