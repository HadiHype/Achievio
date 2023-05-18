import 'package:achievio/Models/userinfo.dart';
import 'package:achievio/Navigation%20Pages/Group/view_submission_page.dart';
import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AdminTasksPage extends StatefulWidget {
  const AdminTasksPage(
      {required this.uid,
      required this.groupPicture,
      required this.adminName,
      required this.adminProfilePicture,
      Key? key})
      : super(key: key);

  final String uid;
  final String groupPicture;
  final String adminName;
  final String adminProfilePicture;

  @override
  // ignore: library_private_types_in_public_api
  _AdminTasksPageState createState() => _AdminTasksPageState();
}

class _AdminTasksPageState extends State<AdminTasksPage> {
  final _formKey = GlobalKey<FormState>();
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
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
        title: const Text('Assign Tasks'),
        backgroundColor: Color(0xBD569DC1),
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
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _taskTitleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter task title';
                }
                return null;
              },
              decoration: const InputDecoration(
                // isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                hintText: 'Task Title',
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
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(
                // isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                hintText: 'Task Description',
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter task description';
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              // initialValue: '$_points',
              decoration: const InputDecoration(
                // isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                hintText: 'Points',
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
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _points = int.tryParse(value) ?? _points;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points';
                }
                _points = int.tryParse(value) ?? _points;

                if (_points < 0 || _points > 20) {
                  return 'Points must be between 0 and 20';
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              // initialValue: '$_penalty',
              decoration: const InputDecoration(
                // isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                hintText: 'Penalty',
                suffixText: '%',
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
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  int? tempPenalty = int.tryParse(value);
                  if (tempPenalty != null &&
                      tempPenalty >= 0 &&
                      tempPenalty <= 100) {
                    _penalty = tempPenalty;
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter penalty';
                }
                int? penaltyValue = int.tryParse(value);
                if (penaltyValue == null ||
                    penaltyValue < 0 ||
                    penaltyValue > 100) {
                  return 'Penalty must be between 0 and 100';
                }
                return null;
              },
            ),
            ListTile(
              title: Text('Start Date: ${DateFormat.yMd().format(_startDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _startDate = selectedDate;

                    // If selected start date is after the currently selected end date
                    if (_startDate.isAfter(_endDate)) {
                      _endDate =
                          _startDate; // Set end date to be the same as start date
                    }
                  });
                }
              },
            ),
            ListTile(
              title: Text('End Date: ${DateFormat.yMd().format(_endDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      _endDate.isBefore(_startDate) ? _startDate : _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
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
              buttonText: const Text("Select Users"),
              title: const Text("Users"),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              buttonIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
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
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xBD569DC1)),
              ),
              child: const Text('Add Attachment'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _submit, // Disable button if submitting
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xBD569DC1)),
              ),
              child: const Text('Assign Task'),
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
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () {
            setState(() {
              _attachments.remove(attachment);
            });
          },
        ),
      );
    }).toList();
  }

  void _addAttachment() async {
    String? attachmentName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController attachmentNameController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Add Attachment'),
          content: TextFormField(
            controller: attachmentNameController,
            decoration:
                const InputDecoration(hintText: 'Enter attachment name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(attachmentNameController.text);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one attachment.'),
          ),
        );
        return;
      }
      if (_assignedToUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

            print('Assigned task to ${user.username}');
            print('Assigned task to ${user.profilePicture}');

            // Add a notification for this task assignment
            await firestore
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .doc(taskRef.id)
                .set({
              'createdAt': FieldValue.serverTimestamp(),
              'adminName': widget.adminName,
              'adminProfilePicture': widget.adminProfilePicture,
              'taskTitle': 'New Task: $taskTitle',
              'taskId': taskRef.id,
              // Add more fields as you need
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
        _endDate = DateTime.now().add(const Duration(days: 7));

        // Show a snackbar
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task successfully created!'),
          ),
        );
      } catch (e) {
        // Show an error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
