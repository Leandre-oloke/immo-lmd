import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import de toutes les pages nécessaires
import '../views/splash/splash_page.dart';
import '../views/auth/page_connexion.dart';
import '../views/auth/register_page.dart';
import '../views/home/page_acceuil.dart';
import '../views/profile/page_profil.dart';
import '../views/owner/page_acceuil_owner.dart';
import '../views/owner/mes_logement.dart';
import '../views/admin/dashboard_page.dart';
import '../views/admin/user_management_page.dart';
import '../views/admin/gestion_logement.dart';
import '../views/logement/logement_page.dart';
import '../views/users/page_acceuil_users.dart';
import '../views/owner/all_logements_page.dart';

// Import des nouvelles pages de paramètres
import '../views/settings/settings_page.dart';  // AJOUT IMPORT
import '../views/settings/help_support_page.dart';  // AJOUT IMPORT
import '../views/settings/about_page.dart';  // AJOUT IMPORT

import '../viewmodels/auth_viewmodel.dart';

class AppRoutes {
  // Routes d'authentification
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
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
  static const String favorites = '/favorites';
  static const String bookings = '/bookings';
  static const String search = '/search';

  // Routes pour gerer les utilisateurs et les logements
  static const String userManagement = '/admin/users';
  static const String propertyManagement = '/admin/properties';
  static const String adminLogements = '/admin/logements';
  static const String ownerProperties = '/owner/logements';
  static const String gestionLogement = '/admin/gestion-logement';
  static const String mesLogements = '/owner/mes-logements';
  static const String logement= '/logement/logement_page';
  
