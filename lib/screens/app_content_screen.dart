import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/no_internet.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/load_web_view.dart';

class AppContentScreen extends StatefulWidget {
  final String title;
  final String content;
  final String url;
  const AppContentScreen(
      {Key? key, required this.title, required this.content, required this.url})
      : super(key: key);

  @override
  _AppContentScreenState createState() => _AppContentScreenState();
}

class _AppContentScreenState extends State<AppContentScreen> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    NoInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      NoInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = widget.content;
    message = Theme.of(context).brightness == Brightness.dark
        ? "<font color='white'>" + widget.content + "</font>"
        : "<font color='black'>" + widget.content + "</font>";
    return SafeArea(
      top: Platform.isIOS ? false : true,
      child: Scaffold(
          // backgroundColor: Colors.red,
          appBar: AppBar(
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              statusBarColor: Colors.black,

              systemNavigationBarIconBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
          ),
            title: Text(widget.title),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: widget.url == ''
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: LoadWebView(
                    url: message,
                    webUrl: false,
                    isDeepLink: false,
                    isMainPage: false,
                  ))
              : _connectionStatus == 'ConnectivityResult.none'
                  ? const NoInternetWidget()
                  : LoadWebView(
                      url: widget.url,
                      webUrl: true,
                      isDeepLink: false,
                      isMainPage: false,
                    )),
    );
  }
}
