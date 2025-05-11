import 'package:flutter/material.dart';
import "package:dtu_connect_2/dashboard.dart";

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return Dashboard until you integrate Firebase Auth
    return const Dashboard();
  }
}
