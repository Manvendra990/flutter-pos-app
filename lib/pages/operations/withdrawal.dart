
import 'package:flutter/material.dart';

class WithDrawal extends StatefulWidget {
  const WithDrawal({super.key});

  @override
  State<WithDrawal> createState() => _WithDrawalState();
}

class _WithDrawalState extends State<WithDrawal> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "WithDrawal",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
