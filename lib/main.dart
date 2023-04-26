import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:isvaraf/bindings/bind.dart';
import 'package:isvaraf/controller/controller.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isvaraf/docs.dart' as doc;
import 'package:isvaraf/home.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as riv;

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

Future<void> main() async {
  InBin().dependencies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(GetMaterialApp(
      initialBinding: InBin(),
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: home(
        camera: firstCamera,
      )));
}

class PushNotificationApp extends StatefulWidget {
  const PushNotificationApp({
    super.key,
    required this.camera,
  });
  static const routeName = "/firebase-push";
  final CameraDescription camera;
  @override
  _PushNotificationAppState createState() => _PushNotificationAppState();
}

class _PushNotificationAppState extends State<PushNotificationApp> {
  @override
  void initState() {
    getPermission();
    messageListener(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          print('android firebase initiated');
          return TakePictureScreen(camera: widget.camera);
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> getPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${notification!.body}');
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DynamicDialog(
                  title: notification.title, body: notification.body);
            }));
      }
    });
  }
}

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
  late String? _token;
  late Stream<String> _tokenStream;
  int notificationCount = 0;

  void setToken(String? token) {
    print('FCM TokenToken: $token');
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    FirebaseMessaging.instance.getToken().then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
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

  sendPushMessageToWeb() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await http
          .post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAhsjsJNc:APA91bFj36wOKcPvOEl0crJ159uTkBRE72-KnIoI71yPAGqaYF8pLfOSzw0YxJudD5TvOdGiwcKTUXdbfBp5wEbhrYNLJxnDPo40aYUBDxaUxwn04ba33t1vahBorssjhszC03HXWcJt'
            },
            body: jsonEncode({
              'to': _token,
              'message': {
                'token': _token,
              },
              "notification": {
                "title": "Too Close to the Screen",
                "body": "Would you please move back"
              }
            }),
          )
          .then((value) => print(value.body));
      print('FCM request for web sent!');
    } catch (e) {
      print(e);
    }
  }

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
    var request = http.MultipartRequest('POST',
        Uri.parse("https://flask-production-ed57.up.railway.app/upload"));

    request.files.add(http.MultipartFile(
        'file', image.readAsBytes().asStream(), await image.length(),
        filename: "data.jpeg"));
    var res = await request.send();
    ijson = jsonDecode(await res.stream.bytesToString());
    print(ijson);
  }

  late Map<String, dynamic> json;
  int i = 0;
  List<int> track = [];
  Future<void> fetchdata() async {
    final response = await http
        .get(Uri.parse("https://flask-production-ed57.up.railway.app/result"));
    json = jsonDecode(response.body);
    print(json['Distance']);
    track.add(json['Distance']);
    if (track.length == 30) {
      for (int j = 0; j < track.length; j++) {
        if (j < 30) {
          i++;
        }
      }
      if ((i / 30) * 100 >= 85) {
        sendPushMessageToWeb();
        print("Sent...............................................");
        i = 0;
        track.clear();
      }
    }
  }

  Future<void> Cap_Image() async {
    try {
      image = await _controller.takePicture();
      if (!mounted) return;
      print("I am here");
      await upload();
      await fetchdata();
    } catch (e) {
      print(e);
    }
  }

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
          //     child: Image.asset('RiveAsset/Spline.png')),
          Positioned(
              child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
          )),
          Padding(
            padding: EdgeInsets.only(right: 150),
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
                    'lib/moon_scan2.riv',
                  ))),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // SizedBox(
            //   height: 10,
            // ),
            Obx(
              () => Padding(
                padding: EdgeInsets.only(
                  left: 350,
                  bottom: 10,
                ),
                child: SizedBox(
                  height: 49,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      thumbIcon: thumbIcon,
                      activeColor: Color.fromARGB(255, 3, 141, 254),
                      value: stat.on.value,
                      onChanged: (bool value) {
                        stat.on.value = value;
                      },
                    ),
                  ),
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
                            print("I am here");
                            Timer.periodic(
                                const Duration(seconds: 4),
                                (timer) async => {
                                      if (stat.on.value == false)
                                        {timer.cancel}
                                      else
                                        {
                                          await Cap_Image(),
                                        }
                                    });
                            return const SizedBox();
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    : const SizedBox(),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.only(top: 40, left: 130),
            child: SizedBox(height: 60, child: Image.asset("lib/oh.png")),
          ),
          Obx(
            () => SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 100),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width) * 1 / 1.59,
                    child: Column(
                      children: [
                        // SizedBox(
                        //   height: 10,
                        // ),
                        stat.on.value
                            ? Text(
                                "Isvara is currently Active",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 55,
                                    fontFamily: "Mukta",
                                    height: 1.2,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500),
                              )
                            : const Text(
                                "Isvara is currently Deactive",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 55,
                                    fontFamily: "Mukta",
                                    height: 1.2,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w500),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
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
                              "Would you want to continue Isvara?",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 230, 222, 222),
                                  fontSize: 18,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 180,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 450,
                            child: Text(
                              "In order to get a recap and better understand the usage and features provided",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 230, 222, 222),
                                  fontSize: 17),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 70,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 180),
                          child: MyElevatedButton(
                            width: 140,
                            height: 45,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  doc.doc(
                                    camera: widget.camera,
                                  )));
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Text(
                              'Go to Docs',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          )
        ],
      ),
    );
  }
}
