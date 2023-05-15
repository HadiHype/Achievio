import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTaskPage extends StatefulWidget {
  const UserTaskPage({required this.uid, required this.groupPicture, Key? key})
      : super(key: key);

  final String uid;
  final String groupPicture;

  @override
  State<UserTaskPage> createState() => _UserTaskPageState();
}

class _UserTaskPageState extends State<UserTaskPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Group Title'), // replace with your group title
        actions: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                widget.groupPicture), // replace with your group picture URL
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.uid) // replace with your groupID
            .collection('Tasks')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          if (snapshot.data!.docs.isEmpty) {
            return Text(widget.uid);
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['description']),
                trailing: IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: () {
                    // put your file upload logic here
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
