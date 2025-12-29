// import 'package:flutter/material.dart';

// // Menu secondaire de l'application
// // AppEndDrawer est un StatelessWidget car il ne nécessite pas de gestion d'état
// class AppEndDrawer extends StatelessWidget {
//   const AppEndDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(color: Colors.grey[200]),
//             child: const Text(
//               'Paramètres',
//               style: TextStyle(fontSize: 22),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings), // Icône des paramètres
//             title: const Text('Paramètres du compte'),
//             onTap: () {}, // Action à définir
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class AppEndDrawer extends StatelessWidget {
//   AppEndDrawer({super.key});
//   int selectedIndex = 0; // Index de l'élément sélectionné
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(color: Colors.grey[200]),
//             child: Text(
//               'Paramètres',
//               style: TextStyle(fontSize: 22),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.settings),
//             title: Text('Paramètres du compte'),
//             selected : selectedIndex == 1, // Vérifie si cet élément est sélectionné
//             selectedTileColor:
//                 const Color.fromARGB(255, 244, 215, 205), // Couleur de fond si sélectionné
//             onTap: () {
//               setState(() {
//                 selectedIndex = 1;
//               });
//               Navigator.pushNamedAndRemoveUntil(context, 
//               '/page-acceuil', (predicate) => false); // Ferme le drawer
            
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

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

// Widget buildDrawer(UserRole role) {
//   return Drawer(
//     child: ListView(
//       children: [
//         ListTile(title: Text("Accueil")),

//         if (role == UserRole.user)
//           ListTile(title: Text("Mes réservations")),

//         if (role == UserRole.owner)
//           ListTile(title: Text("Mes logements")),

//         if (role == UserRole.admin)
//           ListTile(title: Text("Dashboard")),

//         ListTile(title: Text("Déconnexion")),
//       ],
//     ),
//   );
// }

// class AppDrawer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final authVM = context.watch<AuthViewModel>();
//     final role = authVM.user!.role;

//     return Drawer(
//       child: ListView(
//         children: [
//           DrawerHeader(child: Text(authVM.user!.name)),

//           if (role == UserRole.user)
//             ListTile(title: Text("Mes réservations")),

//           if (role == UserRole.owner)
//             ListTile(title: Text("Mes annonces")),

//           if (role == UserRole.admin)
//             ListTile(title: Text("Dashboard")),

//           ListTile(
//             title: Text("Déconnexion"),
//             onTap: () {
//               authVM.logout();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

