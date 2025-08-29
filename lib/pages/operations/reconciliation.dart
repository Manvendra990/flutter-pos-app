
import 'package:flutter/material.dart';

class Reconciliation extends StatefulWidget {
  const Reconciliation({super.key});

  @override
  State<Reconciliation> createState() => _ReconciliationState();
}

class _ReconciliationState extends State<Reconciliation> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Reconciliation",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
