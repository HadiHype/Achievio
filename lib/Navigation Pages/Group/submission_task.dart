import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class SubmissionPage extends StatefulWidget {
  final String taskId;
  final String ugroupid;
  final String taskTitle;
  final int numberOfAttachments;

  const SubmissionPage(
      {Key? key,
      required this.taskId,
      required this.ugroupid,
      required this.taskTitle,
      required this.numberOfAttachments})
      : super(key: key);

  @override
  _SubmissionPageState createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  TextEditingController noteController = TextEditingController();
  // List<XFile> images = [];
  Map<String, XFile> attachments = {};
  bool isSubmitting = false;

  Future<DocumentSnapshot?> getResponse() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('taskResponse')
        .doc(widget.taskId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskTitle),
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: getResponse(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> responseData =
                snapshot.data!.data() as Map<String, dynamic>;
            if (responseData['decision'] == 'Rejected') {
              return rejectUI(responseData);
            } else {
              return responseUI(responseData);
            }
          } else {
            return submissionUI();
          }
        },
      ),
    );
  }

  Widget submissionUI() {
    return Column(
      children: <Widget>[
        // Your submission UI code here
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
        ),
        for (var i = 0; i < widget.numberOfAttachments; i++)
          Row(
            children: [
              Text('Attachment ${i + 1}'), // Display the attachment name
              ElevatedButton(
                child: Text('Add Image'),
                onPressed: () async {
                  final XFile? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      attachments['Attachment ${i + 1}'] =
                          pickedImage; // Store the image against the attachment name
                    });
                  }
                },
              ),
              if (attachments.containsKey(
                  'Attachment ${i + 1}')) // If an image has been picked for this attachment, display a preview
                Image.file(
                  File(attachments['Attachment ${i + 1}']!.path),
                  width: 100,
                  height: 100,
                ),
            ],
          ),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: isSubmitting ? null : () => submitTask(),
        ),
      ],
    );
  }

  Widget responseUI(Map<String, dynamic> responseData) {
    return Column(
      children: <Widget>[
        Text('Response: ${responseData['decision']}'),
        Text('Note: ${responseData['note']}'),
      ],
    );
  }

  Widget rejectUI(Map<String, dynamic> responseData) {
    return Column(
      children: <Widget>[
        Text('Response: ${responseData['decision']}'),
        Text('Note: ${responseData['note']}'),
        // Add your re-upload UI here
        submissionUI(),
      ],
    );
  }

  Future<void> submitTask() async {
    setState(() {
      isSubmitting = true; // Start the submission process
    });

    DocumentReference taskRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.ugroupid) // Use actual group id
        .collection('submittedTasks')
        .doc(widget.taskId);

    DocumentSnapshot snapshot = await taskRef.get();
    if (snapshot.exists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Overwrite Submission?'),
            content: const Text(
                'You have already submitted this task. Do you want to overwrite your previous submission?'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isSubmitting = false; // End the submission process
                  });
                },
              ),
              ElevatedButton(
                child: Text('Overwrite'),
                onPressed: () {
                  Navigator.of(context).pop();
                  proceedWithSubmission();
                },
              ),
            ],
          );
        },
      );
    } else {
      proceedWithSubmission();
    }
  }

  Future<void> proceedWithSubmission() async {
    Map<String, String> imageURLs = {};

    // Iterate over each image file
    for (var entry in attachments.entries) {
      String imageURL = await uploadImageToFirebase(entry.value);
      imageURLs[entry.key] = imageURL;
    }

    DocumentReference groupRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.ugroupid) // Use actual group id
        .collection('submittedTasks')
        .doc(widget.taskId);

    // Save the data to Firestore
    await groupRef.set({
      'taskTitle': widget.taskTitle,
      'note': noteController.text,
      'submittedBy': FirebaseAuth.instance.currentUser?.uid,
      'attachments': imageURLs,
    }, SetOptions(merge: true));

    // Optionally, navigate back to the previous screen
    Navigator.of(context).pop();

    setState(() {
      isSubmitting = false; // End the submission process
    });
  }

  Future<String> uploadImageToFirebase(XFile image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('submissions')
        .child('${DateTime.now().toIso8601String()}.jpg');

    await ref.putFile(File(image.path));

    return await ref.getDownloadURL();
  }
}
