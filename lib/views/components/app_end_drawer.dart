
import 'package:flutter/material.dart';

class AppEndDrawer extends StatefulWidget {
  const AppEndDrawer({super.key});

  @override
  _AppEndDrawerState createState() => _AppEndDrawerState();
}

class _AppEndDrawerState extends State<AppEndDrawer> {
  int selectedIndex = 0; // Index de l'élément sélectionné

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: const Text(
              'Paramètres',
              style: TextStyle(fontSize: 22),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres du compte'),
            selected: selectedIndex == 1,
            selectedTileColor: const Color.fromARGB(255, 244, 215, 205),
            onTap: () {
              setState(() {
                selectedIndex = 1;
              });
              Navigator.pushNamedAndRemoveUntil(
                  context, '/page-acceuil', (predicate) => false);
            },
          ),
        ],
      ),
    );
  }
}
