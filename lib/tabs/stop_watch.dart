import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../theme/color_pallet.dart';

class StopWatchTap extends StatefulWidget {
  const StopWatchTap({super.key});

  @override
  State<StopWatchTap> createState() => _StopWatchTapState();
}

class _StopWatchTapState extends State<StopWatchTap>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final _isHours = true;
  bool isStarted = false;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onEnded: () {},
    onStopped: () {},
  );

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    super.build(context);
    return Center(
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 50,
              horizontal: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /// Display stop watch time
                Container(
                  padding: const EdgeInsets.all(10),
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
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: _stopWatchTimer.rawTime.value,
                    builder: (context, snap) {
                      final value = snap.data!;
                      final displayTime =
                          StopWatchTimer.getDisplayTime(value, hours: _isHours);

                      return Column(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: displayTime.substring(
                                          0, displayTime.length - 3),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 60,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: displayTime
                                          .substring(displayTime.length - 3),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                /// Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //reset
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: IconButton(
                          splashRadius: 30,
                          color: Colors.white,
                          hoverColor: ColorsPallet().tuftsBlue.withOpacity(0.5),
                          onPressed: () {
                            _stopWatchTimer.onResetTimer();
                            setState(() {
                              isStarted = false;
                            });
                          },
                          icon: const Icon(Icons.restart_alt),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // start/stop
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              width: 1,
                              color: ColorsPallet().ghostWhite,
                            ),
                          ),
                          child: IconButton(
                            splashRadius: 30,
                            color: Colors.white,
                            hoverColor:
                                ColorsPallet().tuftsBlue.withOpacity(0.5),
                            onPressed: isStarted
                                ? () {
                                    _stopWatchTimer.onStopTimer();
                                    setState(() {
                                      isStarted = false;
                                    });
                                  }
                                : () {
                                    _stopWatchTimer.onStartTimer();
                                    setState(() {
                                      isStarted = true;
                                    });
                                  },
                            icon: isStarted
                                ? const Icon(Icons.pause)
                                : const Icon(Icons.play_arrow),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // add lap
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: IconButton(
                          splashRadius: 30,
                          color: Colors.white,
                          hoverColor: ColorsPallet().tuftsBlue.withOpacity(0.5),
                          onPressed: _stopWatchTimer.onAddLap,
                          icon: const Icon(Icons.flag),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Lap times.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: screenWidth / 5,
                    height: 150,
                    child: StreamBuilder<List<StopWatchRecord>>(
                      stream: _stopWatchTimer.records,
                      initialData: _stopWatchTimer.records.value,
                      builder: (context, snap) {
                        final value = snap.data!;
                        if (value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut);
                        });
                        //print('Listen records. $value');
                        return RawScrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          thickness: 10,
                          //trackVisibility: true,
                          thumbColor: ColorsPallet().ghostWhite_2,
                          radius: const Radius.circular(20),
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              final data = value[index];
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${index + 1}  ${data.displayTime}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  )
                                ],
                              );
                            },
                            itemCount: value.length,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
