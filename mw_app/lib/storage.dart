import 'dart:io';
import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class InputStorage {
  // find the path to the app docs directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // get a file in the app docs directory
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/input.txt');
  }

  Future<void> writeCounter(int counter) async {
    try {
      final file = await _localFile;
      //await file.writeAsString(counter.toString());
      String jsonString = json.encode({'counter': counter});
      await file.writeAsString(jsonString);
    } catch (e) {
      if(kDebugMode){
        print('writeCounter error: $e');
      }
    }
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      var counterData = json.decode(contents);
      return counterData['counter'];
    } catch(e) {
      if(kDebugMode){
        print('readCounter error: $e');
      }
      return 0;
    }
  }
}