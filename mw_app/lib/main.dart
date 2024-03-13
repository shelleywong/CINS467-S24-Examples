import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
//import 'storage.dart';
//import 'sqlstorage.dart';
import 'firestorage.dart';
import 'photos.dart';

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
      builder: (context, state) => const MyHomePage(title: 'Hello CINS467!'),
    ),
    GoRoute(
      path: '/photos',
      builder: (context, state) => const MyPhotoPage(title: 'Photo Page'),
    ),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Position> _position;
  Position? _photoPosition;

  final CounterStorage _storage = CounterStorage(); // sqflite
  int _counter = 0;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  late StreamSubscription<Position> positionStream;

  File? _image; // for android
  String? _imagePath; // for web
  Uint8List? _imageForWeb; // for web

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();
    // Capture photo
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    _imageForWeb = await photo!.readAsBytes();
    setState(() {
      //if (photo != null) {
      if (kIsWeb) {
        _imagePath = photo.path;
      } else {
        // Android
        _image = File(photo.path);
      }
      // } else {
      //   if (kDebugMode) {
      //     print('No photo captured');
      //   }
      // }
    });
  }

  Future<void> _upload() async {
    if (_image != null || _imagePath != null) {
      _photoPosition = await _determinePosition();
      // Generate a v4 (random) id (universally unique identifier)
      const uuid = Uuid();
      final String uid = uuid.v4();
      // Upload image file to storage (using uid) and generate a downloadURL
      final String downloadURL = await _uploadFile(uid);
      // Add downloadURL (ref to the image) to the database
      await _addItem(downloadURL, uid);
      // Navigate back to the photos screen
      if (mounted) {
        context.go('/photos');
      }
    }
  }

  Future<String> _uploadFile(String filename) async {
    if (kIsWeb) {
      final storageRef = FirebaseStorage.instance.ref();
      try {
        // upload raw data
        TaskSnapshot uploadTask =
            await storageRef.child('$filename.jpg').putData(
                _imageForWeb!,
                SettableMetadata(
                  contentType: 'image/jpeg',
                  contentLanguage: 'en',
                ));
        final String downloadURL = await uploadTask.ref.getDownloadURL();
        return downloadURL;
      } on FirebaseException catch (e) {
        return 'uploadFile on web error: $e';
      }
    } else {
      // Android
      // Create a reference to file location in Google Cloud Storage object
      Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
      // Add metadata to the image file
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        contentLanguage: 'en',
      );
      // Upload the file to Storage
      final UploadTask uploadTask = ref.putFile(_image!, metadata);
      TaskSnapshot uploadResult = await uploadTask;
      // After the upload task is complete, get a (String) download URL
      final String downloadURL = await uploadResult.ref.getDownloadURL();
      // Return the download URL (to be used in the database entry)
      return downloadURL;
    }
  }

  Future<void> _addItem(String downloadURL, String id) async {
    await FirebaseFirestore.instance.collection('photos').add(<String, dynamic>{
      'downloadURL': downloadURL,
      'title': id,
      'geopoint': GeoPoint(_photoPosition!.latitude, _photoPosition!.longitude),
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _incrementCounter() async {
    await _storage.readCounter().then((value) async {
      final int counter = value + 1;
      await _storage.writeCounter(counter);
      setState(() {
        _counter = counter;
      });
    });
  }

  Future<void> _decrementCounter() async {
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
    _storage.readCounter().then((value) {
      setState(() {
        _counter = value;
      });
    });
    _position = _determinePosition();
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? pos) {
      // Handle position changes
      if (kDebugMode) {
        print(pos == null
            ? 'Unknown'
            : '${pos.latitude.toString()}, ${pos.longitude.toString()}');
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera),
            tooltip: 'Go to Photos Page',
            onPressed: () => context.go('/photos'),
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            _image == null
                //? const Icon(Icons.photo, size: 100)
                ? const SizedBox.shrink()
                : Image.file(_image!, height: 300),
            _imagePath == null
                ? const SizedBox.shrink()
                : Image.network(_imagePath!, height: 400),
            Tooltip(
              message: kIsWeb ? 'open the gallery' : 'launch the camera',
              child: ElevatedButton(
                onPressed: _getImage,
                child: const Icon(Icons.photo_camera),
              ),
            ),
            ElevatedButton(
              onPressed: _upload,
              child: const Text(
                'Upload Photo',
              ),
            ),
            FutureBuilder(
              future: _position,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
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
