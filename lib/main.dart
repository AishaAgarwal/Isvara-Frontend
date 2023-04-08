import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:get/get.dart';
import 'package:isvaraf/bindings/bind.dart';
import 'package:isvaraf/controller/controller.dart';
import 'package:isvaraf/response_screen.dart';
import 'package:http/http.dart' as http;
import 'package:isvaraf/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rive/rive.dart';


Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  InBin().dependencies();
  await Firebase.initializeApp(
  options : DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(GetMaterialApp(
    initialBinding: InBin(),
    theme: ThemeData(useMaterial3: true),
    debugShowCheckedModeBanner: false,
    // home: responseScreen(text: 'Hello',),
    home: TakePictureScreen(
      camera: firstCamera,
    ),
  ));
}

//TakePictureScreen(
// Pass the appropriate camera to the TakePictureScreen widget.
//  camera: firstCamera,
//),
// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      // Thumb icon when the switch is selected.
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  late XFile image;
  bool x = true;
  var stat = Get.find<appController>();
  late Future<void> _initializeControllerFuture;
  late Map<String, dynamic> ijson;
  Future<void> upload() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse("http://10.12.23.127:5675/upload"));

    request.files.add(http.MultipartFile(
        'file', image.readAsBytes().asStream(), await image.length(),
        filename: "data.jpeg"));
    var res = await request.send();
    ijson = jsonDecode(await res.stream.bytesToString());
    print(ijson);
  }
  late Map<String, dynamic> json;
  void fetchdata() async {
    final response =
        await http.get(Uri.parse("http://10.12.23.127:5675/result"));
    json = jsonDecode(response.body);
    print(json['Distance']);
    if (json['Distance'] < 30) {
      // ignore: use_build_context_synchronously
      ElegantNotification(
        title: Text('New Version'),
        description: Text("A new version is available to you please update."),
        icon: const Icon(
          Icons.access_alarm,
          color: Colors.orange,
        ),
        progressIndicatorColor: Colors.orange,
      ).show(context);
    }
    // print("cm");
  }

  void Cap_Image() async {
    try {
      image = await _controller.takePicture();
      if (!mounted) return;
      print("I am here");
      await upload();
      fetchdata();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text("Welcome to C.O.E.U.S"),
      // ),
      body: Stack(
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
          const RiveAnimation.asset(
            'RiveAsset/shapes.riv',
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
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 50,
            ),
            Obx(
              () => Align(
                alignment: Alignment.center,
                child: Switch(
                  thumbIcon: thumbIcon,
                  value: stat.on.value,
                  onChanged: (bool value) {
                    stat.on.value = value;
                  },
                ),
              ),
            ),
            Obx(
              () => SizedBox(
                child: stat.x.value
                    ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            print("I am here");
                            Timer.periodic(
                                const Duration(seconds: 2),
                                // ignore: non_constant_identifier_names
                                (timer) => {
                                      if (stat.on.value == false)
                                        {timer.cancel}
                                      else
                                        {
                                          Cap_Image(),
                                        }
                                    });
                            return const SizedBox();
                          } else {
                            // Otherwise, display a loading indicator.
                            return const Center(child: SizedBox());
                          }
                        },
                      )
                    : const SizedBox(
                        height: 10,
                      ),
              ),
            ),
          ]),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.only(left: 32, top: 100),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width) * 1 / 1.59,
                  child: Column(
                    children: const [
                      Text(
                        "Welcome to Isvara",
                        style: TextStyle(
                            color: Colors.white,
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
                        "Keeping an eye on your eyes",
                        style: TextStyle(color: Colors.white60),
                      )
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
