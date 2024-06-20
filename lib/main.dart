// import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fund_app/Screens/splash_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'Screens/ProfileImage_Provider.dart';
// import 'Screens/signup_screen.dart';
import 'firebase_options.dart';
import 'model/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background Message: ${message.messageId}");

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    PushNotification notification = PushNotification(
        title: initialMessage.notification?.title ?? '',
        body: initialMessage.notification?.body ?? '',
        dataTitle: initialMessage.data['title'] ?? '',
        dataBody: initialMessage.data['body'] ?? '');
  }
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProfileImageProvider(),
      child: MyApp(),
    ),
  );

  //For handling the notifications in Terminated state.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  User? user;
  //for overlay suppoirt
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    _firebaseMessaging.getToken().then((token) {
      print("Firebase Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //For incoming messages
      print("Received Message: ${message.notification?.body}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
