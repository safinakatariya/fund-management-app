import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fund_app/Screens/contact_screenn.dart';
import 'package:fund_app/model/push_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileImage_Provider.dart';
import 'fund_screen.dart';
import 'member_screen.dart';
import 'notification_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
// import 'FundPage.dart';
// import 'Members.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<Object> readDataFromFirebase(String mobileNumber) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot =
        await firestore.collection('users').doc(mobileNumber).get();
    return documentSnapshot.data() ?? {};
  }

  late FirebaseMessaging _messaging;
  int _totalNotifications = 0;
  late PushNotification _notificationInfo;
  String? imageUrl;
  var _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

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
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

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
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
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

        print('Attempting to add notification to Firestore');

        try {
          await firestore.collection('notifications').add({
            'title': message.notification?.title,
            'body': message.notification?.body
          }).catchError((error) {
            print('Error adding notification: $error');
          });
          print('Notification added to Firestore');
        } catch (e) {
          print('Error adding notification: $e');
        }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dashboard'),
        actions: <Widget>[
          Consumer<ProfileImageProvider>(
            builder: (context, imageProvider, child) {
              return InkWell(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? phoneNumber = prefs.getString('phoneNumber');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        fromDashboard: true,
                        mobileNumber: phoneNumber!,
                        mobileController: TextEditingController(),
                        // userId: 'user_id',
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: imageProvider.imageFile != null
                      ? FileImage(imageProvider.imageFile!)
                          as ImageProvider<Object>
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider<Object>,
                ),
              );
            },
          ),
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       DrawerHeader(
      //         child: Text('FUNDRAISER', style: TextStyle(color: Colors.white)),
      //         decoration: BoxDecoration(
      //           color: Colors.teal,
      //         ),
      //       ),
      //       ListTile(
      //         title: Text('Fund'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => FundScreen()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Members'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => MemberScreen()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Notifications'),
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => NotificationScreen()),
      //           );
      //         },
      //       ),
      //       Container(
      //         padding: EdgeInsets.symmetric(vertical: 350, horizontal: 60),
      //         child: ElevatedButton(
      //           onPressed: () async {
      //             await FirebaseAuth.instance.signOut();
      //             Navigator.of(context).pushReplacement(
      //               MaterialPageRoute(builder: (_) => SignupScreen()),
      //             );
      //           },
      //           child: Text(
      //             'Logout',
      //             style: TextStyle(
      //               fontSize: 20,
      //               fontWeight: FontWeight.bold,
      //               color: Colors.white,
      //             ),
      //           ),
      //           style: ButtonStyle(
      //             backgroundColor:
      //                 MaterialStateProperty.all<Color>(Colors.teal),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          buildCard(
            'assets/pay.jpg',
            'Pay now',
            () {
              var options = {
                'key': 'rzp_test_07PRXJIZ8eMLvf',
                'amount': 200 * 100, //in the smallest currency sub-unit.
                'name': 'Khodiyar Mandir',
                // 'order_id':
                //     'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
                'description': 'Fund',
                'timeout': 300,
                'theme': {'color': '#3399cc'},
                // 'prefill': {
                //   'contact': '9000090000',
                //   'email': 'gaurav.kumar@example.com'
                // }
              };
              _razorpay.open(options);
            },
          ),
          buildCard(
            'assets/members.jpg',
            'Members',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MemberScreen()),
              );
            },
          ),
          buildCard(
            'assets/fund.jpg',
            'View Fund',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FundScreen()),
              );
            },
          ),
          buildCard(
            'assets/notification.jpg',
            'Notifications',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
          buildCard('assets/admin.jpg', 'Contact Admin', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactScreen()),
            );
          })
        ],
      ),
      // ),
    );
  }
}

Widget buildCard(String imagePath, String text, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Center(
      child: Container(
        width: 180, // Set this to your desired width
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 18 / 11,
                child: Image.asset(imagePath, fit: BoxFit.fill),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(text,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
