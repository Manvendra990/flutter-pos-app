
import 'package:flutter/material.dart';

class DualScreenPage extends StatefulWidget {
  const DualScreenPage({super.key});

  @override
  State<DualScreenPage> createState() => _DualScreenPageState();
}

class _DualScreenPageState extends State<DualScreenPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "DualScreenPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
