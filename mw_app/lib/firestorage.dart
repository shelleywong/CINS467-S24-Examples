import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CounterStorage {
  Future<void> writeCounter(int counter) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('counterCollection').doc('cins467').set({
      'count': counter,
    }).then((value){
      if(kDebugMode){
        print('count updated successfully');
      }
    }).catchError((error){
      if(kDebugMode){
        print('writeCounter error: $error');
      }
    });
  }

  Future<int> readCounter() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds = await firestore.collection('counterCollection').doc('cins467').get();
    if(ds.data() != null){
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if(data.containsKey('count')){
        return data['count'];
      }
    }
    return 0;
  }
}