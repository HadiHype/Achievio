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
  final List<dynamic> attachments;
  final String taskAdmin;

  const SubmissionPage({
    Key? key,
    required this.taskId,
    required this.ugroupid,
    required this.taskTitle,
    required this.numberOfAttachments,
    required this.attachments,
    required this.taskAdmin,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.taskTitle),
        backgroundColor: Color(0xBD569DC1),
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
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              // isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
        ),
        for (var i = 0; i < widget.numberOfAttachments; i++)

          // Display the attachment name and a button to pick an image
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.attachments[i].toString().toTitleCase(),
                style: const TextStyle(
                  decorationColor: Color(0xBD569DC1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ), // Display the attachment name
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xBD569DC1)),
                ),
                onPressed: () async {
                  final XFile? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      attachments[widget.attachments[i]] =
                          pickedImage; // Store the image against the attachment name
                    });
                  }
                },
                child: const Text('Pick an image'),
              ),
              if (attachments.containsKey(widget.attachments[
                  i])) // If an image has been picked for this attachment, display a preview
                Image.file(
                  File(attachments[widget.attachments[i]]!.path),
                  width: 100,
                  height: 100,
                ),
            ],
          ),
        ElevatedButton(
          onPressed: isSubmitting ? null : () => submitTask(),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xBD569DC1)),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget responseUI(Map<String, dynamic> responseData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Response: ${responseData['decision']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            'Note: ${responseData['note']}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget rejectUI(Map<String, dynamic> responseData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Response: ${responseData['decision']}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              )),
          Text(
            'Note: ${responseData['note']}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          // Add your re-upload UI here
          submissionUI(),
        ],
      ),
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
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isSubmitting = false; // End the submission process
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Overwrite'),
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

    //get the admin profile picture
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.taskAdmin)
        .get();

    // get the current user profile picture
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    // Add a notification for this task assignment
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.taskAdmin)
        .collection('notifications')
        .doc(groupRef.id)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
      'adminName': userSnapshot['username'],
      'adminProfilePicture': adminSnapshot['profilePicture'],
      'taskTitle':
          'New submission for ${widget.taskTitle} by ${userSnapshot['username']}',
      'taskId': widget.taskId,
    });

    // Optionally, navigate back to the previous screen
    // ignore: use_build_context_synchronously
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

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
