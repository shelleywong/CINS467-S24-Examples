import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Recipe App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> recipes;

  Future<List<dynamic>> getRecipes() async {
    var url = Uri.https('rest.bryancdixon.com', '/food/');
    var response = await http.get(url);
    if(response.statusCode == 200){
      var jsonResponse = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print(jsonResponse['recipes'][0]);
      }
      return jsonResponse['recipes'];
    } else {
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        //print('Response body: ${response.body}');
      }
      return List.empty();
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if(!await launchUrl(url)){
      if(kDebugMode){
        print('Could not launch $url');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    recipes = getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List> (
        future: recipes,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if(snapshot.hasError){
                return Text('Error: ${snapshot.error}');
              } else {
                //return Text(snapshot.data![0]['title']);
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index){
                    //return Text(snapshot.data![index]['title']);
                    return GestureDetector(
                      onTap: () {
                        Uri url = Uri.parse(snapshot.data![index]['url']);
                        _launchUrl(url);
                      },
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(snapshot.data![index]['title']),
                            ),
                            Image.network(snapshot.data![index]['photo_url']),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getRecipes,
        tooltip: 'Get Recipes',
        child: const Icon(Icons.food_bank),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
