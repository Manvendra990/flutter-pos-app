import 'package:flutter/material.dart';
import 'package:posapp/component/drawer.dart';
import 'package:posapp/component/header.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final void Function(String route)? onNavigate;
  final VoidCallback? onNewOrder; // ✅ add

  const MainLayout({super.key,
    required this.child,
    this.onNavigate,
    this.onNewOrder, // ✅
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: POSHeader(onNavigate: onNavigate),
      drawer: POSDrawer(onNavigate: onNavigate),
      body: child,
    );
  }
}



