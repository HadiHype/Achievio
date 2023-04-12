import 'dart:ffi';

import 'package:achievio/User%20Interface/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> isLogged() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<User?> signIn(String email, String password, context) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // return popup message
        _scaffoldMessage(context);
        // print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // return toast message
        _scaffoldMessage(context);
      } else if (e.code == 'invalid-email') {
        // return toast message
        _scaffoldMessage(context);
      } else if (e.code == 'user-disabled') {
        // return toast message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 100.0, left: 50, right: 50),
            content: Text('Invalid.'),
            dismissDirection: DismissDirection.none,
          ),
        );
      }
    }
  }

  // method to return scaffold message
  void _scaffoldMessage(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100.0, left: 50, right: 50),
        content: const Text('Invalid user credentials.'),
        dismissDirection: DismissDirection.none,
        backgroundColor: kTertiaryColor.withOpacity(0.5),
        elevation: 0,
      ),
    );
  }

  Future<User?> signUp(
    String email,
    String password,
    String username,
    String name,
    Char Gender,
  ) async {
    // create a user with email and password
    // then store that user in a variable called user which will be stored in firestore

    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
