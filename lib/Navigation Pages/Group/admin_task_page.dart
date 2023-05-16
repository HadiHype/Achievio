import 'package:achievio/Models/userinfo.dart';
import 'package:achievio/Navigation%20Pages/Group/view_submission_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AdminTasksPage extends StatefulWidget {
  const AdminTasksPage(
      {required this.uid, required this.groupPicture, Key? key})
      : super(key: key);

  final String uid;
  final String groupPicture;

  @override
  _AdminTasksPageState createState() => _AdminTasksPageState();
}

class _AdminTasksPageState extends State<AdminTasksPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  List<UserData?> _assignedToUsers = [];
  List<String> _attachments = [];

  bool _isSubmitting = false;

  int _points = 10;
  int _penalty = 5;

  // Mock user data, replace with actual data from Firestore
  List<UserData> usersOfGroup = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    // replace 'yourGroupId' with the actual group ID
    QuerySnapshot snapshot = await firestore
        .collection('groups')
        .doc(widget.uid)
        .collection('users')
        .get();
    setState(() {
      usersOfGroup = snapshot.docs
          .map((doc) => UserData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Tasks'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ViewSubmissionsPage(
                  groupId: widget.uid,
                );
              }));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.groupPicture), // replace with your group picture URL
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _taskTitleController,
              decoration: InputDecoration(labelText: 'Task Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter task title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter task description';
                }
                return null;
              },
            ),
            ListTile(
              title: Text('Start Date: ${DateFormat.yMd().format(_startDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _startDate = selectedDate;
                  });
                }
              },
            ),
            ListTile(
              title: Text('End Date: ${DateFormat.yMd().format(_endDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _endDate = selectedDate;
                  });
                }
              },
            ),
            MultiSelectBottomSheetField<UserData?>(
              initialChildSize: 0.4,
              listType: MultiSelectListType.CHIP,
              searchable: true,
              buttonText: Text("Select Users"),
              title: Text("Users"),
              items: usersOfGroup
                  .map(
                      (user) => MultiSelectItem<UserData>(user, user.username!))
                  .toList(),
              onConfirm: (List<UserData?> values) {
                setState(() {
                  _assignedToUsers = values;
                });
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) {
                  setState(() {
                    _assignedToUsers.remove(value);
                  });
                },
              ),
            ),
            ..._buildAttachments(),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _addAttachment, // Disable button if submitting
              child: Text('Add Attachment'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _submit, // Disable button if submitting
              child: Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAttachments() {
// Replace with more sophisticated UI and logic for attachments
    return _attachments.map((attachment) {
      return ListTile(
        title: Text(attachment),
      );
    }).toList();
  }

  void _addAttachment() async {
    String? attachmentName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _attachmentNameController =
            TextEditingController();
        return AlertDialog(
          title: Text('Add Attachment'),
          content: TextFormField(
            controller: _attachmentNameController,
            decoration: InputDecoration(hintText: 'Enter attachment name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_attachmentNameController.text);
              },
            ),
          ],
        );
      },
    );
    if (attachmentName != null && attachmentName.isNotEmpty) {
      setState(() {
        _attachments.add(attachmentName);
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_attachments.isEmpty) {
        print(_attachments);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add at least one attachment.'),
          ),
        );
        return;
      }
      if (_assignedToUsers.isEmpty) {
        print(_assignedToUsers);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please assign to at least one user.'),
          ),
        );
        return;
      }

      // Disable the submit button
      setState(() {
        _isSubmitting = true;
      });

      try {
        String taskTitle = _taskTitleController.text;
        String taskDescription = _taskDescriptionController.text;

        DocumentReference groupRef =
            firestore.collection('groups').doc(widget.uid);

        DocumentReference taskRef = await groupRef.collection('Tasks').add({
          'assignedBy': FirebaseAuth.instance.currentUser?.uid,
          'title': taskTitle,
          'assignedTo': _assignedToUsers
              .where((user) => user != null)
              .map((user) => user!.uid)
              .toList(),
          'startDate': _startDate,
          'endDate': _endDate,
          'Points': _points,
          'Penalty': _penalty,
          'note': 'Task Note',
          'description': taskDescription,
          'attachments': _attachments,
        });

        // Update the task in each assigned user's tasks collection
        for (UserData? user in _assignedToUsers) {
          if (user != null) {
            await firestore
                .collection('users')
                .doc(user.uid)
                .collection('tasks')
                .doc(taskRef.id)
                .set({
              'title': taskTitle,
              'description': taskDescription,
              'startDate': _startDate,
              'endDate': _endDate,
              'assignedBy': FirebaseAuth.instance.currentUser?.uid,
              'points': _points,
              'penalty': _penalty,
              'attachments': _attachments,
            });
          }
        }

        // Reset the form and non-form fields
        _formKey.currentState!.reset();
        _taskTitleController.clear();
        _taskDescriptionController.clear();
        _assignedToUsers = [];
        _attachments = [];
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(Duration(days: 7));

        // Show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task successfully created!'),
          ),
        );
      } catch (e) {
        // Show an error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task. Please try again.'),
          ),
        );
      } finally {
        // Enable the submit button
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
