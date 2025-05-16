import 'package:flutter/material.dart';
import "package:dtu_connect_2/dashboard.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'signin_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return Dashboard until you integrate Firebase Auth
    return FirebaseAuth.instance.currentUser != null?
        const Dashboard() : const SigninPage();
  }
}
