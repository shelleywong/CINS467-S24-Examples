import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';
//import 'storage.dart';
//import 'sqlstorage.dart';
import 'firestorage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hello CINS467!'),
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
  late Future<Position> _position;
  //final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //late Future<int> _counter;

  //final InputStorage _storage = InputStorage(); // path_provider example

  final CounterStorage _storage = CounterStorage(); // sqflite
  int _counter = 0;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  late StreamSubscription<Position> positionStream;

  Future<void> _incrementCounter() async {
    // final SharedPreferences prefs = await _prefs;
    // final int counter = (prefs.getInt('counter') ?? 0) + 1;
    // setState(() {
    //   _counter = prefs.setInt('counter', counter).then((bool success){
    //     return counter;
    //   });
    // });
    await _storage.readCounter().then((value) async {
      final int counter = value + 1;
      await _storage.writeCounter(counter);
      setState(() {
        _counter = counter;
      });
    });
  }

  Future<void> _decrementCounter() async {
    // final SharedPreferences prefs = await _prefs;
    // final int counter = (prefs.getInt('counter') ?? 0) - 1;
    // setState(() {
    //   _counter = prefs.setInt('counter', counter).then((bool success){
    //     return counter;
    //   });
    // });
    await _storage.readCounter().then((value) async {
      final int counter = value - 1;
      await _storage.writeCounter(counter);
      setState(() {
        _counter = counter;
      });
    });
  }

  // Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  /// Ref: https://pub.dev/packages/geolocator
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    // _counter = _prefs.then((SharedPreferences prefs){
    //   return prefs.getInt('counter') ?? 0;
    // });
    _storage.readCounter().then((value) {
      setState(() {
        _counter = value;
      });
    });
    _position = _determinePosition();
    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings).listen((Position? pos){
        // Handle position changes
        if(kDebugMode){
          print(pos == null ? 'Unknown' : '${pos.latitude.toString()}, ${pos.longitude.toString()}');
        }
      });
  }

  @override
  void dispose() {
    //_storage.close();  // sqflite example (close DB)
    positionStream.cancel();
    super.dispose();
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: const EdgeInsets.all(8),
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: <Widget>[
            FutureBuilder(
              future: _position,
              builder:(context, snapshot) {
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if(snapshot.hasError){
                      return Text('${snapshot.error}');
                    } else {
                      return Text('${snapshot.data}');
                    }
                }
              },
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: const Image(
                  image: AssetImage('assets/chicostateflowers.jpeg'),
                ),
              ),
            ),
            const Text(
              'You have pushed the button this many times:',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: "Increment Counter",
                    child: IconButton(
                      onPressed: _incrementCounter,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: FutureBuilder<int>(
                      //   future: _counter,
                      //   builder: ((context, snapshot) {
                      //     switch(snapshot.connectionState){
                      //       case ConnectionState.waiting:
                      //         return const CircularProgressIndicator();
                      //       default:
                      //         if(snapshot.hasError){
                      //           return Text('Error: ${snapshot.error}');
                      //         } else {
                      //           return Text(
                      //             'Count: ${snapshot.data}',
                      //             style: Theme.of(context).textTheme.headlineMedium,
                      //           );
                      //         }
                      //     }
                      //   }),
                      // ),
                      child: Text(
                        _counter == 0 ? '' : 'Count: $_counter',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    child: const Text('Decrement'),
                  )
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: const Image(
                  image: AssetImage('assets/chicostateafterrain.jpg'),
                ),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('greetings')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Text(
                              '${snapshot.data!.docs[index]["message"]}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall,
                            );
                          });
                    }
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
