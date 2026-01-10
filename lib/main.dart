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

// Import des nouvelles pages de paramètres
import '../views/settings/settings_page.dart';  // AJOUT IMPORT
import '../views/settings/help_support_page.dart';  // AJOUT IMPORT
import '../views/settings/about_page.dart';  // AJOUT IMPORT


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
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onUnknownRoute: AppRoutes.onUnknownRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
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
// import '';

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
//       ],
//       child: MaterialApp(
//         title: 'Application de Location',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         // Utilisez les routes définies dans AppRoutes
//         initialRoute: AppRoutes.splash,
//         routes: AppRoutes.routes,
//         onUnknownRoute: AppRoutes.onUnknownRoute,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
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

// // Import des pages (pour les routes directes)
// import 'views/splash/splash_page.dart';
// import 'views/auth/page_connexion.dart';
// import 'views/auth/register_page.dart';
// import 'views/profile/page_profil.dart';
// import 'views/owner/page_acceuil_owner.dart';
// import 'views/owner/mes_logement.dart';
// import 'views/admin/dashboard_page.dart';
// import 'views/logement/logement_page.dart';
// import 'views/users/page_acceuil_users.dart';
// import 'views/home/page_acceuil.dart';
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
//       ],
//       child: MaterialApp(
//         title: 'Application de Location',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         // ✅ CORRECTION : Définissez les routes directement ici
//         initialRoute: '/',
//         routes: {
//           // Route d'accueil/splash
//           '/': (context) => const SplashPage(),
          
//           // Routes d'authentification
//           '/login': (context) => const PageConnexion(),
//           '/register': (context) {
//             // Import dynamique pour éviter les erreurs de const
//             final registerPage = 
//                 // ignore: unnecessary_cast
//                 (const RegisterPage() as Widget);
//             return registerPage;
//           },
          
//           // Routes principales
//           '/home': (context) => const PageAcceuil(),
//           '/profile': (context) {
//             final pageProfil = 
//                 // ignore: unnecessary_cast
//                 (const PageProfil() as Widget);
//             return pageProfil;
//           },
          
//           // Routes propriétaire
//           '/owner-home': (context) => const PageAcceuilOwner(),
//           '/owner-logements': (context) => const MesLogements(),
          
//           // Route administrateur - SANS const
//           '/admin': (context) => DashboardPage(),
          
//           // Routes logement
//           '/logement-details': (context) => const LogementPage(),
          
//           // Route utilisateur spécifique
//           '/user-home': (context) => const PageAcceuilUsers(),
//         },
//         // Route par défaut pour les erreurs
//         onUnknownRoute: (settings) {
//           return MaterialPageRoute(
//             builder: (context) => Scaffold(
//               appBar: AppBar(title: const Text('Erreur')),
//               body: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error, size: 60, color: Colors.red),
//                     const SizedBox(height: 20),
//                     Text('Page "${settings.name}" non trouvée'),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pushNamed(context, '/'),
//                       child: const Text('Retour à l\'accueil'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// // Page de chargement initial SIMPLIFIÉE
// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     print("📱 SplashPage initState()");
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeApp();
//     });
//   }

//   Future<void> _initializeApp() async {
//     print("🔄 Début de l'initialisation");
    
//     try {
//       // Initialiser l'utilisateur
//       final authViewModel = context.read<AuthViewModel>();
//       await authViewModel.initializeUser().timeout(
//         const Duration(seconds: 5),
//         onTimeout: () {
//           print("⏰ Timeout - continuation sans utilisateur");
//           return;
//         },
//       );
      
//       print("✅ Utilisateur chargé: ${authViewModel.currentUser?.email ?? 'null'}");
      
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       if (!mounted) return;
      
//       // Navigation selon l'état de connexion
//       final user = authViewModel.currentUser;
      
//       if (user == null) {
//         Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         switch (user.role) {
//           case 'admin':
//             Navigator.pushReplacementNamed(context, '/admin');
//             break;
//           case 'owner':
//             Navigator.pushReplacementNamed(context, '/owner-home');
//             break;
//           case 'user':
//             Navigator.pushReplacementNamed(context, '/user-home');
//             break;
//           default:
//             Navigator.pushReplacementNamed(context, '/home');
//         }
//       }
      
//     } catch (e) {
//       print("❌ Erreur: $e");
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(color: Colors.white),
//             const SizedBox(height: 20),
//             const Text(
//               'Chargement...',
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//             Consumer<AuthViewModel>(
//               builder: (context, auth, child) {
//                 if (auth.errorMessage != null) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       auth.errorMessage!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
















