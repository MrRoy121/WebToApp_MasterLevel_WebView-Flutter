// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webtoapp_flutter/helpers/Icons.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/no_internet_widget.dart';
import '../helpers/Constant.dart';
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../helpers/Strings.dart';
import '../provider/navigationBarProvider.dart';
import '../screens/main_screen.dart';
import '../widgets/not_found.dart';

import '../helpers/Colors.dart';
import 'no_internet.dart';

class LoadWebView extends StatefulWidget {
  String url = '';
  bool webUrl = true;
  bool isDeepLink;
  bool isMainPage;

  LoadWebView(
      {required this.url,
      required this.webUrl,
      required this.isDeepLink,
      required this.isMainPage,
      Key? key})
      : super(key: key);

  @override
  _LoadWebViewState createState() => _LoadWebViewState();
}

class _LoadWebViewState extends State<LoadWebView>
    with SingleTickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();

  late PullToRefreshController _pullToRefreshController;
  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewController? webViewController;
  double progress = 0;
  String url = '';
  int _previousScrollY = 0;
  bool isLoading = false;
  bool showErrorPage = false;
  bool slowInternetPage = false;
  bool noInternet = false;
  late AnimationController animationController;
  late Animation<double> animation;
  final expiresDate =
      DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch;
  String _connectionStatus = 'ConnectivityResult.none';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var browserOptions;
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
            if (_connectionStatus != 'ConnectivityResult.none') {
              noInternet = false;
            } else {
              noInternet = true;
            }
          }));
    });
    try {
      _pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(backgroundColor: Colors.transparent, color: Colors.transparent),
        onRefresh: () async {
          if (Platform.isAndroid) {
            webViewController!.reload();
          } else if (Platform.isIOS) {
            webViewController!.loadUrl(
                urlRequest: URLRequest(url: await webViewController!.getUrl()));
          }
        },
      );
    } on Exception catch (e) {
      print(e);
    }

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    animationController.dispose();
    webViewController = null;
    super.dispose();
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnDownloadStart: true,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          cacheEnabled: true,
          userAgent:
              "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
          verticalScrollBarEnabled: false,
          horizontalScrollBarEnabled: false,
          transparentBackground: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    bool _validURL = Uri.parse(widget.url).host == '' ? false : true;

    return GestureDetector(
      onHorizontalDragEnd: (dragEndDetails) async {
        if (dragEndDetails.primaryVelocity! > 0) {
          if (widget.isDeepLink) {
            if (await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              setState(() {
                widget.isDeepLink = false;
              });

              webViewController!.loadUrl(
                  urlRequest: URLRequest(url: Uri.parse(webinitialUrl)));
            }
          } else if (await webViewController!.canGoBack()) {
            webViewController!.goBack();
          }
        }
      },
      child: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: !widget.webUrl
            ? InAppWebView(
                initialData: InAppWebViewInitialData(
                    data: widget.url, mimeType: 'text/html', encoding: "utf8"),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      cacheEnabled: true,
                      verticalScrollBarEnabled: false,
                      horizontalScrollBarEnabled: false,
                      transparentBackground: true,
                      allowFileAccessFromFileURLs: true,
                    ),
                    android: AndroidInAppWebViewOptions(
                        useHybridComposition: true, defaultFontSize: 32),
                    ios: IOSInAppWebViewOptions(
                      allowsInlineMediaPlayback: true,
                    )),
                pullToRefreshController: _pullToRefreshController,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onScrollChanged: (controller, x, y) async {
                  int currentScrollY = y;

                  if (currentScrollY > _previousScrollY) {
                    _previousScrollY = currentScrollY;
                    if (!context
                        .read<NavigationBarProvider>()
                        .animationController
                        .isAnimating) {
                      context
                          .read<NavigationBarProvider>()
                          .animationController
                          .forward();
                    }
                  } else {
                    _previousScrollY = currentScrollY;

                    if (!context
                        .read<NavigationBarProvider>()
                        .animationController
                        .isAnimating) {
                      context
                          .read<NavigationBarProvider>()
                          .animationController
                          .reverse();
                    }
                  }
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                  });
                },
                onLoadStop: (controller, url) async {
                  _pullToRefreshController.endRefreshing();
                },
                onLoadError: (controller, url, code, message) {
                  _pullToRefreshController.endRefreshing();

                  setState(() {
                    slowInternetPage = true;
                  });
                },
                onLoadHttpError: (controller, url, statusCode, description) {
                  setState(() {
                    showErrorPage = true;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    _pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    // urlController.text = this.url;
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
              )
            : Stack(
                alignment: AlignmentDirectional.topStart,
                clipBehavior: Clip.hardEdge,
                children: [
                  _validURL
                      ? InAppWebView(
                          initialUrlRequest:
                              URLRequest(url: Uri.parse(widget.url)),
                          initialOptions: options,
                          pullToRefreshController: _pullToRefreshController,
                          gestureRecognizers: <
                              Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer()),
                          },
                          onWebViewCreated: (controller) async {
                            webViewController = controller;

                            await cookieManager.setCookie(
                              url: Uri.parse(widget.url),
                              name: "myCookie",
                              value: "myValue",
                              // domain: ".flutter.dev",
                              expiresDate: expiresDate,
                              isHttpOnly: false,
                              isSecure: true,
                            );
                          },
                          onScrollChanged: (controller, x, y) async {
                            int currentScrollY = y;
                            if (currentScrollY > _previousScrollY) {
                              _previousScrollY = currentScrollY;
                              if (!context
                                  .read<NavigationBarProvider>()
                                  .animationController
                                  .isAnimating) {
                                context
                                    .read<NavigationBarProvider>()
                                    .animationController
                                    .forward();
                              }
                            } else {
                              _previousScrollY = currentScrollY;

                              if (!context
                                  .read<NavigationBarProvider>()
                                  .animationController
                                  .isAnimating) {
                                context
                                    .read<NavigationBarProvider>()
                                    .animationController
                                    .reverse();
                              }
                            }
                          },
                          onLoadStart: (controller, url) async {
                            print('----loadstart---- $url');

                            setState(() {
                              isLoading = true;
                              showErrorPage = false;
                              slowInternetPage = false;
                            });
                            if (Platform.isAndroid) {
                              List<Cookie> cookies =
                                  await cookieManager.getCookies(url: url!);
                              // print('---android cookies---$cookies');
                            }
                            if (Platform.isIOS) {
                              List<Cookie> iosCookies =
                                  await cookieManager.ios.getAllCookies();
                              // print('---ios cookies---$iosCookies');
                            }
                            setState(() {
                              this.url = url.toString();
                            });
                          },
                          onLoadStop: (controller, url) async {
                            print('==load stop');
                            _pullToRefreshController.endRefreshing();

                            setState(() {
                              this.url = url.toString();
                            });

                            // Removes header and footer from page
                            if (hideHeader == true) {
                              webViewController!
                                  .evaluateJavascript(
                                      source: "javascript:(function() { " +
                                          "var head = document.getElementsByTagName('header')[0];" +
                                          "head.parentNode.removeChild(head);" +
                                          "})()")
                                  .then((value) => debugPrint(
                                      'Page finished loading Javascript'))
                                  .catchError(
                                      (onError) => debugPrint('$onError'));
                            }
                            if (hideFooter == true) {
                              webViewController!
                                  .evaluateJavascript(
                                      source: "javascript:(function() { " +
                                          "var footer = document.getElementsByTagName('footer')[0];" +
                                          "footer.parentNode.removeChild(footer);" +
                                          "})()")
                                  .then((value) => debugPrint(
                                      'Page finished loading Javascript'))
                                  .catchError(
                                      (onError) => debugPrint('$onError'));
                            }
                          },
                          onLoadError: (controller, url, code, message) async {
                            _pullToRefreshController.endRefreshing();
                            print('---load error----==$code ---$message');

                            setState(() {
                              if (code != 102) {
                                slowInternetPage = true;
                              }

                              isLoading = false;
                            });
                          },
                          onLoadHttpError:
                              (controller, url, statusCode, description) {
                            _pullToRefreshController.endRefreshing();
                            print('---load http error----$description');
                            setState(() {
                              showErrorPage = true;
                              isLoading = false;
                            });
                          },
                          androidOnGeolocationPermissionsShowPrompt:
                              (controller, origin) async {
                            //   await Permission.location.request();
                            // },
                            await Permission.location.request();
                            return Future.value(
                                GeolocationPermissionShowPromptResponse(
                                    origin: origin, allow: true, retain: true));
                          },
                          androidOnPermissionRequest:
                              (controller, origin, resources) async {
                            if (resources.contains(
                                'android.webkit.resource.AUDIO_CAPTURE')) {
                              await Permission.microphone.request();
                            }
                            if (resources.contains(
                                'android.webkit.resource.VIDEO_CAPTURE')) {
                              await Permission.camera.request();
                            }

                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          },
                          onProgressChanged: (controller, progress) {
                            if (progress == 100) {
                              _pullToRefreshController.endRefreshing();
                              isLoading = false;
                            }
                            setState(() {
                              this.progress = progress / 100;
                            });
                          },
                          shouldOverrideUrlLoading:
                              (controller, navigationAction) async {
                            var url = navigationAction.request.url.toString();
                            var uri = Uri.parse(url);
                            print('---url--$url');
                            if (Platform.isIOS && url.contains("geo")) {
                              var newUrl = url.replaceFirst(
                                  'geo://', 'http://maps.apple.com/');
                            } else if (url.contains("tel:") ||
                                url.contains("mailto:") ||
                                url.contains("play.google.com") ||
                                url.contains("maps") ||
                                url.contains("messenger.com")) {
                              url = Uri.encodeFull(url);
                              try {
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri);
                                } else {
                                  launchUrl(uri);
                                }
                                return NavigationActionPolicy.CANCEL;
                              } catch (e) {
                                launchUrl(uri);
                                return NavigationActionPolicy.CANCEL;
                              }
                            } else if (![
                              "http",
                              "https",
                              "file",
                              "chrome",
                              "data",
                              "javascript",
                            ].contains(uri.scheme)) {
                              if (await canLaunchUrl(uri)) {
                                // Launch the App
                                await launchUrl(
                                  uri,
                                );
                                // and cancel the request
                                return NavigationActionPolicy.CANCEL;
                              }
                            } else if (url == 'about:blank') {
                              return NavigationActionPolicy.CANCEL;
                            }

                            return NavigationActionPolicy.ALLOW;
                          },
                          onCloseWindow: (controller) async {
                            //  webViewController!.evaluateJavascript(source:'document.cookie = "token=$token"');
                          },
                          onCreateWindow:
                              (controller, createWindowRequest) async {
                            // showDialog(
                            //   context: context,
                            //   builder: (context) {
                            //     return AlertDialog(
                            //       content: Container(
                            //         width: MediaQuery.of(context).size.width,
                            //         height: MediaQuery.of(context).size.width,
                            //         child: InAppWebView(
                            //           // Setting the windowId property is important here!
                            //           initialUrlRequest:
                            //               URLRequest(url: Uri.parse(url)),
                            //           windowId: createWindowRequest.windowId,
                            //           initialOptions: InAppWebViewGroupOptions(
                            //             android: AndroidInAppWebViewOptions(),
                            //           ),
                            //           onWebViewCreated:
                            //               (InAppWebViewController controller) {
                            //             webViewController = controller;
                            //           },
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // );

                            return true;
                          },
                          onDownloadStartRequest:
                              (controller, downloadStartRrquest) async {
                            print('=--download--$url');

                            requestPermission().then((status) async {
                              String url = downloadStartRrquest.url.toString();

                              if (status == true) {
                                try {
                                  Dio dio = Dio();
                                  File file = File(url.toString());
                                  String fileName;
                                  if (url.toString().lastIndexOf('?') > 0) {
                                    fileName = url.toString().substring(
                                        url.toString().lastIndexOf('/') + 1,
                                        url.toString().lastIndexOf('?'));
                                  } else {
                                    fileName = url.toString().substring(
                                        url.toString().lastIndexOf('/') + 1);
                                  }
                                  String savePath = await getFilePath(fileName);
                                  print(savePath);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text('Downloading file..'),
                                  ));
                                  await dio.download(url.toString(), savePath,
                                      onReceiveProgress: (rec, total) {});

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text('Download Complete'),
                                  ));
                                } on Exception catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text('Downloading failed'),
                                  ));
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text('Permision denied'),
                                ));
                              }
                            });
                          },
                          onUpdateVisitedHistory:
                              (controller, url, androidIsReload) {
                            print('--from onUpdateVisitedHistory--$url');

                            setState(() {
                              this.url = url.toString();
                            });
                          },
                          onConsoleMessage: (controller, message) {
                            print('---console---$message');
                          },
                        )
                      : Center(
                          child: Text(
                          'Url is not valid',
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                  isLoading
                      ?  Center(
                    child: CircularProgressIndicator(),
                  )
                      : SizedBox(height: 0, width: 0),
                  noInternet
                      ? Center(
                          child: NoInternetWidget(),
                        )
                      : SizedBox(height: 0, width: 0),
                  showErrorPage
                      ? Center(
                          child: NotFound(
                              webViewController!,
                              url,
                              CustomStrings.pageNotFound1,
                              CustomStrings.pageNotFound2))
                      : SizedBox(height: 0, width: 0),
                  slowInternetPage
                      ? Center(
                          child: NotFound(
                              webViewController!,
                              url,
                              CustomStrings.incorrectURL1,
                              CustomStrings.incorrectURL2))
                      : SizedBox(height: 0, width: 0),
                  progress < 1.0
                      ? SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 5.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .progressIndicatorTheme
                                      .color!,
                                  Theme.of(context)
                                      .progressIndicatorTheme
                                      .refreshBackgroundColor!,
                                  Theme.of(context)
                                      .progressIndicatorTheme
                                      .linearTrackColor!,
                                ],
                                stops: const [0.1, 1.0, 0.1],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (mounted) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    print('*****in=== ${url}');
    if (widget.isDeepLink) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();

        return Future.value(false);
      }

      setState(() {
        widget.isDeepLink = false;
      });

      webViewController!
          .loadUrl(urlRequest: URLRequest(url: Uri.parse(webinitialUrl)));

      return Future.value(false);
    } else if (await webViewController!.canGoBack()) {
      print('go back');
      webViewController!.goBack();

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.storage.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status != PermissionStatus.granted) {
      //
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        // await openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = '/storage/emulated/0/Download';
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    print(path);
    path = '$externalStorageDirPath/$uniqueFileName';
    return path;
  }
}

// class PlatformViewVerticalGestureRecognizer
//     extends VerticalDragGestureRecognizer {
//   PlatformViewVerticalGestureRecognizer({PointerDeviceKind? kind})
//       : super(kind: kind);

//   Offset _dragDistance = Offset.zero;

//   @override
//   void addPointer(PointerEvent event) {
//     startTrackingPointer(event.pointer);
//   }

//   @override
//   void handleEvent(PointerEvent event) {
//     _dragDistance = _dragDistance + event.delta;
//     if (event is PointerMoveEvent) {
//       final double dy = _dragDistance.dy.abs();
//       final double dx = _dragDistance.dx.abs();

//       if (dy > dx && dy > kTouchSlop) {
//         // vertical drag - accept
//         resolve(GestureDisposition.accepted);
//         _dragDistance = Offset.zero;
//       } else if (dx > kTouchSlop && dx > dy) {
//         // horizontal drag - stop tracking
//         stopTrackingPointer(event.pointer);
//         _dragDistance = Offset.zero;
//       }
//     }
//   }

//   @override
//   String get debugDescription => 'horizontal drag (platform view)';

//   @override
//   void didStopTrackingLastPointer(int pointer) {}
// }
