import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'first.dart';
import 'second.dart';

void main() {
  runApp(MyApp());
}

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FirstRoute(),
    ),
    GoRoute(
      path: '/page2',
      builder: (context, state) => const SecondRoute(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigation Basics',
      routerConfig: _router,
    );
  }
}



