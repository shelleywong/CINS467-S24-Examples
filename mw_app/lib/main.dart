import 'dart:async';
//import 'dart:io';
//import 'package:uuid/uuid.dart';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
//import 'storage.dart';
//import 'sqlstorage.dart';
//import 'firestorage.dart';
import 'photos.dart';
import 'home.dart';
import 'createuser.dart';
import 'profile.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // if (kIsWeb) {
  //   runApp(const MyApp(myAppTitle: 'Web CINS467'));
  // } else if (Platform.isAndroid) {
  //   runApp(const MyApp(myAppTitle: 'Android CINS467'));
  // } else {
  //   runApp(const MyApp(myAppTitle: 'CINS467'));
  // }
  runApp(const MyApp());
}

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        if(FirebaseAuth.instance.currentUser == null){
          return const AuthPage(title: 'CINS467 Auth Page');
        } else {
          return const MyHomePage(title: 'Hello CINS467!');
        }
      } 
    ),
    GoRoute(
      path: '/photos',
      builder: (context, state) => const MyPhotoPage(title: 'Photo Page'),
    ),
    GoRoute(
      path: '/createuser',
      builder: (context, state) => const CreateUser(title: 'Create Account'),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(title: 'Login'),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        if(FirebaseAuth.instance.currentUser == null){
          return const AuthPage(title: 'CINS467 Auth Page');
        } else {
          return const ProfilePage(title: 'Profile');
        }
      }
    )
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      //home: MyHomePage(title: 'Hello $myAppTitle!'),
      routerConfig: _router,
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.title});

  final String title;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.camera),
        //     tooltip: 'Go to Photos Page',
        //     onPressed: () => context.go('/photos'),
        //   )
        // ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/createuser'),
              child: const Text('Create Account'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
          ]
        ),
      ),
    );
  }
}