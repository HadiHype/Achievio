import 'dart:io';

import 'package:achievio/Navigation%20Pages/navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../User Interface/app_colors.dart';
import '../Authentication Logic/auth_logic.dart';

class AdditionalSignUpScreen extends StatefulWidget {
  const AdditionalSignUpScreen(
      {required this.email,
      required this.password,
      required this.uid,
      super.key});

  final String email;
  final String password;
  final String uid;

  @override
  State<AdditionalSignUpScreen> createState() => _AdditionalSignUpScreenState();
}

enum Gender { male, female, other, preferNotToSay }

class _AdditionalSignUpScreenState extends State<AdditionalSignUpScreen> {
  // firebase auth
  final _auth = FirebaseAuth.instance;
  final Auth auth = Auth();

  // keys
  final _formKey = GlobalKey<FormState>();

  // focus nodes
  final FocusNode focusNodeDateOfBirth = FocusNode();

  // controllers
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode focusNodeUsername = FocusNode();

  // booleans
  bool showSpinner = false;

  // Image saver functions and variables
  File? _pickedImage;

  void _pickImageCamera() async {
    // pick image from camera and save it to the file system cache and then to the gallery of the phone
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 10);
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
      // await FlutterImageCompress.compressWithFile(
      //   imageFile.path,
      //   format: CompressFormat.jpeg,
      //   quality: 15,
      // );

