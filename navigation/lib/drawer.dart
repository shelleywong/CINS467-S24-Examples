import 'package:flutter/material.dart';
import 'second.dart';

Widget getDrawer(BuildContext context){
  return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Second Route'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Go back'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
}
