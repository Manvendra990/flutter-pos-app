
import 'package:flutter/material.dart';

class ServerRenewal extends StatefulWidget {
  const ServerRenewal({super.key});

  @override
  State<ServerRenewal> createState() => _ServerRenewalState();
}

class _ServerRenewalState extends State<ServerRenewal> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "ServerRenewal",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
