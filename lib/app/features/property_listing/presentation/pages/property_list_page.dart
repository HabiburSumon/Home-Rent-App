import 'package:flutter/material.dart';

class PropertyListPage extends StatelessWidget {
  const PropertyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property List'),
      ),
      body: const Center(
        child: Text('Property List Page'),
      ),
    );
  }
}