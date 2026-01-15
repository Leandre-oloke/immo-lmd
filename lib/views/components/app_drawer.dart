import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/utilisateur_model.dart';


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
          _buildUserHeader(currentUser, userRole),
          
          // Section Navigation principale
          _buildDrawerSection(
            title: 'Navigation',
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.home,
                title: 'Accueil',
                route: '/home',
                isActive: ModalRoute.of(context)?.settings.name == '/home',
              ),
              
              if (currentUser != null)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person,
                  title: 'Mon Profil',
                  route: '/profile',
                  isActive: ModalRoute.of(context)?.settings.name == '/profile',
                ),
            ],
          ),
          
          const Divider(),
          
          // Section selon le rôle
          _buildRoleSection(context, userRole, authViewModel),
          
          const Divider(),
          
          // Section Paramètres
          _buildDrawerSection(
            title: 'Paramètres',
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.settings,
                title: 'Paramètres',
                route: '/settings',
                isActive: ModalRoute.of(context)?.settings.name == '/settings',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.help_outline,
                title: 'Aide & Support',
                route: '/help',
                isActive: ModalRoute.of(context)?.settings.name == '/help',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.info,
                title: 'À propos',
                route: '/about',
                isActive: ModalRoute.of(context)?.settings.name == '/about',
              ),
            ],
          ),
          
          const Divider(),
          
          // Déconnexion ou Connexion
          _buildAuthSection(context, currentUser, authViewModel),
          
          // Informations de version
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(Utilisateur? currentUser, String userRole) {
    return UserAccountsDrawerHeader(
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
    );
  }

  Widget _buildRoleSection(BuildContext context, String userRole, AuthViewModel authViewModel) {
    List<Widget> roleItems = [];
    
    if (userRole == 'admin') {
      roleItems = [
        _buildDrawerItem(
          context: context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          route: '/admin-home',
          isActive: ModalRoute.of(context)?.settings.name == '/admin-home',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.people,
          title: 'Gestion Utilisateurs',
          route: '/admin/users',
          isActive: ModalRoute.of(context)?.settings.name == '/admin/users',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.apartment,
          title: 'Gestion Logements',
          route: '/admin/properties',
          isActive: ModalRoute.of(context)?.settings.name == '/admin/properties',
        ),
      ];
    } else if (userRole == 'owner') {
      roleItems = [
        _buildDrawerItem(
          context: context,
          icon: Icons.business,
          title: 'Espace Propriétaire',
          route: '/owner-home',
          isActive: ModalRoute.of(context)?.settings.name == '/owner-home',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.home_work,
          title: 'Mes Logements',
          route: '/owner-logements',
          isActive: ModalRoute.of(context)?.settings.name == '/owner-logements',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.search,
          title: 'Voir tous les logements',
          route: '/all-logements',
          isActive: ModalRoute.of(context)?.settings.name == '/all-logements',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.add_home,
          title: 'Ajouter un logement',
          onTap: () {
            Navigator.pop(context);
            // Pour l'instant, rediriger vers la page propriétaire
            // Vous pourrez ajouter une route spécifique plus tard
            Navigator.pushNamed(context, '/owner-home');
          },
        ),
      ];
    } else if (userRole == 'user') {
      roleItems = [
        _buildDrawerItem(
          context: context,
          icon: Icons.search,
          title: 'Rechercher',
          route: '/user-home',
          isActive: ModalRoute.of(context)?.settings.name == '/user-home',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.favorite,
          title: 'Mes Favoris',
          route: '/favorites',
          isActive: ModalRoute.of(context)?.settings.name == '/favorites',
        ),
        _buildDrawerItem(
          context: context,
          icon: Icons.calendar_today,
          title: 'Mes Réservations',
          route: '/bookings',
          isActive: ModalRoute.of(context)?.settings.name == '/bookings',
        ),
      ];
    }
    
    if (roleItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return _buildDrawerSection(
      title: userRole == 'admin' 
          ? 'Administration' 
          : userRole == 'owner' 
            ? 'Gestion Propriétaire' 
            : 'Locataire',
      children: roleItems,
    );
  }

  Widget _buildAuthSection(BuildContext context, Utilisateur? currentUser, AuthViewModel authViewModel) {
    if (currentUser != null) {
      return ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
        onTap: () async {
          Navigator.pop(context);
          await authViewModel.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
      );
    } else {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.login, color: Colors.green),
            title: const Text('Connexion', style: TextStyle(color: Colors.green)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Inscription', style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
          ),
        ],
      );
    }
  }

  Widget _buildAppInfo() {
    return const Padding(
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
    String? route,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue : null),
      title: Text(title, style: TextStyle(
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive ? Colors.blue : null,
      )),
      tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
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
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../models/utilisateur_model.dart';

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();
//     final currentUser = authViewModel.currentUser;
//     final userRole = currentUser?.role ?? 'guest';

//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // En-tête avec informations utilisateur
//           _buildUserHeader(currentUser, userRole),
          
//           // Section Navigation principale
//           _buildDrawerSection(
//             title: 'Navigation',
//             children: [
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.home,
//                 title: 'Accueil',
//                 route: '/home',
//                 isActive: ModalRoute.of(context)?.settings.name == '/home',
//               ),
              
//               if (currentUser != null)
//                 _buildDrawerItem(
//                   context: context,
//                   icon: Icons.person,
//                   title: 'Mon Profil',
//                   route: '/profile',
//                   isActive: ModalRoute.of(context)?.settings.name == '/profile',
//                 ),
//             ],
//           ),
          
//           const Divider(),
          
//           // Section selon le rôle
//           _buildRoleSection(context, userRole, authViewModel),
          
//           const Divider(),
          
//           // Section Paramètres
//           _buildDrawerSection(
//             title: 'Paramètres',
//             children: [
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.settings,
//                 title: 'Paramètres',
//                 route: '/settings',
//                 isActive: ModalRoute.of(context)?.settings.name == '/settings',
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.help_outline,
//                 title: 'Aide & Support',
//                 route: '/help',
//                 isActive: ModalRoute.of(context)?.settings.name == '/help',
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.info,
//                 title: 'À propos',
//                 route: '/about',
//                 isActive: ModalRoute.of(context)?.settings.name == '/about',
//               ),
//             ],
//           ),
          
//           const Divider(),
          
//           // Déconnexion ou Connexion
//           _buildAuthSection(context, currentUser, authViewModel),
          
//           // Informations de version
//           _buildAppInfo(),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserHeader(Utilisateur? currentUser, String userRole) {
//     return UserAccountsDrawerHeader(
//       accountName: Text(
//         currentUser?.nom ?? 'Invité',
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       accountEmail: Text(currentUser?.email ?? ''),
//       currentAccountPicture: CircleAvatar(
//         backgroundColor: Colors.white,
//         child: Icon(
//           _getUserIcon(userRole),
//           color: _getUserColor(userRole),
//           size: 40,
//         ),
//       ),
//       decoration: BoxDecoration(
//         color: _getUserColor(userRole),
//       ),
//     );
//   }

//   Widget _buildRoleSection(BuildContext context, String userRole, AuthViewModel authViewModel) {
//     if (userRole == 'admin') {
//       return _buildDrawerSection(
//         title: 'Administration',
//         children: [
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.dashboard,
//             title: 'Dashboard',
//             route: '/admin-home',
//             isActive: ModalRoute.of(context)?.settings.name == '/admin-home',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.people,
//             title: 'Gestion Utilisateurs',
//             route: '/admin/users',
//             isActive: ModalRoute.of(context)?.settings.name == '/admin/users',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.apartment,
//             title: 'Gestion Logements',
//             route: '/admin/properties',
//             isActive: ModalRoute.of(context)?.settings.name == '/admin/properties',
//           ),
//         ],
//       );
//     } else if (userRole == 'owner') {
//       return _buildDrawerSection(
//         title: 'Gestion Propriétaire',
//         children: [
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.business,
//             title: 'Espace Propriétaire',
//             route: '/owner-home',
//             isActive: ModalRoute.of(context)?.settings.name == '/owner-home',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.home_work,
//             title: 'Mes Logements',
//             route: '/owner-logements',
//             isActive: ModalRoute.of(context)?.settings.name == '/owner-logements',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.add_home,
//             title: 'Ajouter un logement',
//             onTap: () {
//               Navigator.pop(context);
//               // Pour l'instant, rediriger vers la page propriétaire
//               // Vous pourrez ajouter une route spécifique plus tard
//               Navigator.pushNamed(context, '/owner-home');
//             },
//           ),
//         ],
//       );
//     } else if (userRole == 'user') {
//       return _buildDrawerSection(
//         title: 'Locataire',
//         children: [
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.search,
//             title: 'Rechercher',
//             route: '/user-home',
//             isActive: ModalRoute.of(context)?.settings.name == '/user-home',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.favorite,
//             title: 'Mes Favoris',
//             route: '/favorites',
//             isActive: ModalRoute.of(context)?.settings.name == '/favorites',
//           ),
//           _buildDrawerItem(
//             context: context,
//             icon: Icons.calendar_today,
//             title: 'Mes Réservations',
//             route: '/bookings',
//             isActive: ModalRoute.of(context)?.settings.name == '/bookings',
//           ),
//         ],
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }

