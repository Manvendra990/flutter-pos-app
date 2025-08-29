
import 'package:flutter/material.dart';

class OnlineOrdersPage extends StatefulWidget {
  const OnlineOrdersPage({super.key});

  @override
  State<OnlineOrdersPage> createState() => _OnlineOrdersState();
}

class _OnlineOrdersState extends State<OnlineOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "OnlineOrdersPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
