import 'package:flutter/material.dart';


class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.white),
              title: const Text('Markship', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/markship');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.white),
              title: const Text('Alert', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/alert');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dangerous, color: Colors.white),
              title: const Text('Danger', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/danger');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud, color: Colors.white),
              title: const Text('Weather', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/weather');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/logout');
              },
            ),
          ],
        ),
      ),
    );
  }
}