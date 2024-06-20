import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> storeProfileData(String name, String surname, String imageUrl) async {
  CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');

  return profiles
      .add({
    'name': name,
    'surname': surname,
    'imageUrl': imageUrl,
  })
      .then((value) => print("Profile Added"))
      .catchError((error) => print("Failed to add profile: $error"));
}