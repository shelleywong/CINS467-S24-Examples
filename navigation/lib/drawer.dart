import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'second.dart';

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
              leading: const Icon(Icons.arrow_forward),
              title: const Text('Second Route'),
              onTap: () {
                context.go('/page2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('First Route'),
              onTap: () {
                context.go('/');
              },
            ),
          ],
        ),
      );
}