  // Middleware pour vérifier les rôles
  static WidgetBuilder _roleProtectedRoute({
    required WidgetBuilder builder,
    required List<String> allowedRoles,
  }) {
    return (context) {
      final authViewModel = context.read<AuthViewModel>();
      final user = authViewModel.currentUser;
      
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      if (!allowedRoles.contains(user.role)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _redirectToRoleHome(context, user.role);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      return builder(context);
    };
  }
  
  static void _redirectToRoleHome(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
        break;
      case 'owner':
        Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
        break;
      case 'user':
        Navigator.pushReplacementNamed(context, AppRoutes.userHome);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
  
  static Map<String, WidgetBuilder> get routes {
    return {
      // Routes publiques
      AppRoutes.splash: (context) => const SplashPage(),
      AppRoutes.login: (context) => const PageConnexion(),
      AppRoutes.register: (context) => const RegisterPage(),
      AppRoutes.allLogements: (context) => const AllLogementsPage(),
      
      // Page d'accueil générale
      AppRoutes.home: (context) {
        final authViewModel = context.read<AuthViewModel>();
        final user = authViewModel.currentUser;
        
        if (user == null) {
          return const PageAcceuil();
        }
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _redirectToRoleHome(context, user.role);
        });
        
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      
      // Pages protégées par rôle
      AppRoutes.adminHome: _roleProtectedRoute(
        builder: (context) => DashboardPage(),
        allowedRoles: ['admin'],
      ),
      
      AppRoutes.ownerHome: _roleProtectedRoute(
        builder: (context) => const PageAcceuilOwner(),
        allowedRoles: ['owner'],
      ),
      
      AppRoutes.userHome: _roleProtectedRoute(
        builder: (context) => const PageAcceuilUsers(),
        allowedRoles: ['user'],
      ),
      
      // Routes communes
      AppRoutes.profile: _roleProtectedRoute(
        builder: (context) => const PageProfil(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      AppRoutes.logementDetails: _roleProtectedRoute(
        builder: (context) => const LogementPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      // Routes propriétaire uniquement
      AppRoutes.ownerLogements: _roleProtectedRoute(
        builder: (context) => const MesLogements(),
        allowedRoles: ['owner'],
      ),
      
      // Routes admin uniquement
      AppRoutes.adminUsers: _roleProtectedRoute(
        builder: (context) => const UserManagementPage(),
        allowedRoles: ['admin'],
      ),
      
      AppRoutes.adminProperties: _roleProtectedRoute(
        builder: (context) => const AdminLogementsPage(),
        allowedRoles: ['admin'],
      ),

      // Nouvelles routes (accessibles à tous les utilisateurs connectés)
      AppRoutes.settings: _roleProtectedRoute(
        builder: (context) => const SettingsPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      AppRoutes.help: _roleProtectedRoute(
        builder: (context) => const HelpSupportPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      AppRoutes.about: _roleProtectedRoute(
        builder: (context) => const AboutPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),

      // Routes à implémenter plus tard (gardez-les en commentaire pour l'instant)
      /*
      AppRoutes.favorites: _roleProtectedRoute(
        builder: (context) => const FavoritesPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      
      AppRoutes.bookings: _roleProtectedRoute(
        builder: (context) => const BookingsPage(),
        allowedRoles: ['user', 'owner'],
      ),
      
      AppRoutes.search: _roleProtectedRoute(
        builder: (context) => const SearchPage(),
        allowedRoles: ['admin', 'owner', 'user'],
      ),
      */
    };
  }
  
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
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
                'Page "${settings.name}" non trouvée',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final auth = context.read<AuthViewModel>();
                  if (auth.isLoggedIn) {
                    if (auth.isAdmin) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.adminHome,
                        (route) => false,
                      );
                    } else if (auth.isOwner) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.ownerHome,
                        (route) => false,
                      );
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.userHome,
                        (route) => false,
                      );
                    }
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // AJOUTEZ CET IMPORT

// // Import de toutes les pages nécessaires
// import '../views/splash/splash_page.dart';
// import '../views/auth/page_connexion.dart';
// import '../views/auth/register_page.dart';
// import '../views/home/page_acceuil.dart';
// import '../views/profile/page_profil.dart';
// import '../views/owner/page_acceuil_owner.dart';
// import '../views/owner/mes_logement.dart';
// import '../views/admin/dashboard_page.dart';
// import '../views/admin/user_management_page.dart';
// import '../views/admin/gestion_logement.dart';
// import '../views/logement/logement_page.dart';
// import '../views/users/page_acceuil_users.dart';
// import '../views/owner/all_logements_page.dart'; // Import ajouté

// // CORRECTION: Un seul ../ au lieu de ../../
// import '../viewmodels/auth_viewmodel.dart';

// class AppRoutes {
//   // Routes d'authentification
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
  
// static const String allLogements = '/all-logements';


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

//   // Dans AppRoutes, ajoutez :
// static const String settings = '/settings';
// static const String help = '/help';
// static const String about = '/about';
// static const String favorites = '/favorites';
// static const String bookings = '/bookings';
// static const String search = '/search';
  
//   // Middleware pour vérifier les rôles
//   static WidgetBuilder _roleProtectedRoute({
//     required WidgetBuilder builder,
//     required List<String> allowedRoles,
//   }) {
//     return (context) {
//       final authViewModel = context.read<AuthViewModel>();
//       final user = authViewModel.currentUser;
      
//       // Si pas connecté, rediriger vers login
//       if (user == null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacementNamed(context, AppRoutes.login);
//         });
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
      
//       // Si rôle non autorisé, rediriger vers la page d'accueil appropriée
//       if (!allowedRoles.contains(user.role)) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _redirectToRoleHome(context, user.role);
//         });
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
      
//       // Rôle autorisé, afficher la page
//       return builder(context);
//     };
//   }
  
//   // Redirection vers la page d'accueil selon le rôle
//   static void _redirectToRoleHome(BuildContext context, String role) {
//     switch (role) {
//       case 'admin':
//         Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
//         break;
//       case 'owner':
//         Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
//         break;
//       case 'user':
//         Navigator.pushReplacementNamed(context, AppRoutes.userHome);
//         break;
//       default:
//         Navigator.pushReplacementNamed(context, AppRoutes.home);
//     }
//   }
  
//   // Routes principales avec protection par rôle
//   static Map<String, WidgetBuilder> get routes {
//     return {
//       // Routes publiques
//       AppRoutes.splash: (context) => const SplashPage(),
//       AppRoutes.login: (context) => const PageConnexion(),
//       AppRoutes.register: (context) => const RegisterPage(),
//       // Dans la Map routes :
//       AppRoutes.allLogements: (context) => const AllLogementsPage(),

      
//       // Page d'accueil générale (redirige selon le rôle)
//       AppRoutes.home: (context) {
//         final authViewModel = context.read<AuthViewModel>();
//         final user = authViewModel.currentUser;
        
//         if (user == null) {
//           return const PageAcceuil(); // Version publique
//         }
        
//         // Rediriger selon le rôle
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _redirectToRoleHome(context, user.role);
//         });
        
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
      
//       // Pages protégées par rôle
//       AppRoutes.adminHome: _roleProtectedRoute(
//         builder: (context) => DashboardPage(),
//         allowedRoles: ['admin'],
//       ),
      
//       AppRoutes.ownerHome: _roleProtectedRoute(
//         builder: (context) => const PageAcceuilOwner(),
//         allowedRoles: ['owner'],
//       ),
      
//       AppRoutes.userHome: _roleProtectedRoute(
//         builder: (context) => const PageAcceuilUsers(),
//         allowedRoles: ['user'],
//       ),
      
//       // Routes communes (accessible à tous les rôles connectés)
//       AppRoutes.profile: _roleProtectedRoute(
//         builder: (context) => const PageProfil(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
      
//       AppRoutes.logementDetails: _roleProtectedRoute(
//         builder: (context) => const LogementPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
      
//       // Routes propriétaire uniquement
//       AppRoutes.ownerLogements: _roleProtectedRoute(
//         builder: (context) => const MesLogements(),
//         allowedRoles: ['owner'],
//       ),
      
//       // Routes admin uniquement
//       AppRoutes.adminUsers: _roleProtectedRoute(
//         builder: (context) => const UserManagementPage(),
//         allowedRoles: ['admin'],
//       ),
      
//       AppRoutes.adminProperties: _roleProtectedRoute(
//         builder: (context) => const AdminLogementsPage(),
//         allowedRoles: ['admin'],
//       ),

//      '/settings': (context) => const SettingsPage(),
//   '/help': (context) => const HelpSupportPage(),
//   '/about': (context) => const AboutPage(),
//   // ... vos autres routes

//     };
//   }
  
//   // Route pour les erreurs (page non trouvée)
//   static Route<dynamic> onUnknownRoute(RouteSettings settings) {
//     return MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('Page non trouvée'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 size: 60,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Page "${settings.name}" non trouvée',
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Rediriger vers la page d'accueil appropriée
//                   final auth = context.read<AuthViewModel>();
//                   if (auth.isLoggedIn) {
//                     if (auth.isAdmin) {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.adminHome,
//                         (route) => false,
//                       );
//                     } else if (auth.isOwner) {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.ownerHome,
//                         (route) => false,
//                       );
//                     } else {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.userHome,
//                         (route) => false,
//                       );
//                     }
//                   } else {
//                     Navigator.pushNamedAndRemoveUntil(
//                       context,
//                       AppRoutes.login,
//                       (route) => false,
//                     );
//                   }
//                 },
//                 child: const Text('Retour à l\'accueil'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';

// // Import de toutes les pages nécessaires
// import '../views/splash/splash_page.dart';
// import '../views/auth/page_connexion.dart';
// import '../views/auth/register_page.dart';
// import '../views/home/page_acceuil.dart';
// import '../views/profile/page_profil.dart';
// import '../views/owner/page_acceuil_owner.dart';
// import '../views/owner/mes_logement.dart';
// import '../views/admin/dashboard_page.dart';
// import '../views/admin/user_management_page.dart';
// import '../views/admin/gestion_logement.dart';
// import '../views/logement/logement_page.dart';
// import '../views/users/page_acceuil_users.dart';
// // Vérifiez que cet import existe bien :
// import '../../viewmodels/auth_viewmodel.dart'; // Chemin relatif correct

// class AppRoutes {
//   // Routes d'authentification
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
  
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
  
//   // Middleware pour vérifier les rôles
//   static WidgetBuilder _roleProtectedRoute({
//     required WidgetBuilder builder,
//     required List<String> allowedRoles,
//   }) {
//     return (context) {
//       final authViewModel = context.read<AuthViewModel>();
//       final user = authViewModel.currentUser;
      
//       // Si pas connecté, rediriger vers login
//       if (user == null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushReplacementNamed(context, AppRoutes.login);
//         });
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
      
//       // Si rôle non autorisé, rediriger vers la page d'accueil appropriée
//       if (!allowedRoles.contains(user.role)) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _redirectToRoleHome(context, user.role);
//         });
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
      
//       // Rôle autorisé, afficher la page
//       return builder(context);
//     };
//   }
  
//   // Redirection vers la page d'accueil selon le rôle
//   static void _redirectToRoleHome(BuildContext context, String role) {
//     switch (role) {
//       case 'admin':
//         Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
//         break;
//       case 'owner':
//         Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
//         break;
//       case 'user':
//         Navigator.pushReplacementNamed(context, AppRoutes.userHome);
//         break;
//       default:
//         Navigator.pushReplacementNamed(context, AppRoutes.home);
//     }
//   }
  
//   // Routes principales avec protection par rôle
//   static Map<String, WidgetBuilder> get routes {
//     return {
//       // Routes publiques
//       AppRoutes.splash: (context) => const SplashPage(),
//       AppRoutes.login: (context) => const PageConnexion(),
//       AppRoutes.register: (context) => const RegisterPage(),
      
//       // Page d'accueil générale (redirige selon le rôle)
//       AppRoutes.home: (context) {
//         final authViewModel = context.read<AuthViewModel>();
//         final user = authViewModel.currentUser;
        
//         if (user == null) {
//           return const PageAcceuil(); // Version publique
//         }
        
//         // Rediriger selon le rôle
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _redirectToRoleHome(context, user.role);
//         });
        
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
      
//       // Pages protégées par rôle
//       AppRoutes.adminHome: _roleProtectedRoute(
//         builder: (context) => DashboardPage(),
//         allowedRoles: ['admin'],
//       ),
      
//       AppRoutes.ownerHome: _roleProtectedRoute(
//         builder: (context) => const PageAcceuilOwner(),
//         allowedRoles: ['owner'],
//       ),
      
//       AppRoutes.userHome: _roleProtectedRoute(
//         builder: (context) => const PageAcceuilUsers(),
//         allowedRoles: ['user'],
//       ),
      
//       // Routes communes (accessible à tous les rôles connectés)
//       AppRoutes.profile: _roleProtectedRoute(
//         builder: (context) => const PageProfil(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
      
//       AppRoutes.logementDetails: _roleProtectedRoute(
//         builder: (context) => const LogementPage(),
//         allowedRoles: ['admin', 'owner', 'user'],
//       ),
      
//       // Routes propriétaire uniquement
//       AppRoutes.ownerLogements: _roleProtectedRoute(
//         builder: (context) => const MesLogements(),
//         allowedRoles: ['owner'],
//       ),
      
//       // Routes admin uniquement
//       AppRoutes.adminUsers: _roleProtectedRoute(
//         builder: (context) => const UserManagementPage(),
//         allowedRoles: ['admin'],
//       ),
      
//       AppRoutes.adminProperties: _roleProtectedRoute(
//         builder: (context) => const AdminLogementsPage(),
//         allowedRoles: ['admin'],
//       ),
//     };
//   }
  
//   // Route pour les erreurs (page non trouvée)
//   static Route<dynamic> onUnknownRoute(RouteSettings settings) {
//     return MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('Page non trouvée'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 size: 60,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Page "${settings.name}" non trouvée',
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Rediriger vers la page d'accueil appropriée
//                   final auth = context.read<AuthViewModel>();
//                   if (auth.isLoggedIn) {
//                     if (auth.isAdmin) {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.adminHome,
//                         (route) => false,
//                       );
//                     } else if (auth.isOwner) {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.ownerHome,
//                         (route) => false,
//                       );
//                     } else {
//                       Navigator.pushNamedAndRemoveUntil(
//                         context,
//                         AppRoutes.userHome,
//                         (route) => false,
//                       );
//                     }
//                   } else {
//                     Navigator.pushNamedAndRemoveUntil(
//                       context,
//                       AppRoutes.login,
//                       (route) => false,
//                     );
//                   }
//                 },
//                 child: const Text('Retour à l\'accueil'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// Ajoutez ces importations
// import '../views/admin/user_management_page.dart';
// import '../views/admin/gestion_logement.dart';



// import 'package:flutter/material.dart';

// // Import de toutes les pages nécessaires
// import '../views/splash/splash_page.dart';
// import '../views/auth/page_connexion.dart';
// import '../views/auth/register_page.dart';
// import '../views/home/page_acceuil.dart';
// import '../views/profile/page_profil.dart';
// import '../views/owner/page_acceuil_owner.dart';
// import '../views/owner/mes_logement.dart';
// import '../views/admin/dashboard_page.dart';
// import '../views/logement/logement_page.dart';
// import '../views/users/page_acceuil_users.dart';

// class AppRoutes {
//   // Route initiale
//   static const String initialRoute = '/';
  
//   // Routes nommées
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String home = '/home';
//   static const String profile = '/profile';
//   static const String ownerHome = '/owner-home';
//   static const String ownerLogements = '/owner-logements';
//   static const String admin = '/admin';
//   static const String logementDetails = '/logement-details';
//   static const String userHome = '/user-home';

//   // ✅ CORRECTION : routesMap doit être une Map statique, pas un getter
//   static final Map<String, WidgetBuilder> routesMap = {
//     '/': (context) => const SplashPage(),
//     '/login': (context) => const PageConnexion(),
//     '/register': (context) => const RegisterPage(),
//     '/home': (context) => const PageAcceuil(),
//     '/profile': (context) => const PageProfil(),
//     '/owner-home': (context) => const PageAcceuilOwner(),
//     '/owner-logements': (context) => const MesLogements(),
//     '/admin': (context) => DashboardPage(), // Important : sans const
//     '/logement-details': (context) => const LogementPage(),
//     '/admin': (context) => const UserManagementPage(),
//     '/admin': (context) => const AdminLogementsPage(),
//     '/user-home': (context) => const PageAcceuilUsers(),
//   };

//   // Alternative : méthode getter (si vous préférez)
//   static Map<String, WidgetBuilder> get routes {
//     return {
//       '/': (context) => const SplashPage(),
//       '/login': (context) => const PageConnexion(),
//       '/register': (context) => const RegisterPage(),
//       '/home': (context) => const PageAcceuil(),
//       '/profile': (context) => const PageProfil(),
//       '/owner-home': (context) => const PageAcceuilOwner(),
//       '/owner-logements': (context) => const MesLogements(),
//       '/admin': (context) => DashboardPage(),
//       '/logement-details': (context) => const LogementPage(),
//       '/user-home': (context) => const PageAcceuilUsers(),
//     };
//   }

//   // Route pour les erreurs (page non trouvée)
//   static Route<dynamic> onUnknownRoute(RouteSettings settings) {
//     return MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(
//           title: const Text('Page non trouvée'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 size: 60,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Page "${settings.name}" non trouvée',
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     home,
//                     (route) => false,
//                   );
//                 },
//                 child: const Text('Retour à l\'accueil'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

