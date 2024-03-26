import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key, required this.title});

  final String title;

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _createAccount() async {
    if(_formKey.currentState!.validate()){
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if(mounted){
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return 'Please enter your email address';
                      }
                      return null;
                    }
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      icon: Icon(Icons.password),
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return 'Please enter a password';
                      }
                      return null;
                    }
                  ),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password *',
                      icon: Icon(Icons.password),
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return 'Please re-enter your password to confirm';
                      }
                      if(value != _passwordController.text){
                        return 'Passwords do not match. Please try again';
                      }
                      return null;
                    }
                  ),
                  ElevatedButton(
                    onPressed: _createAccount,
                    child: const Text('Create an Account'),
                  )
                ]
              )
            )
          ]
        ),
      ),
    );
  }
}