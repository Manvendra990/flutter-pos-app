import 'package:flutter/material.dart';

class BillKotPrint extends StatefulWidget {
  const BillKotPrint({super.key});

  @override
  State<BillKotPrint> createState() => _BillKotPrintState();
}

class _BillKotPrintState extends State<BillKotPrint> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Bill Kot Print",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
