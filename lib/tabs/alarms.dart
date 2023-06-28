import 'package:flutter/material.dart';

import 'package:high_quality_clock/models/db_model.dart';

import 'package:high_quality_clock/widgets/alarm_selector.dart';

import '../models/alarm_model.dart';
import '../theme/color_pallet.dart';
import '../widgets/alarmcard.dart';

class Alarms extends StatefulWidget {
  const Alarms({super.key});

  @override
  State<Alarms> createState() => _AlarmsState();
}

class _AlarmsState extends State<Alarms> with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

  DbModel db = DbModel();
  List<AlarmModel> alarms = [];

  // **
  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    alarms = await db.getData();
  }

  //
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        color: ColorsPallet().richBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                "برای اضافه کردن هشدار کلیک کنید",
                style: TextStyle(color: Colors.white),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  barrierColor: ColorsPallet().richBlack.withOpacity(0.9),
                  context: context,
                  builder: (context) => const AlertDialog(
                    backgroundColor: Colors.transparent,
                    content: AlarmSelector(isAddingAlarm: true),
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      addAlarm(
                        value,
                      );
                    });
                  }
                });
              },
              backgroundColor: ColorsPallet().tuftsBlue,
              foregroundColor: ColorsPallet().yaleBlue,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          right: screenwidth / 7,
          left: screenwidth / 7,
          top: 20,
          bottom: 120,
        ),
        child: FutureBuilder(
          future: db.getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isNotEmpty) {
                return AnimatedList(
                  key: _animatedListKey,
                  scrollDirection: Axis.vertical,
                  initialItemCount: alarms.isNotEmpty ? alarms.length : 0,
                  itemBuilder: (context, index, animation) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AlarmCard(
                      index: index,
                      data: alarms[index],
                      delete: deleteAlarm,
                      update: updateAlarm,
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    ".هنوز هشدار ایجاد نشده است",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  //Adding to list
  void addAlarm(AlarmModel am) {
    alarms.add(am);
    _animatedListKey.currentState?.insertItem(0);
  }

  //update
  Future<void> updateAlarm(AlarmModel am, int index) async {
    setState(() {
      alarms[index] = am;
    });
    DbModel().updateAlarm(am);
  }

  //Delete alarms
  void deleteAlarm(AlarmModel am, int index) {
    alarms.removeWhere((element) => element.id == am.id);

    _animatedListKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsPallet().orenge,
                      blurRadius: 5,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Card(
                  color: ColorsPallet().ghostWhite_3,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
