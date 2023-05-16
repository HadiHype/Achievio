import 'package:achievio/Navigation%20Pages/Group/submission_task.dart';
import 'package:achievio/Navigation%20Pages/Group/view_group.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTaskPage extends StatefulWidget {
  const UserTaskPage(
      {required this.uid,
      required this.groupPicture,
      required this.groupTitle,
      required this.groupDescription,
      Key? key})
      : super(key: key);

  final String uid;
  final String groupPicture;
  final String groupTitle;
  final String groupDescription;

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
        title: Text(widget.groupTitle), // replace with your group title
        actions: <Widget>[
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsPage(
                  groupId: widget.uid,
                  groupTitle: widget.groupTitle,
                  groupPicture: widget.groupPicture,
                  groupDescription: widget.groupDescription,
                ),
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.groupPicture), // replace with your group picture URL
            ),
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
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SubmissionPage(
                        taskId: document.id,
                        ugroupid: widget.uid,
                        taskTitle: data['title'],
                        numberOfAttachments: data['attachments'].length,
                      ),
                    ));
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
