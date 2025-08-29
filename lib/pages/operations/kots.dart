
import 'package:flutter/material.dart';

class KotsPage extends StatefulWidget {
  const KotsPage({super.key});

  @override
  State<KotsPage> createState() => _KotsPageState();
}

class _KotsPageState extends State<KotsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "KotsPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
