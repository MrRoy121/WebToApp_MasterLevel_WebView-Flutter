import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBoxCurve extends StatelessWidget {
  final double width, height;
  final Widget child;

  const GlassBoxCurve(
      {Key? key,
      required this.width,
      required this.height,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        // color: Colors.transparent,
        width: width,
        height: height,

        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.0,
                sigmaY: 7.0,
              ),
              child: Container(
                width: width,
                height: height,
                child: const Text(" "),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).bottomAppBarColor,
                        blurRadius: 30,
                        offset: const Offset(2, 2))
                  ],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Theme.of(context).bottomAppBarColor, width: 1.0),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).bottomAppBarColor,
                        Theme.of(context).bottomAppBarColor,
                      ],
                      stops: const [
                        0.0,
                        1.0,
                      ])),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
