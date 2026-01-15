import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import de toutes les pages nécessaires
import '../views/splash/splash_page.dart';
import '../views/auth/page_connexion.dart';
import '../views/auth/register_page.dart';
import '../views/auth/change_password_page.dart';
import '../views/home/page_acceuil.dart';
import '../views/profile/page_profil.dart';
import '../views/owner/page_acceuil_owner.dart';
import '../views/owner/mes_logement.dart';
import '../views/admin/dashboard_page.dart';
import '../views/admin/user_management_page.dart';
import '../views/admin/gestion_logement.dart';
import '../views/logement/logement_page.dart';
import '../views/logement/favoris.dart';
import '../views/users/page_acceuil_users.dart';
import '../views/owner/all_logements_page.dart';

// Import des pages de paramètres
import '../views/settings/settings_page.dart';
import '../views/settings/help_support_page.dart';
import '../views/settings/about_page.dart';

// Import de la page notifications
import '../views/notifications/notifications_page.dart';

// Import de la page détails (bottom sheet)
import '../views/logement/details_bottom_sheet.dart'; // ✅ AJOUT

import '../viewmodels/auth_viewmodel.dart';

class AppRoutes {
  // Clé pour navigation globale
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Routes d'authentification
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String changePassword = '/change-password';
  static const String allLogements = '/all-logements';

  // Routes par rôle
  static const String home = '/home';
  static const String ownerHome = '/owner-home';
  static const String adminHome = '/admin-home';
  static const String userHome = '/user-home';

  // Routes fonctionnelles
  static const String profile = '/profile';
  static const String ownerLogements = '/owner-logements';
  static const String logementDetails = '/logement-details';
  
  // Routes admin spécifiques
  static const String adminUsers = '/admin/users';
  static const String adminProperties = '/admin/properties';

  // Nouvelles routes
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String bookings = '/bookings';
  static const String search = '/search';

  // Routes pour gerer les utilisateurs et les logements
  static const String userManagement = '/admin/users-management';
  static const String propertyManagement = '/admin/properties-management';
  static const String adminLogements = '/admin/logements';
  static const String ownerProperties = '/owner/logements';
  static const String gestionLogement = '/admin/gestion-logement';
  static const String mesLogements = '/owner/mes-logements';
  static const String logement = '/logement/logement-page';

  // NOUVELLES ROUTES AJOUTÉES
  static const String detailsBottomSheet = '/logement/details';
  static const String contactOwner = '/contact/owner';
  static const String shareLogement = '/share/logement';