//   Widget _buildAuthSection(BuildContext context, Utilisateur? currentUser, AuthViewModel authViewModel) {
//     if (currentUser != null) {
//       return ListTile(
//         leading: const Icon(Icons.logout, color: Colors.red),
//         title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
//         onTap: () async {
//           Navigator.pop(context);
//           await authViewModel.logout();
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//         },
//       );
//     } else {
//       return Column(
//         children: [
//           ListTile(
//             leading: const Icon(Icons.login, color: Colors.green),
//             title: const Text('Connexion', style: TextStyle(color: Colors.green)),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, '/login');
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.person_add, color: Colors.blue),
//             title: const Text('Inscription', style: TextStyle(color: Colors.blue)),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, '/register');
//             },
//           ),
//         ],
//       );
//     }
//   }

//   Widget _buildAppInfo() {
//     return const Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Location App',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             'Version 1.0.0',
//             style: TextStyle(fontSize: 10, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildDrawerItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     String? route,
//     VoidCallback? onTap,
//     bool isActive = false,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: isActive ? Colors.blue : null),
//       title: Text(title, style: TextStyle(
//         fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//         color: isActive ? Colors.blue : null,
//       )),
//       tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
//       onTap: onTap ?? () {
//         Navigator.pop(context);
//         if (route != null) {
//           Navigator.pushNamed(context, route);
//         }
//       },
//     );
//   }

