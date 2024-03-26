import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> _signOutFirebase() async {
    await FirebaseAuth.instance.signOut();
    if(mounted){
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go back to Home Page',
            onPressed: () => context.go('/'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Email: ${FirebaseAuth.instance.currentUser!.email}',
                    ),
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _signOutFirebase,
              child: const Text('Logout'),
            )
          ]
        ),
      ),
    );
  }
}
