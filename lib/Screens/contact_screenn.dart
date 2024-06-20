import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final String adminName = 'Ajay Umraliya';
  final String adminPhoneNumber = '+91 9913104650';
  final String adminEmail = 'ajayumraliya@gmail.com';
  final String adminImageUrl = 'https://picsum.photos/301/301';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(adminImageUrl),
            ),
            SizedBox(height: 20),
            Text(
              adminName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              adminEmail,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text('Email Admin'),
              onPressed: () => launch('mailto:$adminEmail'),
            ),
            SizedBox(height: 20),
            Text(
              adminPhoneNumber,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.call),
              label: Text('Call Admin'),
              onPressed: () => launch('tel:$adminPhoneNumber'),
            ),
          ],
        ),
      ),
    );
  }
}
