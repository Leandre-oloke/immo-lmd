import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AppEndDrawer extends StatelessWidget {
  const AppEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.settings, size: 40, color: Colors.blue),
                const SizedBox(height: 10),
                const Text(
                  'Paramètres',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (currentUser != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Connecté en tant que ${currentUser.nom}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          
          // Section Profil
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Profil',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Modifier mon profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Modifier email'),
            onTap: () {
              // TODO: Implémenter la modification d'email
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
          
          const Divider(),
          
          // Section Application
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Application',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implémenter les paramètres de notifications
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Confidentialité'),
            onTap: () {
              // TODO: Implémenter les paramètres de confidentialité
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          
          const Divider(),
          
          // Actions rapides
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rafraîchir'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter le rafraîchissement
            },
          ),
          if (currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await authViewModel.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
              },
            ),
          
          // Version
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}











// import 'package:flutter/material.dart';

// class AppEndDrawer extends StatefulWidget {
//   const AppEndDrawer({super.key});

//   @override
//   _AppEndDrawerState createState() => _AppEndDrawerState();
// }

// class _AppEndDrawerState extends State<AppEndDrawer> {
//   int selectedIndex = 0; // Index de l'élément sélectionné

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
//             leading: const Icon(Icons.settings),
//             title: const Text('Paramètres du compte'),
//             selected: selectedIndex == 1,
//             selectedTileColor: const Color.fromARGB(255, 244, 215, 205),
//             onTap: () {
//               setState(() {
//                 selectedIndex = 1;
//               });
//               Navigator.pushNamedAndRemoveUntil(
//                   context, '/page-acceuil', (predicate) => false);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
