import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'second.dart';
import 'drawer.dart';
class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      drawer: getDrawer(context),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open route'),
          onPressed: () {
            // Navigate to second route when tapped.
            context.go('/page2');
          },
        ),
      ),
    );
  }
}
