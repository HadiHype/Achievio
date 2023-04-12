import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../User Interface/app_colors.dart';
import '../Authentication Logic/auth_logic.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  String email = '';
  String password = '';
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // create login page
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        color: const Color(0xFF4169E1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height: screenHeight - keyboardHeight,
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Image(
                      image: AssetImage('assets/images/signin_image.png'),
                      fit: BoxFit.contain,
                      height: 220,
                      width: double.infinity,
                    ),

                    const SizedBox(
                      height: 12.0,
                    ),

                    const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4169E1),
                      ),
                    ),

                    const SizedBox(
                      height: 36.0,
                    ),

                    TextField(
                      focusNode: focusNode,
                      controller: _emailController,
                      onTapOutside: ((event) => focusNode.unfocus()),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      decoration: const InputDecoration(
                        // isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        hintText: 'example@email.com',
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
                      height: 8.0,
                    ),
                    TextField(
                      focusNode: focusNodePassword,
                      controller: _passwordController,
                      onTapOutside: ((event) => focusNodePassword.unfocus()),
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      decoration: const InputDecoration(
                        // isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        hintText: 'password123!',
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
                    // forgot password button

                    ElevatedButton(
                      onPressed: email != "" && password != ""
                          ? () async {
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                // create user
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email, password: password);

                                // add user to firestore collection 'users'
                                var db = FirebaseFirestore.instance;

                                db.collection('users').add({
                                  'email': email,
                                  'password': password,
                                });

                                if (newUser != null) {
                                  // navigate to home page
                                  Navigator.pushNamed(context, '/nav');
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  // return popup message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: 100.0, left: 50, right: 50),
                                      content:
                                          Text('Invalid user credentials.'),
                                      dismissDirection: DismissDirection.none,
                                    ),
                                  );
                                  // print('No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  // return toast message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.only(
                                          bottom: 100.0, left: 50, right: 50),
                                      content: const Text(
                                          'Invalid user credentials.'),
                                      dismissDirection: DismissDirection.none,
                                      backgroundColor:
                                          kTertiaryColor.withOpacity(0.5),
                                      elevation: 0,
                                    ),
                                  );
                                } else if (e.code == 'invalid-email') {
                                  // return toast message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: 100.0, left: 50, right: 50),
                                      content:
                                          Text('Invalid user credentials.'),
                                      dismissDirection: DismissDirection.none,
                                    ),
                                  );
                                } else if (e.code == 'user-disabled') {
                                  // return toast message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          bottom: 100.0, left: 50, right: 50),
                                      content:
                                          Text('Invalid user credentials.'),
                                      dismissDirection: DismissDirection.none,
                                    ),
                                  );
                                }
                              }
                              setState(
                                () {
                                  showSpinner = false;
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        backgroundColor: const Color(0xFF4169E1),
                      ),
                      child: const Text('Sign Up'),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'have an account?',
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Color(0xFF4169E1),
                            ),
                          ),
                        ),
                      ],
                    )
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
