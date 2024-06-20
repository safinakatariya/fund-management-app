import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:fund_app/Screens/dashboard_screen.dart';
import 'package:fund_app/Screens/profile_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dashboard_screen.dart';
import 'signup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({Key? key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

// TextEditingController txtNumController = TextEditingController();
final otpController = TextEditingController();

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => SignupScreen(),
            ));
          },
        ),
        title: const Text(''),
        // backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 44.0),
                Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.0),
                Pinput(
                  length: 6,
                  showCursor: true,
                  controller: otpController,
                  defaultPinTheme: PinTheme(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(),
                      border: Border.all(
                        color: Colors.black54,
                      ),
                    ),
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  onSubmitted: (value) {
                    otpCode = value;
                    print('Entered OTP: $otpCode');
                  },
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 35.0),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: widget.verificationId,
                        smsCode: otpController.text,
                      );
                      await FirebaseAuth.instance
                          .signInWithCredential(credential);

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      String userMobileNumber =
                          prefs.getString('userMobileNumber') ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            mobileNumber: userMobileNumber,
                            mobileController: TextEditingController(),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Invalid OTP. Please try again.')),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