//   Color _getUserColor(String role) {
//     switch (role) {
//       case 'admin':
//         return Colors.purple;
//       case 'owner':
//         return Colors.blue;
//       case 'user':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getUserIcon(String role) {
//     switch (role) {
//       case 'admin':
//         return Icons.admin_panel_settings;
//       case 'owner':
//         return Icons.business;
//       case 'user':
//         return Icons.person;
//       default:
//         return Icons.person_outline;
//     }
//   }
   
//    if (userRole == 'owner')
//   _buildDrawerItem(
//     context: context,
//     icon: Icons.search,
//     title: 'Voir tous les logements',
//     route: '/all-logements',
//     isActive: ModalRoute.of(context)?.settings.name == '/all-logements',
//   ),

// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();
//     final currentUser = authViewModel.currentUser;
//     final userRole = currentUser?.role ?? 'guest';

//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // En-tête avec informations utilisateur
//           UserAccountsDrawerHeader(
//             accountName: Text(
//               currentUser?.nom ?? 'Invité',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             accountEmail: Text(currentUser?.email ?? ''),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(
//                 _getUserIcon(userRole),
//                 color: _getUserColor(userRole),
//                 size: 40,
//               ),
//             ),
//             decoration: BoxDecoration(
//               color: _getUserColor(userRole),
//             ),
//           ),
          
//           // Section Accueil
//           _buildDrawerSection(
//             title: 'Navigation',
//             children: [
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.home,
//                 title: 'Accueil',
//                 route: '/home',
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.search,
//                 title: 'Recherche',
//                 route: '/search',
//               ),
//               if (currentUser != null)
//                 _buildDrawerItem(
//                   context: context,
//                   icon: Icons.favorite,
//                   title: 'Mes Favoris',
//                   route: '/favorites',
//                 ),
//             ],
//           ),
          
//           const Divider(),
          
//           // Section Compte
//           _buildDrawerSection(
//             title: 'Mon Compte',
//             children: [
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.person,
//                 title: 'Mon Profil',
//                 route: '/profile',
//               ),
//               if (userRole == 'owner')
//                 _buildDrawerItem(
//                   context: context,
//                   icon: Icons.business,
//                   title: 'Mes Logements',
//                   route: '/owner-logements',
//                 ),
//               if (userRole == 'owner')
//                 _buildDrawerItem(
//                   context: context,
//                   icon: Icons.add_home,
//                   title: 'Publier un logement',
//                   route: '/add-logement',
//                 ),
//               if (userRole == 'admin')
//                 _buildDrawerItem(
//                   context: context,
//                   icon: Icons.admin_panel_settings,
//                   title: 'Administration',
//                   route: '/admin',
//                 ),
//             ],
//           ),
          
//           const Divider(),
          
//           // Section Autres
//           _buildDrawerSection(
//             title: 'Autres',
//             children: [
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.settings,
//                 title: 'Paramètres',
//                 route: '/settings',
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.help_outline,
//                 title: 'Aide & Support',
//                 route: '/help',
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.info,
//                 title: 'À propos',
//                 route: '/about',
//               ),
//             ],
//           ),
          
//           const Divider(),
          
//           // Déconnexion ou Connexion
//           if (currentUser != null)
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
//               onTap: () async {
//                 Navigator.pop(context);
//                 await authViewModel.logout();
//                 Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//               },
//             )
//           else
//             ListTile(
//               leading: const Icon(Icons.login, color: Colors.green),
//               title: const Text('Connexion', style: TextStyle(color: Colors.green)),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/login');
//               },
//             ),
          
//           // Informations de version
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Location App',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Version 1.0.0',
//                   style: TextStyle(fontSize: 10, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildDrawerItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required String route,
//   }) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushNamed(context, route);
//       },
//     );
//   }

//   Color _getUserColor(String role) {
//     switch (role) {
//       case 'admin':
//         return Colors.purple;
//       case 'owner':
//         return Colors.blue;
//       case 'user':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getUserIcon(String role) {
//     switch (role) {
//       case 'admin':
//         return Icons.admin_panel_settings;
//       case 'owner':
//         return Icons.business;
//       case 'user':
//         return Icons.person;
//       default:
//         return Icons.person_outline;
//     }
//   }

//   // Méthode pour obtenir l'initial du nom
//   String _getInitials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return name[0].toUpperCase();
//   }
// }