  // Page simple de chargement
  static Widget _buildLoadingScreen({String message = 'Chargement...'}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Redirection vers la page d'accueil selon le rôle
  static void _redirectToRoleHome(BuildContext context, String role) {
    // Évite les redirections multiples
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    String targetRoute;
    
    switch (role) {
      case 'admin':
        targetRoute = adminHome;
        break;
      case 'owner':
        targetRoute = ownerHome;
        break;
      case 'user':
        targetRoute = userHome;
        break;
      default:
        targetRoute = home;
    }
    
    // Ne redirige pas si déjà sur la bonne route
    if (currentRoute != targetRoute) {
      print("🔄 Redirection de $currentRoute vers $targetRoute (rôle: $role)");
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
          targetRoute,
          (route) => false,
        );
      });
    }
  }

  // Vérification d'authentification et de rôle
  static Future<bool> _checkAuthAndRole(
    BuildContext context, {
    bool requireAuth = true,
    List<String>? allowedRoles,
  }) async {
    final authViewModel = context.read<AuthViewModel>();
    
    // Vérifie si l'utilisateur est connecté
    if (requireAuth && !authViewModel.isLoggedIn) {
      print("🔒 Route protégée - Utilisateur non connecté");
      Future.microtask(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
          login,
          (route) => false,
        );
      });
      return false;
    }
    
    // Vérifie le rôle si nécessaire
    if (requireAuth && allowedRoles != null && authViewModel.isLoggedIn) {
      final userRole = authViewModel.currentUser?.role ?? '';
      if (!allowedRoles.contains(userRole)) {
        print("🚫 Rôle $userRole non autorisé pour cette route");
        Future.microtask(() {
          _redirectToRoleHome(context, userRole);
        });
        return false;
      }
    }
    
    return true;
  }

  // Générateur de route principal
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print("📍 Navigation vers: ${settings.name}");
    
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        // Routes publiques (pas besoin d'authentification)
        switch (settings.name) {
          case splash:
            return const SplashPage();
          case login:
            return const PageConnexion();
          case register:
            return const RegisterPage();
          case allLogements:
            return const AllLogementsPage();
        }
        
        // Route home intelligente
        if (settings.name == home) {
          final authViewModel = context.read<AuthViewModel>();
          
          if (!authViewModel.isLoggedIn) {
            return const PageAcceuil();
          }
          
          final userRole = authViewModel.currentUser?.role ?? '';
          return _RoleRedirector(role: userRole);
        }
        
        // Routes protégées par rôle
        final roleConfig = _getRouteRoleConfig(settings.name!);
        if (roleConfig != null) {
          return _ProtectedRoute(
            routeName: settings.name!,
            allowedRoles: roleConfig.allowedRoles,
            child: roleConfig.builder(context),
          );
        }
        
        // Gestion des routes spéciales (bottom sheets, etc.)
        // if (settings.name == detailsBottomSheet) {
        //   final args = settings.arguments;
        //   if (args is Map<String, dynamic> && args.containsKey('logement')) {
        //     final logement = args['logement'];
        //     // Pour un bottom sheet, on ne peut pas le retourner directement
        //     // On retourne une page temporaire qui affichera le bottom sheet
        //     return MaterialPageRoute(
        //       builder: (context) => Scaffold(
        //         appBar: AppBar(
        //           title: const Text('Détails du logement'),
        //           leading: IconButton(
        //             icon: const Icon(Icons.arrow_back),
        //             onPressed: () => Navigator.pop(context),
        //           ),
        //         ),
        //         body: Center(
        //           child: ElevatedButton(
        //             onPressed: () {
        //               showLogementDetails(context, logement);
        //             },
        //             child: const Text('Voir les détails'),
        //           ),
        //         ),
        //       ),
        //     );
        //   }
        // }
        
        // Page non trouvée
        return _buildNotFoundPage(settings.name!);
      },
    );
  }

  // Configuration des rôles par route
  static _RouteConfig? _getRouteRoleConfig(String routeName) {
    final configs = {
      // Routes admin
      adminHome: _RouteConfig(
        builder: (context) => const DashboardPage(),
        allowedRoles: ['admin'],
      ),
      adminUsers: _RouteConfig(
        builder: (context) => const UserManagementPage(),
        allowedRoles: ['admin'],
      ),
      adminProperties: _RouteConfig(
        builder: (context) => const AdminLogementsPage(), // ✅ CORRIGÉ : AdminLogementsPage → GestionLogement
        allowedRoles: ['admin'],
      ),
      userManagement: _RouteConfig(
        builder: (context) => const UserManagementPage(),
        allowedRoles: ['admin'],
      ),
      gestionLogement: _RouteConfig(
        builder: (context) => const AdminLogementsPage(),
        allowedRoles: ['admin'],
      ),
      adminLogements: _RouteConfig(
        builder: (context) => const AdminLogementsPage(),
        allowedRoles: ['admin'],
      ),
      
      // Routes owner
      ownerHome: _RouteConfig(
        builder: (context) => const PageAcceuilOwner(),
        allowedRoles: ['owner'],
      ),
      ownerLogements: _RouteConfig(
        builder: (context) => const MesLogements(),
        allowedRoles: ['owner'],
      ),
      mesLogements: _RouteConfig(
        builder: (context) => const MesLogements(),
        allowedRoles: ['owner'],
      ),
      ownerProperties: _RouteConfig(
        builder: (context) => const MesLogements(),
        allowedRoles: ['owner'],
      ),
      
      // Routes user
      userHome: _RouteConfig(
        builder: (context) => const PageAcceuilUsers(),
        allowedRoles: ['user'],
      ),
      
      // Routes communes (tous rôles)
      profile: _RouteConfig(
        builder: (context) => const PageProfil(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      logementDetails: _RouteConfig(
        builder: (context) => const LogementPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      logement: _RouteConfig(
        builder: (context) => const LogementPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      settings: _RouteConfig(
        builder: (context) => const SettingsPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      help: _RouteConfig(
        builder: (context) => const HelpSupportPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      about: _RouteConfig(
        builder: (context) => const AboutPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      notifications: _RouteConfig(
        builder: (context) => const NotificationsPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      changePassword: _RouteConfig(
        builder: (context) => const ChangePasswordPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      favorites: _RouteConfig(
        builder: (context) => const MesFavorisPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      // ✅ NOUVELLES ROUTES AJOUTÉES
      allLogements: _RouteConfig(
        builder: (context) => const AllLogementsPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
    };
    
    return configs[routeName];
  }

  // Navigation helper pour le bottom sheet
  static void navigateToLogementDetails(BuildContext context, dynamic logement) {
    showLogementDetails(context, logement);
  }

  // Navigation helper pour les favoris
  static void navigateToFavorites(BuildContext context) {
    Navigator.pushNamed(context, favorites);
  }

  // Navigation helper pour le profil
  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  // Navigation helper pour les paramètres
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

  // Navigation helper pour les notifications
  static void navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, notifications);
  }

  // Navigation helper pour changer le mot de passe
  static void navigateToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, changePassword);
  }

  // Navigation helper pour déconnexion
  static void navigateToLogout(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      login,
      (route) => false,
    );
  }

  // Page 404
  static Widget _buildNotFoundPage(String routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page non trouvée'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Page "$routeName" non trouvée',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                );
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour obtenir la route d'accueil selon le rôle
  static String getHomeRouteForRole(String? role) {
    switch (role) {
      case 'admin':
        return adminHome;
      case 'owner':
        return ownerHome;
      case 'user':
        return userHome;
      default:
        return home;
    }
  }

  // Méthode pour vérifier si une route est accessible
  static bool isRouteAccessible(String routeName, String userRole) {
    final config = _getRouteRoleConfig(routeName);
    if (config == null) return false;
    return config.allowedRoles.contains(userRole);
  }
}

// Widget pour gérer la redirection de rôle
class _RoleRedirector extends StatefulWidget {
  final String role;
  
  const _RoleRedirector({required this.role});
  
  @override
  State<_RoleRedirector> createState() => _RoleRedirectorState();
}

class _RoleRedirectorState extends State<_RoleRedirector> {
  bool _redirected = false;
  
  @override
  void initState() {
    super.initState();
    _performRedirect();
  }
  
  void _performRedirect() {
    if (!_redirected) {
      _redirected = true;
      Future.microtask(() {
        AppRoutes._redirectToRoleHome(context, widget.role);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppRoutes._buildLoadingScreen(
      message: 'Redirection vers votre espace...'
    );
  }
}

// Widget pour les routes protégées
class _ProtectedRoute extends StatefulWidget {
  final String routeName;
  final List<String> allowedRoles;
  final Widget child;
  
  const _ProtectedRoute({
    required this.routeName,
    required this.allowedRoles,
    required this.child,
  });
  
  @override
  State<_ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<_ProtectedRoute> {
  bool _isChecking = true;
  bool _accessGranted = false;
  
  @override
  void initState() {
    super.initState();
    _checkAccess();
  }
  
  Future<void> _checkAccess() async {
    final hasAccess = await AppRoutes._checkAuthAndRole(
      context,
      requireAuth: true,
      allowedRoles: widget.allowedRoles,
    );
    
    if (mounted) {
      setState(() {
        _isChecking = false;
        _accessGranted = hasAccess;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return AppRoutes._buildLoadingScreen(
        message: 'Vérification des permissions...'
      );
    }
    
    if (!_accessGranted) {
      return AppRoutes._buildLoadingScreen(
        message: 'Redirection...'
      );
    }
    
    return widget.child;
  }
}

// Configuration de route
class _RouteConfig {
  final Widget Function(BuildContext) builder;
  final List<String> allowedRoles;
  
  _RouteConfig({
    required this.builder,
    required this.allowedRoles,
  });
}




//==============================
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // Import de toutes les pages nécessaires
// import '../views/splash/splash_page.dart';
// import '../views/auth/page_connexion.dart';
// import '../views/auth/register_page.dart';
// import '../views/auth/change_password_page.dart';
// import '../views/home/page_acceuil.dart';
// import '../views/profile/page_profil.dart';
// import '../views/owner/page_acceuil_owner.dart';
// import '../views/owner/mes_logement.dart';
// import '../views/admin/dashboard_page.dart';
// import '../views/admin/user_management_page.dart';
// import '../views/admin/gestion_logement.dart';
// import '../views/logement/logement_page.dart';
// import '../views/logement/favoris.dart';
// import '../views/users/page_acceuil_users.dart';
// import '../views/owner/all_logements_page.dart';

// // Import des pages de paramètres
// import '../views/settings/settings_page.dart';
// import '../views/settings/help_support_page.dart';
// import '../views/settings/about_page.dart';

// // Import de la page notifications
// import '../views/notifications/notifications_page.dart';

// import '../viewmodels/auth_viewmodel.dart';

// class AppRoutes {
//   // Clé pour navigation globale
//   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
//   // Routes d'authentification
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String changePassword = '/change-password';
//   static const String allLogements = '/all-logements';

//   // Routes par rôle
//   static const String home = '/home';
//   static const String ownerHome = '/owner-home';
//   static const String adminHome = '/admin-home';
//   static const String userHome = '/user-home';

//   // Routes fonctionnelles
//   static const String profile = '/profile';
//   static const String ownerLogements = '/owner-logements';
//   static const String logementDetails = '/logement-details';
  
//   // Routes admin spécifiques
//   static const String adminUsers = '/admin/users';
//   static const String adminProperties = '/admin/properties';

//   // Nouvelles routes
//   static const String settings = '/settings';
//   static const String help = '/help';
//   static const String about = '/about';
//   static const String notifications = '/notifications';
//   static const String favorites = '/favorites';
//   static const String bookings = '/bookings';
//   static const String search = '/search';

//   // Routes pour gerer les utilisateurs et les logements
//   static const String userManagement = '/admin/users-management';
//   static const String propertyManagement = '/admin/properties-management';
//   static const String adminLogements = '/admin/logements';
//   static const String ownerProperties = '/owner/logements';
//   static const String gestionLogement = '/admin/gestion-logement';
//   static const String mesLogements = '/owner/mes-logements';
//   static const String logement = '/logement/logement-page';

//   // Page simple de chargement
//   static Widget _buildLoadingScreen({String message = 'Chargement...'}) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 20),
//             Text(
//               message,
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Redirection vers la page d'accueil selon le rôle
//   static void _redirectToRoleHome(BuildContext context, String role) {
//     // Évite les redirections multiples
//     final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
//     String targetRoute;
    
//     switch (role) {
//       case 'admin':
//         targetRoute = adminHome;
//         break;
//       case 'owner':
//         targetRoute = ownerHome;
//         break;
//       case 'user':
//         targetRoute = userHome;
//         break;
//       default:
//         targetRoute = home;
//     }
    
//     // Ne redirige pas si déjà sur la bonne route
//     if (currentRoute != targetRoute) {
//       print("🔄 Redirection de $currentRoute vers $targetRoute (rôle: $role)");
//       Future.microtask(() {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           targetRoute,
//           (route) => false,
//         );
//       });
//     }
//   }

//   // Vérification d'authentification et de rôle
//   static Future<bool> _checkAuthAndRole(
//     BuildContext context, {
//     bool requireAuth = true,
//     List<String>? allowedRoles,
//   }) async {
//     final authViewModel = context.read<AuthViewModel>();
    
//     // Vérifie si l'utilisateur est connecté
//     if (requireAuth && !authViewModel.isLoggedIn) {
//       print("🔒 Route protégée - Utilisateur non connecté");
//       Future.microtask(() {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           login,
//           (route) => false,
//         );
//       });
//       return false;
//     }
    
//     // Vérifie le rôle si nécessaire
//     if (requireAuth && allowedRoles != null && authViewModel.isLoggedIn) {
//       final userRole = authViewModel.currentUser?.role ?? '';
//       if (!allowedRoles.contains(userRole)) {
//         print("🚫 Rôle $userRole non autorisé pour cette route");
//         Future.microtask(() {
//           _redirectToRoleHome(context, userRole);
//         });
//         return false;
//       }
//     }
    
//     return true;
//   }

//   // Générateur de route principal
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     print("📍 Navigation vers: ${settings.name}");
    
//     return MaterialPageRoute(
//       settings: settings,
//       builder: (context) {
//         // Routes publiques (pas besoin d'authentification)
//         switch (settings.name) {
//           case splash:
//             return const SplashPage();
//           case login:
//             return const PageConnexion();
//           case register:
//             return const RegisterPage();
//           case allLogements:
//             return const AllLogementsPage();
//         }
        
//         // Route home intelligente
//         if (settings.name == home) {
//           final authViewModel = context.read<AuthViewModel>();
          
//           if (!authViewModel.isLoggedIn) {
//             return const PageAcceuil();
//           }
          
//           final userRole = authViewModel.currentUser?.role ?? '';
//           return _RoleRedirector(role: userRole);
//         }
        
//         // Routes protégées par rôle
//         final roleConfig = _getRouteRoleConfig(settings.name!);
//         if (roleConfig != null) {
//           return _ProtectedRoute(
//             routeName: settings.name!,
//             allowedRoles: roleConfig.allowedRoles,
//             child: roleConfig.builder(context),
//           );
//         }
        
//         // Page non trouvée
//         return _buildNotFoundPage(settings.name!);
//       },
//     );
//   }

//   // Configuration des rôles par route
//   static _RouteConfig? _getRouteRoleConfig(String routeName) {
//     final configs = {
//       // Routes admin
//       adminHome: _RouteConfig(
//         builder: (context) => const DashboardPage(),
//         allowedRoles: ['admin'],
//       ),
//       adminUsers: _RouteConfig(
//         builder: (context) => const UserManagementPage(),
//         allowedRoles: ['admin'],
//       ),
//       adminProperties: _RouteConfig(
//         builder: (context) => const AdminLogementsPage(),
//         allowedRoles: ['admin'],
//       ),
//       userManagement: _RouteConfig(
//         builder: (context) => const UserManagementPage(),
//         allowedRoles: ['admin'],
//       ),
//       gestionLogement: _RouteConfig(
//         builder: (context) => const AdminLogementsPage(),
//         allowedRoles: ['admin'],
//       ),
//       adminLogements: _RouteConfig(
//         builder: (context) => const AdminLogementsPage(),
//         allowedRoles: ['admin'],
//       ),
      
//       // Routes owner
//       ownerHome: _RouteConfig(
//         builder: (context) => const PageAcceuilOwner(),
//         allowedRoles: ['owner'],
//       ),
//       ownerLogements: _RouteConfig(
//         builder: (context) => const MesLogements(),
//         allowedRoles: ['owner'],
//       ),
//       mesLogements: _RouteConfig(
//         builder: (context) => const MesLogements(),
//         allowedRoles: ['owner'],
//       ),
//       ownerProperties: _RouteConfig(
//         builder: (context) => const MesLogements(),
//         allowedRoles: ['owner'],
//       ),
      
//       // Routes user
//       userHome: _RouteConfig(
//         builder: (context) => const PageAcceuilUsers(),
//         allowedRoles: ['user'],
//       ),
      
//       // Routes communes (tous rôles)
//       profile: _RouteConfig(
//         builder: (context) => const PageProfil(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       logementDetails: _RouteConfig(
//         builder: (context) => const LogementPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       logement: _RouteConfig(
//         builder: (context) => const LogementPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       settings: _RouteConfig(
//         builder: (context) => const SettingsPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       help: _RouteConfig(
//         builder: (context) => const HelpSupportPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       about: _RouteConfig(
//         builder: (context) => const AboutPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       notifications: _RouteConfig(
//         builder: (context) => const NotificationsPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       changePassword: _RouteConfig(
//         builder: (context) => const ChangePasswordPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//       favorites: _RouteConfig(
//         builder: (context) => const MesFavorisPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
//     };
    
//     return configs[routeName];
//   }

//   // Page 404
//   static Widget _buildNotFoundPage(String routeName) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Page non trouvée'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 60,
//               color: Colors.red,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Page "$routeName" non trouvée',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 navigatorKey.currentState?.pushNamedAndRemoveUntil(
//                   home,
//                   (route) => false,
//                 );
//               },
//               child: const Text('Retour à l\'accueil'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget pour gérer la redirection de rôle
// class _RoleRedirector extends StatefulWidget {
//   final String role;
  
//   const _RoleRedirector({required this.role});
  
//   @override
//   State<_RoleRedirector> createState() => _RoleRedirectorState();
// }

// class _RoleRedirectorState extends State<_RoleRedirector> {
//   bool _redirected = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _performRedirect();
//   }
  
//   void _performRedirect() {
//     if (!_redirected) {
//       _redirected = true;
//       Future.microtask(() {
//         AppRoutes._redirectToRoleHome(context, widget.role);
//       });
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return AppRoutes._buildLoadingScreen(
//       message: 'Redirection vers votre espace...'
//     );
//   }
// }

// // Widget pour les routes protégées
// class _ProtectedRoute extends StatefulWidget {
//   final String routeName;
//   final List<String> allowedRoles;
//   final Widget child;
  
//   const _ProtectedRoute({
//     required this.routeName,
//     required this.allowedRoles,
//     required this.child,
//   });
  
//   @override
//   State<_ProtectedRoute> createState() => _ProtectedRouteState();
// }

// class _ProtectedRouteState extends State<_ProtectedRoute> {
//   bool _isChecking = true;
//   bool _accessGranted = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _checkAccess();
//   }
  
//   Future<void> _checkAccess() async {
//     final hasAccess = await AppRoutes._checkAuthAndRole(
//       context,
//       requireAuth: true,
//       allowedRoles: widget.allowedRoles,
//     );
    
//     if (mounted) {
//       setState(() {
//         _isChecking = false;
//         _accessGranted = hasAccess;
//       });
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     if (_isChecking) {
//       return AppRoutes._buildLoadingScreen(
//         message: 'Vérification des permissions...'
//       );
//     }
    
//     if (!_accessGranted) {
//       return AppRoutes._buildLoadingScreen(
//         message: 'Redirection...'
//       );
//     }
    
//     return widget.child;
//   }
// }

// // Configuration de route
// class _RouteConfig {
//   final Widget Function(BuildContext) builder;
//   final List<String> allowedRoles;
  
//   _RouteConfig({
//     required this.builder,
//     required this.allowedRoles,
//   });
// }


