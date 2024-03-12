import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
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
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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
          ),
          Image.network(snapshot.data!.docs[index]['downloadURL']),
        ],
      );
    } catch(e){
      return Text('Error: $e');
    }
  }
}