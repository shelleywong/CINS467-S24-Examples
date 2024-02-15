import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _myController = TextEditingController();
  String? _inputText = '';

  void _printLatestValue(){
    if (kDebugMode) {
      print('Text field input: ${_myController.text}');
    }
  }

  // void _submitText(){
  //   setState((){
  //     _inputText = _myController.text;
  //   });
  // }

  void _saveText(String? value){
    setState((){
      _inputText = value;
    });
  }

  void _submitForm() {
    if(_formKey.currentState!.validate()){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Processing data...'),
          action: SnackBarAction(
            label: 'Finish',
            onPressed:() {
              _formKey.currentState!.save();
              _myController.clear();
            },
          )
        )
      );
      // if (kDebugMode) {
      //   print('TextFormField input: ${_myController.text}');
      // }
    }
  }

  String? _textValidator(String? value){
    if(value == null || value.isEmpty){
      return 'Please enter some text; field cannot be empty';
    }
    if(value.contains('@')){
      return 'Do not use the @ char.';
    }
    if(value.length < 2){
      return 'Must use at least 2 chars';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
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
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _myController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'What do people call you?',
                      labelText: 'Name *',
                    ),
                    onSaved: _saveText,
                    validator: _textValidator,
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  )
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _inputText ?? '<nothing input>',
              ),
            ),
            // TextField(
            //   controller: _myController,
            //   obscureText: false,
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'Enter a search term',
            //     hintText: 'Search...',
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     _inputText,
            //   ),
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _submitText,
      //   tooltip: 'Submit Text',
      //   child: const Icon(Icons.edit),
      // ),
    );
  }
}
