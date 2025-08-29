
import 'package:flutter/material.dart';

class DeliveryboysPage extends StatefulWidget {
  const DeliveryboysPage({super.key});

  @override
  State<DeliveryboysPage> createState() => _DeliveryboysPageState();
}

class _DeliveryboysPageState extends State<DeliveryboysPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "DeliveryboysPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
