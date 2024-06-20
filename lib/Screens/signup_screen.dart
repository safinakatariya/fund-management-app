// import 'dart:html';
// import 'dart:js_util';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dashboard_screen.dart';
import 'otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fund_app/model/push_notification.dart';

// FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Store data in Firestore
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': message.notification?.title,
    'body': message.notification?.body,
    'data': message.data,
    'receivedAt': Timestamp.now(),
  });
}

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

TextEditingController txtNumController = TextEditingController();
final RegExp _regex = RegExp(r'^[0-9]{10}$');

Country selectedCountry = Country(
  phoneCode: "91",
  countryCode: "IN",
  e164Sc: 0,
  geographic: true,
  level: 1,
  name: "India",
  example: "India",
  displayName: "India",
  displayNameNoCountryCode: "IN",
  e164Key: "",
);

class _SignupScreenState extends State<SignupScreen> {
  late FirebaseMessaging _messaging;
  int _totalNotifications = 0;
  late PushNotification _notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    print(
        'User granted permission: ${settings.authorizationStatus == AuthorizationStatus.authorized}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Message Title: ${message.notification?.title}');

        //show the message into a pushnotification
        PushNotification notification = PushNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          dataTitle: message.data['title'] ?? '',
          dataBody: message.data['body'] ?? '',
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        if (_notificationInfo != null) {
          //For display the notification in overlay
          showSimpleNotification(
            Text(_notificationInfo.title),
            subtitle: Text(_notificationInfo.body ?? ''),
            background: Colors.teal,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined.');
    }
  }

  //for terminated mode
  checkForInitialMessage() async {
    await Firebase.initializeApp();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title ?? '',
        body: initialMessage.notification?.body ?? '',
        dataTitle: initialMessage.data['title'] ?? '',
        dataBody: initialMessage.data['body'] ?? '',
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();

    //For background mode (Not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        dataTitle: message.data['title'] ?? '',
        dataBody: message.data['body'] ?? '',
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

    super.initState();
  }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+${selectedCountry.phoneCode}$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => OtpScreen(verificationId: verificationId),
        ));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('hasSignedUp', true);
        prefs.setString(phoneNumber, txtNumController.text);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    txtNumController.selection = TextSelection.fromPosition(
        TextPosition(offset: txtNumController.text.length));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 44.0),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextFormField(
                    controller: txtNumController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        txtNumController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: EdgeInsets.all(15.0),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                                context: context,
                                countryListTheme: CountryListThemeData(
                                    bottomSheetHeight: 550),
                                onSelect: (value) {
                                  setState(() {
                                    selectedCountry = value;
                                  });
                                });
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      suffixIcon: txtNumController.text.length == 10
                          ? Container(
                              height: 15,
                              width: 15,
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                              child: Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 15,
                              ),
                            )
                          : null,
                      label: Text(
                        'Enter your mobile number',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black,
                            width: BorderSide.strokeAlignCenter,
                            style: BorderStyle.solid),
                      ),
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  SizedBox(height: 26.0),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'phoneNumber', txtNumController.text);
                      if (!_regex.hasMatch(txtNumController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Enter a valid mobile number'),
                        ));
                        return;
                      }
                      print("Get Otp");
                      _verifyPhoneNumber(txtNumController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: Text(
                      'Get OTP',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 80.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
