
import 'package:flutter/material.dart';

class Tax extends StatefulWidget {
  const Tax({super.key});

  @override
  State<Tax> createState() => _TaxState();
}

class _TaxState extends State<Tax> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Tax",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
