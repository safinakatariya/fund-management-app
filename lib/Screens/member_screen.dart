import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<Member> members = [];

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      members.add(Member(
          firstName: data['name'],
          lastName: data['surname'],
          contactNumber: data['mobile'],
          imageUrl: data['imageUrl'])); // Add this
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(members[index].imageUrl),
            ),
            title:
                Text('${members[index].firstName} ${members[index].lastName}'),
            subtitle: Text(members[index].contactNumber),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () => launch("tel://${members[index].contactNumber}"),
            ),
          );
        },
      ),
    );
  }
}

class Member {
  final String firstName;
  final String lastName;
  final String contactNumber;
  final String imageUrl;

  Member({
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    required this.imageUrl,
  });
}
