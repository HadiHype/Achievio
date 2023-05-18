import 'package:achievio/Authentication/Authentication%20Screen/login_page.dart';
import 'package:achievio/Authentication/Authentication%20Screen/signup_page_additional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Authentication Logic/auth_logic.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // firebase auth
  final _auth = FirebaseAuth.instance;
  final Auth auth = Auth();

  // variables to store user input
  String email = '';
  String password = '';

  // keys
  final _formKey = GlobalKey<FormState>();

  // focus nodes
  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  // controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // booleans
  bool showSpinner = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    // get screen height and keyboard height
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
                    const Image(
                      image: AssetImage('assets/images/signup_image.png'),
                      fit: BoxFit.contain,
                      height: 260,
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

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            focusNode: focusNode,
                            onTapOutside: (event) => focusNode.unfocus(),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              } else {
                                if (!RegExp(
                                        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                    .hasMatch(value)) {
                                  return 'Please enter valid email';
                                }
                              }
                              return null;
                            },
                            onChanged: (value) {
                              email = value;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
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
                            height: 12.0,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: focusNodePassword,
                            onTapOutside: (event) =>
                                focusNodePassword.unfocus(),
                            obscureText: !showPassword,
                            validator: (value) {
                              RegExp regex = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$');
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              } else {
                                if (!regex.hasMatch(value)) {
                                  var val = '';
                                  if (!value.contains(RegExp(r'[A-Z]'))) {
                                    val += '\u2022 1 uppercase letter\n';
                                  }
                                  if (!value.contains(RegExp(r'[a-z]'))) {
                                    val += '\u2022 1 lowercase letter\n';
                                  }
                                  if (!value.contains(RegExp(r'[0-9]'))) {
                                    val += '\u2022 1 number\n';
                                  }
                                  if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
                                    val += '\u2022 1 special character\n';
                                  }
                                  if (value.length < 8) {
                                    val += '\u2022 8 characters\n';
                                  }

                                  return 'Password must contain:\n$val';
                                } else {
                                  return null;
                                }
                              }
                            },
                            onChanged: (value) {
                              password = value;
                            },
                            decoration: InputDecoration(
                              // isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              hintText: 'Password123!',
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
                          ElevatedButton(
                            onPressed: email != "" && password != ""
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      try {
                                        final newUser = await _auth
                                            .createUserWithEmailAndPassword(
                                                email: email,
                                                password: password);
                                        var db = FirebaseFirestore.instance;

                                        await db
                                            .collection('users')
                                            .doc(newUser.user!.uid)
                                            .set({
                                          'email': email,
                                          'uid': newUser.user!.uid,
                                          'gender': "",
                                          'dateofbirth': "",
                                          'username': "",
                                          'profilePicture': "",
                                          'friends': [],
                                          'friendRequestReceived': [],
                                          'friendRequestSent': [],
                                          'dateCreated':
                                              DateTime.now().toString(),
                                          'dateUpdated':
                                              DateTime.now().toString(),
                                          'dateLastLogin':
                                              DateTime.now().toString(),
                                        });

                                        if (!mounted) return;

                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    AdditionalSignUpScreen(
                                                      uid: newUser.user!.uid,
                                                    ),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  var begin =
                                                      const Offset(0.0, 1.0);
                                                  var end = Offset.zero;
                                                  var curve = Curves.ease;

                                                  var tween = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .chain(CurveTween(
                                                          curve: curve));

                                                  return SlideTransition(
                                                    position:
                                                        animation.drive(tween),
                                                    child: child,
                                                  );
                                                }));
                                      } catch (signuperror) {
                                        if (signuperror
                                            is FirebaseAuthException) {
                                          if (signuperror.code ==
                                              'email-already-in-use') {
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
                                                    'Email already in use'),
                                                dismissDirection:
                                                    DismissDirection.none,
                                              ),
                                            );
                                          }
                                        }
                                      }
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
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    // forgot password button

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
                            Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 250),
                                    transitionsBuilder: (_, a, __, c) =>
                                        FadeTransition(opacity: a, child: c),
                                    pageBuilder: (context, a, b) {
                                      return const LoginScreen();
                                    }),
                                (route) => false);
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
