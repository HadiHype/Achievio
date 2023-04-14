import 'package:achievio/Authentication/Authentication%20Screen/signup_page.dart';
import 'package:achievio/Navigation%20Pages/navigation.dart';
import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../Authentication Logic/auth_logic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

class _LoginScreenState extends State<LoginScreen> {
  // create email and password controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  String email = '';
  String password = '';
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final Auth auth = Auth();
  bool showPassword = false;

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
                      'Sign In',
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
                      obscureText: true,
                      onTapOutside: ((event) => focusNodePassword.unfocus()),
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      decoration: InputDecoration(
                        // isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        hintText: 'password123!',
                        hintStyle: const TextStyle(
                          color: Colors.black45,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                        ),
                        fillColor: const Color(0xFFF5F5F5),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        border: const OutlineInputBorder(
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
                                await _auth.signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (!mounted) {
                                  return;
                                }
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const NavPage();
                                }), (route) => false);
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
                      child: const Text('Log In'),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/forgot_password');
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(vertical: 6.5),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 250),
                                    transitionsBuilder: (_, a, __, c) =>
                                        FadeTransition(opacity: a, child: c),
                                    pageBuilder: (context, a, b) {
                                      return const SignUpScreen();
                                    }),
                                (route) => false);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Register',
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
