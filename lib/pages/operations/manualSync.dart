
import 'package:flutter/material.dart';

class ManualSyncPage extends StatefulWidget {
  const ManualSyncPage({super.key});

  @override
  State<ManualSyncPage> createState() => _ManualSyncPageState();
}

class _ManualSyncPageState extends State<ManualSyncPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "ManualSyncPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
