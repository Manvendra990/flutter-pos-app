
import 'package:flutter/material.dart';

class CustomerOrderStatusPage extends StatefulWidget {
  const CustomerOrderStatusPage({super.key});

  @override
  State<CustomerOrderStatusPage> createState() => _CustomerOrderStatusPageState();
}

class _CustomerOrderStatusPageState extends State<CustomerOrderStatusPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "CustomerOrderStatusPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
