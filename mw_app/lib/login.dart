import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late String _exception = '';

  Future<void> _login() async {
    if(_formKey.currentState!.validate()){
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if(mounted){
          context.go('/');
        }
      } on FirebaseAuthException catch(e){
        String ex = 'Firebase Authentication Exception: ';
        if(e.code == 'invalid-email'){
          ex += 'invalid email address';
        } else {
          ex += 'check your credentials and try signing in again';
        }
        setState((){
          _exception = ex;
        });
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
                        return 'Please enter your password';
                      }
                      return null;
                    }
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  )
                ]
              )
            ),
            _exception.isEmpty
              ? const SizedBox.shrink()
              : Text(
                _exception,
                style: const TextStyle(color: Colors.red),
              ),
          ]
        ),
      ),
    );
  }
}