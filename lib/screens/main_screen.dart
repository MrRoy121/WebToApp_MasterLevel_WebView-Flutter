import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/src/provider.dart';
//import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:lottie/lottie.dart';
import '../helpers/Icons.dart';
import '../helpers/Constant.dart';
import '../helpers/Strings.dart';
import '../widgets/GlassBoxCurve.dart';
import '../provider/navigationBarProvider.dart';

import '../screens/home_screen.dart';
import 'settings_screen.dart';

class MyHomePage extends StatefulWidget {
  final String webUrl;
  final bool isDeepLink;
  const MyHomePage({Key? key, required this.webUrl, required this.isDeepLink})
      : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  var _previousIndex;
  late AnimationController idleAnimation;
  late AnimationController onSelectedAnimation;
  late AnimationController onChangedAnimation;
  Duration animationDuration = const Duration(milliseconds: 700);
  late AnimationController navigationContainerAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    idleAnimation = AnimationController(vsync: this);
    onSelectedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    onChangedAnimation =
        AnimationController(vsync: this, duration: animationDuration);
    Future.delayed(Duration.zero, () {
      context
          .read<NavigationBarProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
    initPlatformState();

  }

  Future<void> initPlatformState() async {
    // await OneSignal.shared.setAppId(
    //     Platform.isAndroid ? oneSignalAndroidAppId : oneSignalIOSAppId);
    // OneSignal.shared
    //     .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    //   print(
    //       'NOTIFICATION OPENED HANDLER CALLED WITH: ${result.notification.launchUrl}');
    //   if (result.notification.launchUrl != null) {
    //     setState(() {
    //       webinitialUrl = result.notification.launchUrl.toString();
    //       Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(
    //             builder: (_) => MyHomePage(
    //                   webUrl: webinitialUrl,
    //                   isDeepLink: true,
    //                 )),
    //         (route) => false,
    //       );
    //     });
    //   }
    // });
    //
    // OneSignal.shared.setNotificationWillShowInForegroundHandler(
    //     (OSNotificationReceivedEvent event) {
    //   setState(() {
    //     print(
    //         "Notification received in foreground notification: \n${event.notification.launchUrl}");
    //   });
    // });
  }

  @override
  void dispose() {
    idleAnimation.dispose();
    onSelectedAnimation.dispose();
    onChangedAnimation.dispose();
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => _navigateBack(context),
      child: GestureDetector(
        onTap: () =>
            context.read<NavigationBarProvider>().animationController.reverse(),
        child: SafeArea(
          top: Platform.isIOS ? false : true,
          child: Scaffold(
            extendBody: true,
            // extendBody: true,
            bottomNavigationBar: showBottomNavigationBar
                ? FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(
                            parent: navigationContainerAnimationController,
                            curve: Curves.easeInOut)),
                    child: SlideTransition(
                        position: Tween<Offset>(
                                begin: Offset.zero, end: const Offset(0.0, 1.0))
                            .animate(CurvedAnimation(
                                parent: navigationContainerAnimationController,
                                curve: Curves.easeInOut)),
                        child: _bottomNavigationBar),
                  )
                : null,
            body:
            showBottomNavigationBar
                ? IndexedStack(
                    index: _selectedIndex,
                    children: _tabs,
                  )
                : Navigator(
                    key: _navigatorKeys[1],
                    onGenerateRoute: (routeSettings) {
                      return MaterialPageRoute(
                          builder: (_) => HomeScreen(
                                widget.webUrl,
                                true,
                                false,
                              ));
                    },
                  ),
          ),
        ),
      ),
    );
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  late final List<Widget> _tabs = [
    //demo tab
    Navigator(
      key: _navigatorKeys[0],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (_) => HomeScreen(firstTabUrl, false, false),
        );
      },
    ),

    //home tab
    Navigator(
      key: _navigatorKeys[1],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
            builder: (_) => HomeScreen(
                  widget.webUrl,
                  true,
                  widget.isDeepLink,
                ));
      },
    ),

    //settings tab
    // Navigator(
    //   key: _navigatorKeys[2],
    //   onGenerateRoute: (routeSettings) {
    //     return MaterialPageRoute(builder: (_) => const SettingsScreen());
    //   },
    // ),
  ];

  Widget get _bottomNavigationBar {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 3,
            spreadRadius: 1,
          )
        ],
      ),
      child: GlassBoxCurve(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 10,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, right: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildNavItem(0, CustomStrings.demo,
                  Theme.of(context).colorScheme.demoIcon),
              _buildNavItem(1, CustomStrings.home,
                  Theme.of(context).colorScheme.homeIcon),
              _buildNavItem(2, CustomStrings.settings,
                  Theme.of(context).colorScheme.settingsIcon),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String icon) {
    return InkWell(
      onTap: () {
        onButtonPressed(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10.0),
          Lottie.asset(icon,
              height: 30,
              repeat: true,
              // reverse: true,
              // animate: true,
              controller: _selectedIndex == index
                  ? onSelectedAnimation
                  : _previousIndex == index
                      ? onChangedAnimation
                      : idleAnimation),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Text(title,
                textAlign: TextAlign.center,
                style: _selectedIndex == index
                    ? TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      )
                    : const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: 35,
                height: 3,
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ? Theme.of(context).indicatorColor
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0)),
                  boxShadow: _selectedIndex == index
                      ? [
                          BoxShadow(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.5),
                            blurRadius: 50.0, // soften the shadow
                            spreadRadius: 20.0,
                            //extend the shadow
                          )
                        ]
                      : [],
                )),
          ),
        ],
      ),
    );
  }

  void onButtonPressed(int index) {
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    // pageController.jumpToPage(index);
    onSelectedAnimation.reset();
    onSelectedAnimation.forward();

    onChangedAnimation.value = 1;
    onChangedAnimation.reverse();

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  Future<bool> _navigateBack(BuildContext context) async {
    if (Platform.isIOS && Navigator.of(context).userGestureInProgress) {
      return Future.value(true);
    }
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
    if (!context
        .read<NavigationBarProvider>()
        .animationController
        .isAnimating) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    if (!isFirstRouteInCurrentTab) {
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Do you want to exit app?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ));

      return Future.value(true);
    }
  }
}
