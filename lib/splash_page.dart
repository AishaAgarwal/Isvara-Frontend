import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isvaraf/main.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.ca});
  final ca;
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  void _navigateAfter() {
    print("done timer");
    // Get.to(MyHomePage());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => TakePictureScreen(
              camera: widget.ca,
            )));
  }

  void startTimer() {
    Timer(const Duration(seconds: 6), _navigateAfter);
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceInOut);

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 240, 232),
      body: Stack(
        children: const [
          // ScaleTransition(
          //   scale: animation,
          //   child:
          Center(
            //     child: Image.asset(
            //   "lib/hipi.png",
            //   width: 250,
            // )
            child: RiveAnimation.asset(
              'RiveAsset/bub.riv',
            ),
          ),
          // ),
        ],
      ),
    );
  }
}