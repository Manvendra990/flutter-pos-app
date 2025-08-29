
import 'package:flutter/material.dart';

class LangauageprofilePage extends StatefulWidget {
  const LangauageprofilePage({super.key});

  @override
  State<LangauageprofilePage> createState() => _LangauageprofilePageState();
}

class _LangauageprofilePageState extends State<LangauageprofilePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "LangauageprofilePage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
