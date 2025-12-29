import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    final userRole = currentUser?.role ?? 'guest';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête avec informations utilisateur
          UserAccountsDrawerHeader(
            accountName: Text(
              currentUser?.nom ?? 'Invité',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(currentUser?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _getUserIcon(userRole),
                color: _getUserColor(userRole),
                size: 40,
              ),
            ),
            decoration: BoxDecoration(
              color: _getUserColor(userRole),
            ),
          ),
          
          // Section Accueil
          _buildDrawerSection(
            title: 'Navigation',
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.home,
                title: 'Accueil',
                route: '/home',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.search,
                title: 'Recherche',
                route: '/search',
              ),
              if (currentUser != null)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.favorite,
                  title: 'Mes Favoris',
                  route: '/favorites',
                ),
            ],
          ),
          
          const Divider(),
          
          // Section Compte
          _buildDrawerSection(
            title: 'Mon Compte',
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.person,
                title: 'Mon Profil',
                route: '/profile',
              ),
              if (userRole == 'owner')
                _buildDrawerItem(
                  context: context,
                  icon: Icons.business,
                  title: 'Mes Logements',
                  route: '/owner-logements',
                ),
              if (userRole == 'owner')
                _buildDrawerItem(
                  context: context,
                  icon: Icons.add_home,
                  title: 'Publier un logement',
                  route: '/add-logement',
                ),
              if (userRole == 'admin')
                _buildDrawerItem(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Administration',
                  route: '/admin',
                ),
            ],
          ),
          
          const Divider(),
          
          // Section Autres
          _buildDrawerSection(
            title: 'Autres',
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.settings,
                title: 'Paramètres',
                route: '/settings',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.help_outline,
                title: 'Aide & Support',
                route: '/help',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.info,
                title: 'À propos',
                route: '/about',
              ),
            ],
          ),
          
          const Divider(),
          
          // Déconnexion ou Connexion
          if (currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await authViewModel.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Connexion', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
          
          // Informations de version
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location App',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Color _getUserColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'owner':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getUserIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'owner':
        return Icons.business;
      case 'user':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  // Méthode pour obtenir l'initial du nom
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// import 'package:flutter/material.dart';

// // Menu principal de l'application
// //ici on utilise un StatelessWidget car le menu ne nécessite pas de gestion d'état
// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key}); // constructeur qui accepte une clé optionnelle

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(color: Colors.blue),
//             child: Text(
//               'Menu Principal',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text('Accueil'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.search),
//             title: const Text('Recherche logements'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profil'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.message),
//             title: const Text('Messagerie'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.add_box),
//             title: const Text('Mes annonces'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.dashboard),
//             title: const Text('Dashboard'),
//             onTap: () {},
//           ),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Déconnexion'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
