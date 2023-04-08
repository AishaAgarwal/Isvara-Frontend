import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart';
//Solution for Ya'
//"Providing a highly tested and well accepted solution"
class responseScreen extends StatefulWidget {
  const responseScreen({
    super.key,
    required this.text,
  });
  final String text;
  @override
  State<responseScreen> createState() => _responseScreenState();
}
class _responseScreenState extends State<responseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text("Welcome to C.O.E.U.S"),
      // ),
      body: Stack(
        // alignment: Alignment.center,
        children: [
          Positioned(
              width: MediaQuery.of(context).size.width * 1.5,
              bottom: 200,
              left: 100,
              child: Image.asset('RiveAsset/Spline.png')),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
          )),
          RiveAnimation.asset(
            'RiveAsset/bub.riv',
          ),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30,
              sigmaY: 30,
            ),
            child: SizedBox(
                // height: 10,
                ),
          )),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.only(left: 32, top: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width) * 1 / 1.59,
                  child: Column(
                    children: [
                      const Text(
                        "Solution for Ya'",
                        style: TextStyle(
                            fontSize: 60,
                            fontFamily: "Mukta",
                            height: 1.2,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                          "Providing a highly tested and well accepted solution"),
                      SizedBox(
                        height: (MediaQuery.of(context).size.width) * 1 / 8,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: (MediaQuery.of(context).size.width) * 1 / 7,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width) * 1 / 1.8,
                              child: Text(
                                // textAlign: TextAlign.center,
                                widget.text,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: "Mukta",
                                  height: 1.5,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}