import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:isvaraf/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:isvaraf/docs.dart';
import 'package:isvaraf/main.dart';
import 'package:rive/rive.dart' as riv;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DynamicDialog extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final title;
  final body;
  DynamicDialog({this.title, this.body});
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}
var stat = Get.find<appController>();

Future<User?> signInWithGoogle({required BuildContext context}) async {
  User? user;
  GoogleAuthProvider authProvider = GoogleAuthProvider();
  try {
    final UserCredential userCredential =
        await stat.auth.signInWithPopup(authProvider);
    user = userCredential.user;
    print(user!.photoURL);
  } catch (e) {
    print(e);
  }
  return user;
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

class home extends StatefulWidget {
  const home({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  homeState createState() => homeState();
}

class homeState extends State<home> {
  bool x = true;
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
                    'lib/curious_eyess.riv',
                  ))),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 0,
              sigmaY: 0,
            ),
            child: const SizedBox(
                // height: 10,
                ),
          )),
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
                      SizedBox(
                        height: 10,
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          colors: [Colors.grey, Colors.white],
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome to Isvara',
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 55,
                                fontWeight: FontWeight.w300,
                              ),
                              speed: const Duration(milliseconds: 200),
                            ),
                          ],
                          totalRepeatCount: 5,
                          pause: const Duration(milliseconds: 250),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
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
                        height: 90,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 450,
                          child: Text(
                            "Greetings users, providing eye protection and Care, via realtime notifications/alerts ",
                            style: TextStyle(
                                color: Color.fromARGB(255, 230, 222, 222),
                                fontSize: 18,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 90,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 450,
                          child: Text(
                            "Suggesting you to move backwards from the screen maintaining an ideal distance incase of extreme closure to the screen",
                            style: TextStyle(
                                color: Color.fromARGB(255, 230, 222, 222),
                                fontSize: 17),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      MyElevatedButton(
                        width: 230,
                        height: 45,
                        onPressed: () async {
                          await signInWithGoogle(context: context)
                              .then((value) => {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                doc(
                                                  camera: widget.camera,
                                                  data: value,
                                                ))),
                                    print(value)
                                  });
                            
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Text(
                          'Sign in with Google',
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
      child: ElevatedButton.icon(
        icon: SizedBox(
          height: 30,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Image.asset('lib/google.png'),
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        label: child,
      ),
    );
  }
}
