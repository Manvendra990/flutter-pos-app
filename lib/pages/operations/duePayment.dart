
import 'package:flutter/material.dart';

class DuePamentPage extends StatefulWidget {
  const DuePamentPage({super.key});

  @override
  State<DuePamentPage> createState() => _DuePamentPageState();
}

class _DuePamentPageState extends State<DuePamentPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "DuePamentPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
