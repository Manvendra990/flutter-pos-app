import 'package:flutter/material.dart';

class BillingUserProfile extends StatefulWidget {
  const BillingUserProfile({super.key});

  @override
  State<BillingUserProfile> createState() => _BillingUserProfileState();
}

class _BillingUserProfileState extends State<BillingUserProfile> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Billing User Profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
