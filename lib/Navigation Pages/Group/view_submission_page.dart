import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewSubmissionsPage extends StatefulWidget {
  final String groupId;

  const ViewSubmissionsPage({required this.groupId, Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ViewSubmissionsPageState createState() => _ViewSubmissionsPageState();
}

class _ViewSubmissionsPageState extends State<ViewSubmissionsPage> {
  Future<void> _respondToSubmission({
    required String decision,
    required String submittedBy,
    required String taskId,
  }) async {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$decision Submission'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a note for your decision:'),
              SizedBox(height: 10),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  // isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  hintText: 'Note',
                  hintStyle: TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),

                  fillColor: Color(0xFFF5F5F5),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(submittedBy)
                    .collection('taskResponse')
                    .doc(taskId)
                    .set({
                  'decision': decision,
                  'note': noteController.text,
                  'taskId': taskId,
                });

                // get the task and add points to the user if accepted
                if (decision == 'Accepted') {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('Tasks')
                      .doc(taskId)
                      .get()
                      .then((value) async {
                    var points = await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('users')
                        .doc(submittedBy)
                        .get()
                        .then((value) => value.data()!['points']);

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('users')
                        .doc(submittedBy)
                        .update({
                      'points': FieldValue.increment(points),
                    });
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('Tasks')
                      .doc(taskId)
                      .get()
                      .then((value) async {
                    // get the user's points and multiply by the penalty
                    var points = await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('users')
                        .doc(submittedBy)
                        .get()
                        .then((value) => value.data()!['points']);

                    double penalty =
                        points - (value.data()!['Penalty'] / 100 * points);
                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(widget.groupId)
                        .collection('users')
                        .doc(submittedBy)
                        .update({
                      'points': penalty,
                    });
                  });
                }

                // Delete the submission from the group
                await FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('submittedTasks')
                    .doc(taskId)
                    .delete();

                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference submissions = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('submittedTasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Submissions'),
        backgroundColor: const Color(0xBD569DC1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: submissions.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const CircularProgressIndicator();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['submittedBy'])
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("");
                  }

                  Map<String, dynamic> userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  String username = userData[
                      'username']; // replace 'username' with the correct field name in your Firestore

                  return ListTile(
                    title: Text(data['taskTitle']),
                    subtitle: Text('Submitted by: $username'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _respondToSubmission(
                              decision: 'Accepted',
                              submittedBy: data['submittedBy'],
                              taskId: document.id,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _respondToSubmission(
                              decision: 'Rejected',
                              submittedBy: data['submittedBy'],
                              taskId: document.id,
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      //... remaining code
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Attachments for ${data['taskTitle']}'),
                            content: SizedBox(
                              height: 300, // adjust the height to your needs
                              width: double.maxFinite,
                              child: ListView(
                                children: List<Widget>.from(
                                    data['attachments'].entries.map((entry) {
                                  return ListTile(
                                    title: Text(entry.key),
                                    leading: Image.network(entry.value),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ImageDisplayPage(
                                                  imageUrl: entry.value),
                                        ),
                                      );
                                    },
                                  );
                                }).toList()),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ImageDisplayPage extends StatelessWidget {
  final String imageUrl;

  const ImageDisplayPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
