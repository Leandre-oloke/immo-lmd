import 'package:flutter/material.dart';

// Import de toutes les pages nécessaires
import '../views/splash/splash_page.dart';
import '../views/auth/page_connexion.dart';
import '../views/auth/register_page.dart';
import '../views/home/page_acceuil.dart';
import '../views/profile/page_profil.dart';
import '../views/owner/page_acceuil_owner.dart';
import '../views/owner/mes_logement.dart';
import '../views/admin/dashboard_page.dart';
import '../views/logement/logement_page.dart';
import '../views/users/page_acceuil_users.dart';

class AppRoutes {
  // Route initiale
  static const String initialRoute = '/';
  
  // Routes nommées
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String ownerHome = '/owner-home';
  static const String ownerLogements = '/owner-logements';
  static const String admin = '/admin';
  static const String logementDetails = '/logement-details';
  static const String userHome = '/user-home';

  // ✅ CORRECTION : routesMap doit être une Map statique, pas un getter
  static final Map<String, WidgetBuilder> routesMap = {
    '/': (context) => const SplashPage(),
    '/login': (context) => const PageConnexion(),
    '/register': (context) => const RegisterPage(),
    '/home': (context) => const PageAcceuil(),
    '/profile': (context) => const PageProfil(),
    '/owner-home': (context) => const PageAcceuilOwner(),
    '/owner-logements': (context) => const MesLogements(),
    '/admin': (context) => DashboardPage(), // Important : sans const
    '/logement-details': (context) => const LogementPage(),
    '/user-home': (context) => const PageAcceuilUsers(),
  };

  // Alternative : méthode getter (si vous préférez)
  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const SplashPage(),
      '/login': (context) => const PageConnexion(),
      '/register': (context) => const RegisterPage(),
      '/home': (context) => const PageAcceuil(),
      '/profile': (context) => const PageProfil(),
      '/owner-home': (context) => const PageAcceuilOwner(),
      '/owner-logements': (context) => const MesLogements(),
      '/admin': (context) => DashboardPage(),
      '/logement-details': (context) => const LogementPage(),
      '/user-home': (context) => const PageAcceuilUsers(),
    };
  }

  // Route pour les erreurs (page non trouvée)
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    home,
                    (route) => false,
                  );
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

//   // Table des routes
//   static Map<String, WidgetBuilder> getRoutes() {
//     return {
//       // Route d'accueil/splash
//       splash: (context) => const SplashPage(),
      
//       // Routes d'authentification
//       login: (context) => const PageConnexion(),
//       register: (context) => const RegisterPage(),
      
//       // Routes principales
//       home: (context) => const PageAcceuil(),
//       profile: (context) => const PageProfil(),
      
//       // Routes propriétaire
//       ownerHome: (context) => const PageAcceuilOwner(),
//       ownerLogements: (context) => const MesLogements(),
      
//       // Route administrateur
//       admin: (context) =>  DashboardPage(),
      
//       // Routes logement
//       logementDetails: (context) => const LogementPage(),
      
//       // Route utilisateur spécifique
//       userHome: (context) => const PageAcceuilUsers(),
//     };
//   }

//   // Générateur de routes pour les paramètres
//   static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//     // Vous pouvez gérer les routes dynamiques ici
//     // Ex: '/logement-details/:id'
    
//     // Pour l'instant, retourner null pour utiliser les routes standards
//     return null;
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

//   // Méthode utilitaire pour naviguer
//   static Future<T?> push<T>(BuildContext context, String routeName, {Object? arguments}) {
//     return Navigator.pushNamed(
//       context,
//       routeName,
//       arguments: arguments,
//     );
//   }

//   // Méthode pour remplacer la route actuelle
//   static Future<T?> pushReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
//     return Navigator.pushReplacementNamed(
//       context,
//       routeName,
//       arguments: arguments,
//     );
//   }

//   // Méthode pour aller à une route et supprimer toutes les autres
//   static Future<T?> pushAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments}) {
//     return Navigator.pushNamedAndRemoveUntil(
//       context,
//       routeName,
//       (route) => false,
//       arguments: arguments,
//     );
//   }

//   // Vérifier si une route existe
//   static bool routeExists(String routeName) {
//     return getRoutes().containsKey(routeName);
//   }

//   // Récupérer toutes les routes disponibles
//   static List<String> getAllRoutes() {
//     return getRoutes().keys.toList();
//   }

//   // Route protégée (exemple pour authentification)
//   static WidgetBuilder protectedRoute(WidgetBuilder builder, {required bool isAuthenticated}) {
//     return (context) {
//       if (!isAuthenticated) {
//         // Rediriger vers la page de connexion
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             login,
//             (route) => false,
//           );
//         });
//         return Container(); // Widget vide temporaire
//       }
//       return builder(context);
//     };
//   }

//   // Exemple d'usage dans main.dart
//   static void setupRoutes() {
//     // Cette méthode montre comment utiliser les routes
//     print('Routes disponibles: ${getAllRoutes().join(', ')}');
//   }
// }

// // Extension pour faciliter la navigation depuis n'importe quel BuildContext
// extension NavigationExtension on BuildContext {
//   void navigateTo(String route, {Object? arguments}) {
//     AppRoutes.push(this, route, arguments: arguments);
//   }

//   void navigateAndReplace(String route, {Object? arguments}) {
//     AppRoutes.pushReplacement(this, route, arguments: arguments);
//   }

//   void navigateAndClearStack(String route, {Object? arguments}) {
//     AppRoutes.pushAndRemoveUntil(this, route, arguments: arguments);
//   }

//   void goBack<T>([T? result]) {
//     Navigator.pop(this, result);
//   }

//   void goBackTo(String route) {
//     Navigator.popUntil(this, ModalRoute.withName(route));
//   }
// }

// // Classe pour gérer les arguments de navigation
// class RouteArguments {
//   final dynamic data;
//   final String? action;
//   final Map<String, dynamic>? extras;

//   RouteArguments({
//     this.data,
//     this.action,
//     this.extras,
//   });

//   // Méthode pour parser les arguments depuis les settings
//   factory RouteArguments.fromSettings(RouteSettings settings) {
//     if (settings.arguments is RouteArguments) {
//       return settings.arguments as RouteArguments;
//     }
//     return RouteArguments(data: settings.arguments);
//   }

//   // Récupérer un extra spécifique
//   T? getExtra<T>(String key) {
//     if (extras != null && extras!.containsKey(key)) {
//       return extras![key] as T?;
//     }
//     return null;
//   }
// }