      // convert to bytes
      final bytes = imageFile.readAsBytesSync();
      String imageName =
          _auth.currentUser!.metadata.toString() + DateTime.now().toString();
      // save to gallery
      await ImageGallerySaver.saveImage(
        bytes,
        name: imageName,
        quality: 15,
      );
    }
  }

  void _pickImageGallery() async {
    // pick image from gallery and save it to the file system cache and then to the gallery of the phone
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
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

  final DateTime _dateOfBirthTime = DateTime.now();
  Gender? _gender;
  String username = '';
  bool? valid;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SizedBox(
            height: screenHeight - keyboardHeight,
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: InkWell(
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
                                          leading:
                                              Icon(Icons.camera_alt_rounded),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _pickImageGallery,
                                        child: const ListTile(
                                          title: Text('Gallery'),
                                          leading:
                                              Icon(Icons.photo_album_rounded),
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
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4169E1)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(100),
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
                                    width: 160,
                                    height: 160,
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
                    ),

                    const SizedBox(
                      height: 24.0,
                    ),

                    const Text(
                      'Additional Information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4169E1),
                      ),
                    ),

                    const SizedBox(
                      height: 36.0,
                    ),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Text form field that opens a calendar to select a date of birth
                          TextFormField(
                            controller: _dateOfBirthController,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              return null;
                            },
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirthTime,
                                  firstDate: DateTime(1900, 1),
                                  lastDate: DateTime.now(),
                                  fieldHintText: 'Date of Birth',
                                  fieldLabelText: 'Date of Birth',
                                  keyboardType: TextInputType.text,
                                  builder: (context, child) => Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color(0xFF4169E1),
                                          ),
                                        ),
                                        child: child!,
                                      ));
                              if (picked != null) {
                                setState(() {
                                  _dateOfBirthController.text =
                                      DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              // isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              hintText: '01/01/2002',
                              hintStyle: TextStyle(
                                color: Colors.black45,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.black,
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

                          const SizedBox(
                            height: 24.0,
                          ),
                          // pick the users gender
                          TextFormField(
                            readOnly: true,
                            controller: _genderController,
                            decoration: const InputDecoration(
                              // isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              hintText: 'Gender',
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
                            onTap: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    bool isOther = false;

                                    if (_gender == Gender.other) {
                                      isOther = true;
                                      _genderController.text = '';
                                    }
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return AlertDialog(
                                        title: const Text('Gender'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: const Text('Female'),
                                                leading: Radio<Gender>(
                                                  value: Gender.female,
                                                  groupValue: _gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _gender = value;
                                                      _genderController.text =
                                                          value
                                                              .toString()
                                                              .split('.')[1];
                                                      isOther = false;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: const Text('Male'),
                                                leading: Radio<Gender>(
                                                  value: Gender.male,
                                                  groupValue: _gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _gender = value;
                                                      _genderController.text =
                                                          value
                                                              .toString()
                                                              .split('.')[1];
                                                      isOther = false;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: const Text('Other'),
                                                leading: Radio<Gender>(
                                                  value: Gender.other,
                                                  groupValue: _gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _gender = value;
                                                      isOther = true;
                                                    });
                                                  },
                                                ),
                                              ),
                                              if (isOther)
                                                Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 30),
                                                  child: TextField(
                                                    controller:
                                                        _genderController,
                                                    onChanged: (value) {
                                                      setState(() {});
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          "Please specify",
                                                    ),
                                                  ),
                                                ),
                                              ListTile(
                                                title: const Text(
                                                    'Prefer not to say'),
                                                leading: Radio<Gender>(
                                                  value: Gender.preferNotToSay,
                                                  groupValue: _gender,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _gender = value;
                                                      _genderController.text =
                                                          "Prefer not to say";
                                                      isOther = false;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: _genderController
                                                        .text.isNotEmpty
                                                    ? () {
                                                        Navigator.pop(context);
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4169E1),
                                                ),
                                                child: const Text('Done'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  });
                            },
                          ),

                          const SizedBox(
                            height: 24.0,
                          ),
                          TextFormField(
                            controller: _usernameController,
                            focusNode: focusNodeUsername,
                            onTapOutside: (event) =>
                                focusNodeUsername.unfocus(),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter username';
                              } else {
                                if (!RegExp(r'^[a-zA-Z0-9]+$')
                                    .hasMatch(value)) {
                                  return 'Please enter valid username';
                                }
                              }

                              if (!valid!) {
                                return 'Username already taken';
                              }

                              return null;
                            },
                            onChanged: (value) async {
                              username = value;
                              var result = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('username', isEqualTo: username)
                                  .get();

                              if (result.docs.isEmpty) {
                                valid = true;
                              } else {
                                valid = false;
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              hintText: 'achievio',
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

                          const SizedBox(
                            height: 24.0,
                          ),
                          ElevatedButton(
                            onPressed: username != "" &&
                                    _genderController.text != "" &&
                                    _dateOfBirthController.text != "" &&
                                    _pickedImage != null
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      try {
                                        // upload image to firebase storage

                                        Reference ref = FirebaseStorage.instance
                                            .ref()
                                            .child('profilePictures')
                                            .child(
                                                '${FirebaseAuth.instance.currentUser?.uid}');

                                        // UploadTask uploadTask =
                                        //     ref.putFile(_pickedImage!);
                                        // final snapshot = await uploadTask
                                        //     .whenComplete(() => null);

                                        // final downloadUrl =
                                        //     await snapshot.ref.getDownloadURL();

                                        var db = FirebaseFirestore.instance;

                                        await db
                                            .collection('users')
                                            .doc(widget.uid)
                                            .set({
                                          'email': widget.email,
                                          'password': widget.password,
                                          'uid': widget.uid,
                                          'gender': _genderController.text,
                                          'dateofbirth':
                                              _dateOfBirthController.text,
                                          'username': username,
                                          // 'profilePicture': downloadUrl,
                                          'friends': [],
                                          'dateCreated':
                                              DateTime.now().toString(),
                                          'dateUpdated':
                                              DateTime.now().toString(),
                                          'dateLastLogin':
                                              DateTime.now().toString(),
                                        });

                                        // await db
                                        //     .collection('users')
                                        //     .doc(_auth.currentUser!.uid)
                                        //     .update({
                                        //   'gender': _genderController.text,
                                        //   'dateofbirth':
                                        //       _dateOfBirthController.text,
                                        //   'username': username,
                                        //   'profilePicture': downloadUrl,
                                        // });
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'user-not-found') {
                                          // return popup message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.only(
                                                  bottom: 100.0,
                                                  left: 50,
                                                  right: 50),
                                              content: Text(
                                                  'Invalid user credentials.'),
                                              dismissDirection:
                                                  DismissDirection.none,
                                            ),
                                          );
                                          // print('No user found for that email.');
                                        } else if (e.code == 'wrong-password') {
                                          // return toast message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.only(
                                                  bottom: 100.0,
                                                  left: 50,
                                                  right: 50),
                                              content: const Text(
                                                  'Invalid user credentials.'),
                                              dismissDirection:
                                                  DismissDirection.none,
                                              backgroundColor: kTertiaryColor
                                                  .withOpacity(0.5),
                                              elevation: 0,
                                            ),
                                          );
                                        } else if (e.code == 'invalid-email') {
                                          // return toast message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.only(
                                                  bottom: 100.0,
                                                  left: 50,
                                                  right: 50),
                                              content: Text(
                                                  'Invalid user credentials.'),
                                              dismissDirection:
                                                  DismissDirection.none,
                                            ),
                                          );
                                        } else if (e.code == 'user-disabled') {
                                          // return toast message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.only(
                                                  bottom: 100.0,
                                                  left: 50,
                                                  right: 50),
                                              content: Text(
                                                  'Invalid user credentials.'),
                                              dismissDirection:
                                                  DismissDirection.none,
                                            ),
                                          );
                                        }
                                      }

                                      // ignore: use_build_context_synchronously
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          PageRouteBuilder(
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 250),
                                              transitionsBuilder:
                                                  (_, a, __, c) =>
                                                      FadeTransition(
                                                          opacity: a, child: c),
                                              pageBuilder: (context, a, b) {
                                                return const NavPage();
                                              }),
                                          (route) => false);
                                      setState(
                                        () {
                                          showSpinner = false;
                                        },
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              backgroundColor: const Color(0xFF4169E1),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    // forgot password button
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
