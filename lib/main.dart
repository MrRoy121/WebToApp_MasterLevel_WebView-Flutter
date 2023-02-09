// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/navigationBarProvider.dart';
import '../screens/splash_screen.dart';
import '../helpers/Constant.dart';
import '../screens/main_screen.dart';
import '../provider/theme_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (showInterstitialAds) {
    //  AdMobService.initialize();
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    statusBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  bool isNavVisible = true;
  int counter = 0;
  SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('counter', counter);
    var isDarkTheme =
        prefs.getBool("isDarkTheme") ?? ThemeMode.system == ThemeMode.dark
            ? true
            : false;
    return runApp(
      ChangeNotifierProvider<ThemeProvider>(
        child: MyApp(),
        create: (BuildContext context) {
          return ThemeProvider(isDarkTheme);
        },
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatfromState();
  }

  static const String oneSignalappid = "20daef39-ff94-466d-a9f2-c2ef574ede57";

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationBarProvider>(
            create: (_) => NavigationBarProvider())
      ],
      child: Consumer<ThemeProvider>(builder: (context, value, child) {
        return MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
            themeMode: value.getTheme(),
            theme: AppThemes.darkTheme,
            darkTheme: AppThemes.darkTheme,
            navigatorKey: navigatorKey,
            // onGenerateRoute: (RouteSettings settings) {
            //   switch (settings.name) {
            //     case 'settings':
            //       return CupertinoPageRoute(builder: (_) => SettingsScreen());
            //   }
            // },
            home: MyHome());
      }),
    );
  }

  Future<void> initPlatfromState() async {
    OneSignal.shared.setAppId(oneSignalappid);
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 4),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SecondScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: SizedBox(
            width: 1,
          ),
          flex: 124,
        ),
        Container(
            color: Colors.black,
            child: Center(
                child: Image.asset(
              "assets/splash.png",
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 8,
            ))),
        const Expanded(
          child: SizedBox(
            width: 1,
          ),
          flex: 116,
        ),
      ],
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      webUrl: webinitialUrl,
      isDeepLink: false,
    );
  }
}
