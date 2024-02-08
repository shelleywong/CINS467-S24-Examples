import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'drawer.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      drawer: getDrawer(context),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            context.go('/');
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}