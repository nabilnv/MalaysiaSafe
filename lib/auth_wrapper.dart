import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen.dart';
import 'login_screen.dart'; // Replace with your actual login screen.

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in using Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, navigate to the HomeScreen
    if (user != null) {
      return HomeScreen();  // Replace with your home screen widget
    } else {
      return LoginScreen();  // Replace with your login screen widget
    }
  }
}
