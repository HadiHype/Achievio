import 'dart:io';
import 'package:achievio/Models/userinfo.dart';
import 'package:achievio/User%20Interface/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../User Interface/app_colors.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DescribeGroup extends StatefulWidget {
  const DescribeGroup(this.usersOfGroup, {super.key});

  final List<UserData> usersOfGroup;

  @override
  State<DescribeGroup> createState() => _DescribeGroupState();
}

class _DescribeGroupState extends State<DescribeGroup> {
  File? _pickedImage;

  FocusNode focusNode = FocusNode();
  TextEditingController groupNameController = TextEditingController();

  FocusNode focusNodeTextArea = FocusNode();
  TextEditingController groupDescriptionController = TextEditingController();

  bool showSpinner = false;

  // Firebase Auth instance and Firestore
  final authUser = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;

  // Logged in user
  User? user = FirebaseAuth.instance.currentUser;

  // Keys
  final _formKey = GlobalKey<FormState>();

  void _pickImageCamera() async {
    // pick image from camera and save it to the file system cache and then to the gallery of the phone
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 60);
    final pickedImageFile = File(pickedImage!.path);

    setState(() {
      saveImage(pickedImageFile);
      _pickedImage = pickedImageFile;
    });

    // ignore: use_build_context_synchronously
    Navigator.canPop(context);
  }

  Future<void> saveImage(File imageFile) async {
    if (await Permission.storage.request().isGranted &&
        await Permission.photos.request().isGranted &&
        await Permission.camera.request().isGranted &&
        await Permission.mediaLibrary.request().isGranted) {
      // rotate image
      await FlutterExifRotation.rotateAndSaveImage(path: imageFile.path);

      // try catch was removed -- may cause issues

      // compress rotated file
      await FlutterImageCompress.compressWithFile(
        imageFile.path,
        format: CompressFormat.jpeg,
      );

      // convert to bytes
      final bytes = imageFile.readAsBytesSync();

      // save to gallery
      await ImageGallerySaver.saveImage(
        bytes,
        name: 'achievio',
      );
    }
  }

  void _pickImageGallery() async {
    // pick image from gallery and save it to the file system cache and then to the gallery of the phone
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
      saveImage(pickedImageFile);
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _remove() {
    // remove image from the file system cache and from the gallery of the phone
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Describe your group',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          elevation: 1,
          backgroundColor: kTertiaryColor,
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // create a form that takes in image input, group name, group description
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select an image'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      _pickImageCamera();
                                    },
                                    child: const ListTile(
                                      title: Text('Camera'),
                                      leading: Icon(Icons.camera_alt_rounded),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _pickImageGallery,
                                    child: const ListTile(
                                      title: Text('Gallery'),
                                      leading: Icon(Icons.photo_album_rounded),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _remove,
                                    child: const ListTile(
                                      title: Text('Remove'),
                                      leading: Icon(Icons.delete_rounded),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Stack(
                      children: _pickedImage == null
                          ? [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: kGreyColor,
                                  borderRadius: BorderRadius.circular(70),
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ]
                          : [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircleAvatar(
                                  radius: 90,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: _pickedImage == null
                                      ? null
                                      : FileImage(_pickedImage!),
                                ),
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      focusNode: focusNode,
                      controller: groupNameController,
                      onTapOutside: ((event) => focusNode.unfocus()),
                      decoration: const InputDecoration(
                        // isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        hintText: 'Group Name',
                        hintStyle: TextStyle(
                          color: Colors.black,
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
                      maxLength: 50,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      focusNode: focusNodeTextArea,
                      controller: groupDescriptionController,
                      onTapOutside: ((event) => focusNodeTextArea.unfocus()),
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      maxLength: 248,
                      decoration: const InputDecoration(
                        // isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        hintText: 'Group Description',
                        hintStyle: TextStyle(
                          color: Colors.black,
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
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _pickedImage != null) {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            // add the group information to firebase firestore database
                            Reference ref = FirebaseStorage.instance
                                .ref()
                                .child('groupProfilePics')
                                .child(
                                    '${FirebaseAuth.instance.currentUser?.uid}'
                                    '${DateTime.now()}');

                            UploadTask uploadTask = ref.putFile(_pickedImage!);
                            final snapshot =
                                await uploadTask.whenComplete(() => null);

                            final downloadUrl =
                                await snapshot.ref.getDownloadURL();

                            var db = FirebaseFirestore.instance;

                            DocumentReference groupRef =
                                await db.collection('groups').add({
                              'title': groupNameController.text,
                              'admins': [
                                FirebaseAuth.instance.currentUser?.uid
                              ],
                              'description': groupDescriptionController.text,
                              'profilePic': downloadUrl,
                              'createdBy':
                                  FirebaseAuth.instance.currentUser?.uid,
                              'createdAt': DateTime.now(),
                              // 'uid': ,
                            });

                            // Add a task to the Tasks sub-collection
                            await groupRef.collection('Tasks').add({
                              'assignedBy':
                                  FirebaseAuth.instance.currentUser?.uid,
                              'title': 'Welcome to the group!',
                              'assignedTo': [
                                FirebaseAuth.instance.currentUser?.uid
                              ],
                              'startDate': DateTime.now(),
                              'endDate':
                                  DateTime.now().add(const Duration(days: 7)),
                              'Points': 10,
                              'Penalty': 5,
                              'note': 'Task Note',
                              'description': 'Task Description',
                              'attachments': ['Attachment 1', 'Attachment 2']
                            });

                            for (int i = 0;
                                i < widget.usersOfGroup.length;
                                i++) {
                              await groupRef
                                  .collection('users')
                                  .doc(widget.usersOfGroup[i].uid)
                                  .set({
                                'uid': widget.usersOfGroup[i].uid,
                                'username': widget.usersOfGroup[i].username,
                                'points': 0,
                                'profilePicture':
                                    widget.usersOfGroup[i].profilePicture,
                              });
                            }

                            // add the group to the user's list of groups in the database
                            await db
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .collection('groups')
                                .add({
                              'groupID': groupRef.id,
                              'title': groupNameController.text,
                              'admins': [
                                FirebaseAuth.instance.currentUser?.uid
                              ],
                              'description': groupDescriptionController.text,
                              'profilePic': downloadUrl,
                              'starred': false,
                              'visible': true,
                              'isArchived': false,
                              'index': groupCards.length,
                            });

                            // add the group to the friends' list of groups in the database
                            for (int i = 0;
                                i < widget.usersOfGroup.length;
                                i++) {
                              await db
                                  .collection('users')
                                  .doc(widget.usersOfGroup[i].uid)
                                  .collection('groups')
                                  .add({
                                'groupID': groupRef.id,
                                'title': groupNameController.text,
                                'admins': [
                                  FirebaseAuth.instance.currentUser?.uid
                                ],
                                'description': groupDescriptionController.text,
                                'profilePic': downloadUrl,
                                'starred': false,
                                'visible': true,
                                'isArchived': false,
                                'index': groupCards.length,
                              });
                            }
                            if (mounted) {
                              defined = false;

                              groupCards.clear();
                              groupCardsArchived.clear();

                              Navigator.popAndPushNamed(
                                context,
                                '/nav',
                              );
                            }
                            // ignore: empty_catches
                          } catch (e) {}

                          setState(() {
                            showSpinner = false;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill all the fields and add a profile picture',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: kSecondaryColor,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: kTertiaryColor,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width:
                        widget.usersOfGroup.length >= 6 ? double.infinity : 300,
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: widget.usersOfGroup.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                    widget.usersOfGroup[i].profilePicture ??
                                        ""),
                              ),
                              Text(
                                widget.usersOfGroup[i].username ?? "",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
