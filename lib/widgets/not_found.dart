import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/src/provider.dart';
import '../helpers/Strings.dart';
import '../provider/navigationBarProvider.dart';

class NotFound extends StatefulWidget {
  InAppWebViewController _webViewController;
  String url;
  String title1;
  String title2;
  NotFound(this._webViewController, this.url, this.title1, this.title2);

  @override
  State<NotFound> createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFound> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        if (!context
            .read<NavigationBarProvider>()
            .animationController
            .isAnimating) {
          context.read<NavigationBarProvider>().animationController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

    @override
    Widget build(BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            const Expanded(
              flex: 23,
              child: SizedBox(
                width: 1,
              ),
            ),Container(
        color: Colors.black,
        child: Center(
            child: Image.asset(
              "assets/splash.png",
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 8,
            ))),

            const Expanded(
              flex: 10,
              child: SizedBox(
                width: 1,
              ),
            ),
            Image.asset(
              "assets/ex.png",
              width: 20,
              height: 30,
            ),
            SizedBox(height: 30,),
            const Text(
              "No hay conexión a internet.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20,),
            _isLoading
                ? const CircularProgressIndicator(
              color: Colors.black,
            )
                : TextButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                primary: Colors.black,
                onPrimary: Theme.of(context).cardColor,
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                Future.delayed(const Duration(seconds: 3), () {
                  widget._webViewController.loadUrl(
                      urlRequest: URLRequest(url: Uri.parse(widget.url)));
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
              child: const Text('Reintentar'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 18,
            ),
          ],
        ),
      );

  }
}
