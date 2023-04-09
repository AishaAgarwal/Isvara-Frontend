import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isvaraf/bindings/bind.dart';
import 'package:isvaraf/controller/controller.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// import 'package:browser_api/browser_api.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'dart:html';
// import 'dart:js_util' as js_util;
// import 'dart:js' as js;
// import 'dart:js' as js;

// void showNotification(String title, String body) {
//   if (js.context.hasProperty('Notification')) {
//     if (js.context['Notification']['permission'] == 'granted') {
//       var notificationOptions = {
//         'body': body
//       };
//       var notification = js.JsObject(js.context['Notification'], [title, notificationOptions]);
//       js.JsObject(notification)['show']();
//     } else {
//       js.context['Notification'].callMethod('requestPermission', []);
//     }
//   } else {
//     print('Notifications not supported');
//   }
// }

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  InBin().dependencies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      home: PushNotificationApp(
        camera: firstCamera,
      )
      // TakePictureScreen(
      //   camera: firstCamera,
      // ),
      ));
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
        print(
            'Message also contained a notification: ${message.notification!.body}');
        showDialog(
            context: context,
            builder: ((BuildContext context) {
              return DynamicDialog(
                  title: notification!.title, body: notification.body);
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
                "title": "Push Notification",
                "body": "Firebase  push notification"
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
      sendPushMessageToWeb();
      print("Sent...............................................");
      // ElegantNotification(
      //   title: Text('New Version'),
      //   description: Text("A new version is available to you please update."),
      //   icon: const Icon(
      //     Icons.access_alarm,
      //     color: Colors.orange,
      //   ),
      //   progressIndicatorColor: Colors.orange,
      // ).show(context);
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
            SizedBox(
              height: 40,
            ),
            ElevatedButton.icon(
              onPressed: () {
                // showNotification('Hello', 'This is a notification!');
                sendPushMessageToWeb();
                print("hello");
                // print(_token);
              },
              icon: const Icon(
                Icons.camera_alt_rounded,
              ),
              label: const Text(
                'Take a picture from Camera',
                style: TextStyle(
                    fontFamily: "Mukta",
                    height: 1.2,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700),
              ), // <-- Text
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

class DynamicDialog extends StatefulWidget {
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
