import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;
  }
}


class Photos extends StatelessWidget {
  const Photos({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyPhotoPage(title: 'My Photo Page'),
    );
  }
}

class MyPhotoPage extends StatefulWidget {
  const MyPhotoPage({super.key, required this.title});

  final String title;

  @override
  State<MyPhotoPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPhotoPage> {
  final myScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Home Page',
            onPressed: () => context.go('/'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getBody(),
          // children: <Widget>[
          //   Text('Photos!'),

          // ],
        ),
      ),
    );
  }

  List<Widget> getBody() {
    return [
      const Text('Photos!'),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('photos').snapshots(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if(snapshot.hasError){
                return Text('Error: ${snapshot.error}');
              } else {
                return Expanded(
                  child: Scrollbar(
                    controller: myScrollController,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: myScrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        return photoWidget(snapshot, index);
                      }
                    ),
                  ),
                );
              }
          }
        }
      )
    ];
  }

  Widget photoWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index){
    try {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(snapshot.data!.docs[index]['title']),
            subtitle: Text(DateTime.fromMillisecondsSinceEpoch(snapshot.data!.docs[index]['timestamp'].seconds * 1000).toString()),
            //subtitle: Text(snapshot.data!.docs[index]['timestamp'].toString()),
          ),
          //Image.network(snapshot.data!.docs[index]['downloadURL']),
          kIsWeb
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  snapshot.data!.docs[index]['downloadURL'],
                  height: SizeConfig.blockSizeVertical! * 70,
                )
              )
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(snapshot.data!.docs[index]['downloadURL']),
              ),

        ],
      );
    } catch(e){
      return Text('Error: $e');
    }
  }
}