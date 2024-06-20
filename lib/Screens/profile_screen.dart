// ignore_for_file: body_might_complete_normally_nullable

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fund_app/Screens/dashboard_screen.dart';
import 'package:fund_app/Screens/otp_screen.dart';
import 'package:fund_app/Screens/signup_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileImage_Provider.dart';

class ProfileScreen extends StatefulWidget {
  final bool fromDashboard;
  final String mobileNumber;
  final Map<String, dynamic>? userData;

  ProfileScreen({
    required this.mobileNumber,
    this.fromDashboard = false,
    // required String userId,
    required TextEditingController mobileController,
    this.userData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  // TextEditingController mobileController = TextEditingController();
  TextEditingController txtNumController = TextEditingController();
  File? _imageFile;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  late DocumentSnapshot userData;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> signInWithPhoneNumber(
      String phoneNumber) async {
    Map<String, dynamic>? userData;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Check if a document with the user's mobile number exists
          DocumentReference docRef =
              FirebaseFirestore.instance.collection('users').doc(phoneNumber);

          DocumentSnapshot docSnapshot = await docRef.get();

          if (docSnapshot.exists) {
            // Document exists, fetch data
            userData = docSnapshot.data() as Map<String, dynamic>;
            print("Fetched Data: $userData"); // Check if data is fetched
          } else {
            // Document does not exist, create a new one
            await docRef.set({
              'mobile': phoneNumber,
              // Add other fields as necessary
            });
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e);
      },
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return userData;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchPhoneNumber();

    // print(imageUrl);
    if (txtNumController.text.isNotEmpty) {
      signInWithPhoneNumber(txtNumController.text).then((userData) {
        if (userData != null) {
          nameController.text = userData['name'] ?? '';
          surnameController.text = userData['surname'] ?? '';
          txtNumController.text = userData['mobile'] ?? '';
          imageUrl = userData['imageUrl'] ?? '';
        }
      });
    } else {
      print("Phone number is empty");
    }
  }

  Future<void> fetchPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phoneNumber');
    if (phoneNumber != null) {
      txtNumController.text = phoneNumber;
    }
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        print("Fetched Data: $data"); // Check if data is fetched
        setState(() {
          nameController.text = data['name'];
          surnameController.text = data['surname'];
          txtNumController.text = data['mobile'];
          // Assuming you have a controller for the imageUrl
          imageUrl = data['imageUrl'];
        });
      } else {
        print("Document does not exist.");
      }
    } else {
      print("PhoneNumber is null");
    }
    FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(phoneNumber).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Image.network(data['imageUrl']);
        }

        return Text("loading");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: widget.fromDashboard
            ? [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // if (imageUrl != null) Image.network(imageUrl!),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (imageUrl != null
                              ? NetworkImage(imageUrl!)
                              : AssetImage('assets/default_avatar.png'))
                          as ImageProvider,
                ),
                ElevatedButton(
                  child: Text('Add Photo'),
                  onPressed: () async {
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      if (pickedFile != null) {
                        _imageFile = File(pickedFile.path);
                        Provider.of<ProfileImageProvider>(context,
                                listen: false)
                            .imageFile = _imageFile;
                      }
                    });
                  },
                ),
                SizedBox(height: 40),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: surnameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your surname',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your surname';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: 350,
                  child: TextFormField(
                    controller: txtNumController,
                    decoration: InputDecoration(
                      hintText: 'Enter your mobile number',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 55),
                Container(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString(
                            'mobileNumber', txtNumController.text);
                        await prefs.setString(
                            'userMobileNumber', txtNumController.text);

                        String imageUrl = _imageFile != null
                            ? await uploadImageToFirebase(context)
                            : ''; // Use a default image URL or leave it empty

                        String? mobileNumber = prefs.getString('mobileNumber');
                        print('userDocId: $mobileNumber'); // Add this line

                        try {
                          DocumentSnapshot docSnapshot = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .doc(mobileNumber)
                              .get();

                          if (docSnapshot.exists) {
                            Map<String, dynamic> updatedData = {
                              'name': nameController.text,
                              'surname': surnameController.text,
                              'mobile': txtNumController.text,
                            };

                            if (_imageFile != null) {
                              String imageUrl =
                                  await uploadImageToFirebase(context);
                              updatedData['imageUrl'] =
                                  imageUrl; // Update imageUrl only if _imageFile is not null
                            }

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(mobileNumber)
                                .update(updatedData);
                          } else {
                            String imageUrl = _imageFile != null
                                ? await uploadImageToFirebase(context)
                                : ''; // Use a default image URL or leave it empty

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(mobileNumber)
                                .set({
                              'name': nameController.text,
                              'surname': surnameController.text,
                              'mobile': txtNumController.text,
                              'imageUrl':
                                  imageUrl, // Ensure imageUrl is included
                            }, SetOptions(merge: true));
                          }
                        } catch (e) {
                          print("Error: $e");
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen()),
                        );
                      }
                    },
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadImageToFirebase(BuildContext context) async {
    // ignore: unused_local_variable
    String fileName = basename(_imageFile!.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(
        "Profile Image/" + DateTime.now().millisecondsSinceEpoch.toString());
    UploadTask uploadTask = ref.putFile(_imageFile!);
    await uploadTask.whenComplete(() => null);
    String returnURL = "";
    await ref.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }
}
