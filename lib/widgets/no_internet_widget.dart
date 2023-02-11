import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/src/provider.dart';
import '../helpers/Icons.dart';
import '../helpers/Strings.dart';
import '../provider/navigationBarProvider.dart';
import '../widgets/no_internet.dart';

class NoInternetWidget extends StatefulWidget {
  const NoInternetWidget({Key? key}) : super(key: key);

  @override
  _NoInternetWidgetState createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
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
            child: SizedBox(
              width: 1,
            ),
            flex: 23,
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
            flex: 10,
          ),
          Image.asset(
            "assets/ex.png",
            width: 20,
            height: 30,
          ),
          SizedBox(
            height: 30,
          ),
          const Text(
            "No hay conexión a internet.",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : TextButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });

                    Future.delayed(const Duration(seconds: 3), () {
                      NoInternet.initConnectivity();
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },
                  child: const Text('Reintentar',style: TextStyle(color: Colors.white),),
                ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 18,
          ),
        ],
      ),
    );
  }
}
