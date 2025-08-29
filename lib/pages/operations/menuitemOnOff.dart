
import 'package:flutter/material.dart';

class MenuItemsonOffPage extends StatefulWidget {
  const MenuItemsonOffPage({super.key});

  @override
  State<MenuItemsonOffPage> createState() => _MenuItemsonOffPageState();
}

class _MenuItemsonOffPageState extends State<MenuItemsonOffPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "MenuItemsonOffPage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
