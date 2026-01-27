import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Import des ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/logement_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/owner_viewmodel.dart';
import 'viewmodels/users_viewmodel.dart';

// Import des routes
import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚀 Démarrage de l'application");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialisé avec succès");
  } catch (e) {
    print("❌ Erreur Firebase: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthViewModel doit être en premier et lazy: false
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => LogementViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => OwnerViewModel()),
        ChangeNotifierProvider(create: (_) => UsersViewModel()),
      ],
      child: MaterialApp(
        title: 'Application de Location',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        navigatorKey: AppRoutes.navigatorKey,
        navigatorObservers: [
          _RouteObserver(),
        ],
      ),
    );
  }
}

// Observateur de routes pour déboguer la navigation
class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('📍 Route pushed: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('🔄 Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('🔙 Route popped: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('🗑️ Route removed: ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }
}








// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:provider/provider.dart';

// // Import des ViewModels
// import 'viewmodels/auth_viewmodel.dart';
// import 'viewmodels/logement_viewmodel.dart';
// import 'viewmodels/admin_viewmodel.dart';
// import 'viewmodels/owner_viewmodel.dart';
// import 'viewmodels/users_viewmodel.dart';

// // Import des routes
// import 'routes/routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   print("🚀 Démarrage de l'application");
  
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("✅ Firebase initialisé avec succès");
//   } catch (e) {
//     print("❌ Erreur Firebase: $e");
//   }
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // AuthViewModel doit être en premier et lazy: false
//         ChangeNotifierProvider(
//           create: (_) => AuthViewModel(),
//           lazy: false,
//         ),
//         ChangeNotifierProvider(create: (_) => LogementViewModel()),
//         ChangeNotifierProvider(create: (_) => AdminViewModel()),
//         ChangeNotifierProvider(create: (_) => OwnerViewModel()),
//         ChangeNotifierProvider(create: (_) => UsersViewModel()),
//       ],
//       child: MaterialApp(
//         title: 'Application de Location',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//           useMaterial3: true,
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: AppRoutes.onGenerateRoute,
//         navigatorKey: AppRoutes.navigatorKey,
//         // ✅ IMPORTANT : Désactive les transitions par défaut
//         navigatorObservers: [
//           _RouteObserver(),
//         ],
//       ),
//     );
//   }
// }

// // Observateur de routes pour éviter les doubles navigations
// class _RouteObserver extends NavigatorObserver {
//   @override
//   void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     print('📍 Route pushed: ${route.settings.name}');
//   }

//   @override
//   void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
//     print('🔄 Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:provider/provider.dart';

// // Import des ViewModels
// import 'viewmodels/auth_viewmodel.dart';
// import 'viewmodels/logement_viewmodel.dart';
// import 'viewmodels/admin_viewmodel.dart';
// import 'viewmodels/owner_viewmodel.dart';
// import 'viewmodels/users_viewmodel.dart';

// // Import des routes
// import 'routes/routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   print("🚀 Démarrage de l'application");
  
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("✅ Firebase initialisé avec succès");
//   } catch (e) {
//     print("❌ Erreur Firebase: $e");
//   }
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // AuthViewModel doit être en premier
//         ChangeNotifierProvider(
//           create: (_) => AuthViewModel(),
//           lazy: false, // Initialisé immédiatement
//         ),
//         ChangeNotifierProvider(create: (_) => LogementViewModel()),
//         ChangeNotifierProvider(create: (_) => AdminViewModel()),
//         ChangeNotifierProvider(create: (_) => OwnerViewModel()),
//         ChangeNotifierProvider(create: (_) => UsersViewModel()),
//       ],
//       child: MaterialApp(
//         title: 'Application de Location',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//           useMaterial3: true,
//         ),
//         // Désactive temporairement les animations pour debug
//         debugShowCheckedModeBanner: true,
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: AppRoutes.onGenerateRoute,
//         navigatorKey: AppRoutes.navigatorKey,
//       ),
//     );
//   }
// }










//==============================================================================
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
//==============================================================================
//======================= ANCIEN MAIN.DART ===================================
// import 'firebase_options.dart';
// import 'package:provider/provider.dart';

// // Import des ViewModels
// import 'viewmodels/auth_viewmodel.dart';
// import 'viewmodels/logement_viewmodel.dart';
// import 'viewmodels/admin_viewmodel.dart';
// import 'viewmodels/owner_viewmodel.dart';
// import 'viewmodels/users_viewmodel.dart';
// //import 'viewmodels/notification_viewmodel.dart';  // AJOUT

// // Import des routes
// import 'routes/routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   print("🚀 Démarrage de l'application");
  
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("✅ Firebase initialisé avec succès");
//   } catch (e) {
//     print("❌ Erreur Firebase: $e");
//   }
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => LogementViewModel()),
//         ChangeNotifierProvider(create: (_) => AdminViewModel()),
//         ChangeNotifierProvider(create: (_) => OwnerViewModel()),
//         ChangeNotifierProvider(create: (_) => UsersViewModel()),
//         //ChangeNotifierProvider(create: (_) => NotificationViewModel()),  // AJOUT
//       ],
//       child: MaterialApp(
//         title: 'Application de Location',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         initialRoute: AppRoutes.splash,
//         routes: AppRoutes.routes,
//         onUnknownRoute: AppRoutes.onUnknownRoute,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }







