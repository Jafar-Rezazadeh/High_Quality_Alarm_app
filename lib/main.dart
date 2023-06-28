import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:high_quality_clock/tabs/alarms.dart';
import 'package:high_quality_clock/tabs/stop_watch.dart';
import 'package:high_quality_clock/tabs/timer_tab.dart';
import 'package:url_launcher/link.dart';

import 'package:high_quality_clock/theme/color_pallet.dart';

import 'package:sidebarx/sidebarx.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  runApp(const MyApp());

  // windows Style
  // == for make the window background transparent(for rounded corners)
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  Window.initialize();
  Window.setEffect(effect: WindowEffect.transparent);

  // == Bitsdojo for title bar
  doWhenWindowReady(() async {
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    final win = appWindow;

    win.alignment = Alignment.center;
    win.size = const Size(1024, 700);
    win.minSize = const Size(800, 700);
    win.maxSize = const Size(1200, 800);
    win.title = "HighQualityClock";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HighQualityClock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(labelMedium: TextStyle(color: Colors.white)),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor:
              MaterialStateProperty.all<Color>(ColorsPallet().ghostWhite_2),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const menuWidth = 100.0;
const titleBarHeight = 50.0;
int _currentTabIndex = 0;

//
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        // etc.
      };
}

class _MyHomePageState extends State<MyHomePage> {
  var windowsButtonsColor = WindowButtonColors(
    mouseOver: Colors.grey,
    iconNormal: Colors.white,
  );
  final pageController = PageController();
  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: ColorsPallet().richBlack,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                //Title Bar
                SizedBox(
                  height: titleBarHeight - 2,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //MovableSection
                      Expanded(
                        child: MoveWindow(
                          onDoubleTap: () {},
                        ),
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          textDirection: TextDirection.rtl,
                          children: [
                            CloseWindowButton(
                              onPressed: () {
                                exitAlert();
                              },
                            ),
                            MinimizeWindowButton(colors: windowsButtonsColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: ColorsPallet().ghostWhite_2,
                  endIndent: 0,
                  indent: 0,
                  thickness: 1,
                ),
                //Contents
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    navigationMenu(context, height),
                    // contents of each tab
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(20)),
                          color: Colors.transparent,
                        ),
                        height: height - titleBarHeight,
                        width: width - menuWidth,
                        child: Center(
                          child: PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            controller: pageController,
                            children: [
                              //Alarms
                              const Alarms()
                                  .animate(
                                    target: _currentTabIndex == 0 ? 1 : 0,
                                  )
                                  .fadeIn(delay: 500.ms, duration: 500.ms),
                              //Timer
                              const TimerTab()
                                  .animate(
                                    target: _currentTabIndex == 1 ? 1 : 0,
                                  )
                                  .fadeIn(delay: 500.ms, duration: 500.ms),

                              //StopWatch
                              const StopWatchTap()
                                  .animate(
                                    target: _currentTabIndex == 2 ? 1 : 0,
                                  )
                                  .fadeIn(delay: 500.ms, duration: 500.ms)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(),
    );
  }

  exitAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(110),
        shadowColor: Colors.black.withOpacity(0.9),
        content: Container(
          decoration: BoxDecoration(
            color: ColorsPallet().oxfordBlue,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: ColorsPallet().tuftsBlue,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          height: 200,
          width: 300,
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "خروج",
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: 20,
                ),
              ),
              Text(
                "اگر خارج شوید هشدار ها قابل مشاهده نخواهد بود آیا مطمئن هستید؟",
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: ColorsPallet().ghostWhite,
                  fontSize: 15,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorsPallet().orenge),
                    ),
                    onPressed: () {
                      appWindow.close();
                    },
                    child: const Text("بله"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("لغو"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //Todo: add app icon and other needed options for release

  Widget navigationMenu(context, height) {
    return Container(
      height: height - titleBarHeight,
      width: 200,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
      child: SidebarX(
        footerBuilder: (context, extended) => Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(
            left: 20,
            bottom: 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
            child: IconButton(
              splashRadius: 20,
              hoverColor: ColorsPallet().tuftsBlue.withOpacity(0.3),
              color: Colors.white,
              onPressed: () {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.9),
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: const EdgeInsets.all(60),
                    backgroundColor: Colors.transparent,
                    content: Container(
                      padding: const EdgeInsets.all(20),
                      height: 500,
                      width: 300,
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
                            color: ColorsPallet().tuftsBlue.withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "درباره سازنده",
                            style: TextStyle(
                              color: ColorsPallet().ghostWhite,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Text.rich(
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              height: 2,
                              wordSpacing: -1,
                            ),
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "جعفر رضازاده ",
                                  style: TextStyle(
                                    color: ColorsPallet().lightGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      "فارغ التحصل رشته نرم افزار کامپیوتر، علاقمند به برنامه نویسی در پلتفرم های مختلف.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: Link(
                              target: LinkTarget.blank,
                              uri: Uri.parse(
                                  "https://jafarrezazadeh76@gmail.com"),
                              builder: (context, followLink) => Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    width: 2,
                                    color: ColorsPallet().tuftsBlue,
                                  )),
                                ),
                                child: TextButton(
                                  onPressed: followLink,
                                  child:
                                      const Text("jafarrezazadeh76@gmail.com"),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.question_mark),
            ),
          ),
        ),
        animationDuration: const Duration(seconds: 0),
        theme: SidebarXTheme(
          //main style
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),

          //text style
          textStyle: const TextStyle(color: Colors.white),
          itemTextPadding: const EdgeInsets.symmetric(horizontal: 10),
          selectedItemTextPadding: const EdgeInsets.symmetric(horizontal: 10),
          selectedTextStyle: const TextStyle(color: Colors.white),
          //item style
          selectedItemDecoration: const BoxDecoration(
            color: Color.fromRGBO(236, 238, 244, 0.2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          hoverColor: ColorsPallet().tuftsBlue.withOpacity(0.3),
          itemDecoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          // icon style
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          selectedIconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        controller: SidebarXController(
          selectedIndex: _currentTabIndex,
          extended: true,
        ),
        showToggleButton: false,
        items: [
          //alarms
          SidebarXItem(
            icon: Icons.alarm,
            label: "هشدار ها",
            onTap: (() {
              setState(() => _currentTabIndex = 0);
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutExpo,
              );
            }),
          ),
          //timer
          SidebarXItem(
            icon: Icons.timer,
            label: "تایمر",
            onTap: (() {
              setState(() => _currentTabIndex = 1);
              pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutExpo,
              );
            }),
          ),
          //stopWatch
          SidebarXItem(
            icon: Icons.timer_outlined,
            label: "کرونومتر",
            onTap: (() {
              setState(() => _currentTabIndex = 2);
              pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutExpo,
              );
            }),
          ),
        ],
      ),
    );
  }
}
