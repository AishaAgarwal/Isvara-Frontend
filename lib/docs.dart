import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:isvaraf/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:isvaraf/main.dart';
import 'package:rive/rive.dart' as riv;
import 'package:animated_text_kit/animated_text_kit.dart';

class DynamicDialog extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final title;
  final body;
  DynamicDialog({this.title, this.body});
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        OutlinedButton.icon(
            label: Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close))
      ],
      content: Text(widget.body),
    );
  }
}

class doc extends StatefulWidget {
  const doc({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  docState createState() => docState();
}

class docState extends State<doc> {
  bool x = true;
  var stat = Get.find<appController>();
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Positioned(
          //     width: MediaQuery.of(context).size.width * 1.5,
          //     bottom: 200,
          //     left: 100,
          //     child: Image.asset('RiveAsset/spine.png')),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
          )),
          Padding(
            padding: EdgeInsets.only(right: 125),
            child: riv.RiveAnimation.asset(
              'lib/spine.riv',
            ),
          ),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 30,
            ),
            child: const SizedBox(
                // height: 10,
                ),
          )),
          Padding(
              padding: EdgeInsets.only(left: 650, top: 150),
              child: SizedBox(
                  height: 500,
                  child: riv.RiveAnimation.asset(
                    'lib/nqueens.riv',
                  ))),
          Padding(
            padding: EdgeInsets.only(top: 50, left: 230),
            child: SizedBox(height: 60, child: Image.asset("lib/oh.png")),
          ),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 100),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width) * 1 / 1.59,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          colors: [Colors.grey, Colors.white],
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Precise Doc’s For Ya’',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 55,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      // Text(
                      //   "Welcome to Isvara",
                      //   style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 55,
                      //       fontFamily: "Mukta",
                      //       height: 1.2,
                      //       fontStyle: FontStyle.normal,
                      //       fontWeight: FontWeight.w500),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Keeping an eye on your eyes",
                        style: TextStyle(color: Colors.white60),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 450,
                          child: Text(
                            "Isvara sends notifications once a distance of less than 30 cm  is maintained for more than a minute between the user and the device’s screen ",
                            style: TextStyle(
                                color: Color.fromARGB(255, 230, 222, 222),
                                fontSize: 17,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 450,
                          child: Text(
                            "Before starting with Isvara make sure that the browser in which Isvara is running has the permission to send notifications on your device",
                            style: TextStyle(
                                color: Color.fromARGB(255, 230, 222, 222),
                                fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 450,
                          child: Text(
                            "The user can handle/modulate the state of Isvara via the switch provided on the main page",
                            style: TextStyle(
                                color: Color.fromARGB(255, 230, 222, 222),
                                fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      MyElevatedButton(
                        width: 140,
                        height: 45,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TakePictureScreen(
                                    camera: widget.camera,
                                  )));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Text(
                          'Get Started',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class MyElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width,
    this.height = 30,
    this.gradient = const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}
