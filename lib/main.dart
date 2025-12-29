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

// Import des pages (pour les routes directes)
import 'views/splash/splash_page.dart';
import 'views/auth/page_connexion.dart';
import 'views/auth/register_page.dart';
import 'views/profile/page_profil.dart';
import 'views/owner/page_acceuil_owner.dart';
import 'views/owner/mes_logement.dart';
import 'views/admin/dashboard_page.dart';
import 'views/logement/logement_page.dart';
import 'views/users/page_acceuil_users.dart';
import 'views/home/page_acceuil.dart';
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
        // ✅ CORRECTION : Définissez les routes directement ici
        initialRoute: '/',
        routes: {
          // Route d'accueil/splash
          '/': (context) => const SplashPage(),
          
          // Routes d'authentification
          '/login': (context) => const PageConnexion(),
          '/register': (context) {
            // Import dynamique pour éviter les erreurs de const
            final registerPage = 
                // ignore: unnecessary_cast
                (const RegisterPage() as Widget);
            return registerPage;
          },
          
          // Routes principales
          '/home': (context) => const PageAcceuil(),
          '/profile': (context) {
            final pageProfil = 
                // ignore: unnecessary_cast
                (const PageProfil() as Widget);
            return pageProfil;
          },
          
          // Routes propriétaire
          '/owner-home': (context) => const PageAcceuilOwner(),
          '/owner-logements': (context) => const MesLogements(),
          
          // Route administrateur - SANS const
          '/admin': (context) => DashboardPage(),
          
          // Routes logement
          '/logement-details': (context) => const LogementPage(),
          
          // Route utilisateur spécifique
          '/user-home': (context) => const PageAcceuilUsers(),
        },
        // Route par défaut pour les erreurs
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 20),
                    Text('Page "${settings.name}" non trouvée'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/'),
                      child: const Text('Retour à l\'accueil'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Page de chargement initial SIMPLIFIÉE
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print("📱 SplashPage initState()");
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    print("🔄 Début de l'initialisation");
    
    try {
      // Initialiser l'utilisateur
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.initializeUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("⏰ Timeout - continuation sans utilisateur");
          return;
        },
      );
      
      print("✅ Utilisateur chargé: ${authViewModel.currentUser?.email ?? 'null'}");
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navigation selon l'état de connexion
      final user = authViewModel.currentUser;
      
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        switch (user.role) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/admin');
            break;
          case 'owner':
            Navigator.pushReplacementNamed(context, '/owner-home');
            break;
          case 'user':
            Navigator.pushReplacementNamed(context, '/user-home');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/home');
        }
      }
      
    } catch (e) {
      print("❌ Erreur: $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Chargement...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Consumer<AuthViewModel>(
              builder: (context, auth, child) {
                if (auth.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// TEST

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:provider/provider.dart';
// import 'viewmodels/auth_viewmodel.dart';
// import 'routes/routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   print("🚀 [DEBUG] Démarrage de l'application");
  
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print("✅ [DEBUG] Firebase initialisé");
//   } catch (e) {
//     print("❌ [DEBUG] Erreur Firebase: $e");
//   }
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => AuthViewModel(),
//       child: MaterialApp(
//         title: 'Test App',
//         theme: ThemeData(primarySwatch: Colors.blue),
//         home: const SafeLoadingPage(), // Page de test simple
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// class SafeLoadingPage extends StatefulWidget {
//   const SafeLoadingPage({super.key});

//   @override
//   State<SafeLoadingPage> createState() => _SafeLoadingPageState();
// }

// class _SafeLoadingPageState extends State<SafeLoadingPage> {
//   bool _isLoading = true;
//   String _status = "Initialisation...";

//   @override
//   void initState() {
//     super.initState();
//     _testConnection();
//   }

//   Future<void> _testConnection() async {
//     print("🧪 [DEBUG] Test de connexion démarré");
    
//     try {
//       final auth = context.read<AuthViewModel>();
      
//       setState(() => _status = "Chargement utilisateur...");
//       await auth.initializeUser().timeout(const Duration(seconds: 5));
      
//       final user = auth.currentUser;
//       print("👤 [DEBUG] Résultat: ${user?.email ?? 'non connecté'}");
      
//       setState(() => _status = "Navigation...");
      
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       if (!mounted) return;
      
//       // Aller directement à la page de connexion pour tester
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => Scaffold(
//             appBar: AppBar(title: const Text('Page de Test')),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.check, color: Colors.green, size: 60),
//                   const SizedBox(height: 20),
//                   const Text('Application fonctionnelle!',
//                     style: TextStyle(fontSize: 18)),
//                   const SizedBox(height: 10),
//                   Text('Utilisateur: ${user?.email ?? "non connecté"}'),
//                   const SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Tester la navigation vers login
//                       Navigator.pushNamed(context, AppRoutes.login);
//                     },
//                     child: const Text('Tester la page de connexion'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
      
//     } catch (e) {
//       print("❌ [DEBUG] Erreur test: $e");
//       setState(() => _status = "Erreur: $e");
      
//       if (mounted) {
//         // En cas d'erreur, aller à une page simple
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => Scaffold(
//               appBar: AppBar(title: const Text('Erreur')),
//               body: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error, color: Colors.red, size: 60),
//                     const SizedBox(height: 20),
//                     const Text('Problème d\'initialisation',
//                       style: TextStyle(fontSize: 18)),
//                     const SizedBox(height: 10),
//                     Text('Détail: $e'),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Retenter l'initialisation
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SafeLoadingPage()),
//                         );
//                       },
//                       child: const Text('Réessayer'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     } finally {
//       _isLoading = false;
//       print("🏁 [DEBUG] Test terminé");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 20),
//             Text(_status),
//             const SizedBox(height: 10),
//             if (_isLoading)
//               const Text('Patientez...', style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }




// IMPORTANT:

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
//         // Configuration des routes
//         initialRoute: AppRoutes.initialRoute,
//         routes: AppRoutes.getRoutes(),
//         onGenerateRoute: AppRoutes.onGenerateRoute,
//         onUnknownRoute: AppRoutes.onUnknownRoute,
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }

// // Page de chargement initial (remplacez SplashPage si nécessaire)
// class InitialLoadingPage extends StatefulWidget {
//   const InitialLoadingPage({super.key});

//   @override
//   State<InitialLoadingPage> createState() => _InitialLoadingPageState();
// }

// class _InitialLoadingPageState extends State<InitialLoadingPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Utiliser PostFrameCallback pour éviter setState during build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeApp();
//     });
//   }

//   Future<void> _initializeApp() async {
//     // Initialiser l'utilisateur
//     final authViewModel = context.read<AuthViewModel>();
//     await authViewModel.initializeUser();
    
//     // Petite pause pour l'animation
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     if (!mounted) return;
    
//     final user = authViewModel.currentUser;
    
//     // Naviguer vers la page appropriée
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//     } else {
//       // Rediriger selon le rôle
//       switch (user.role) {
//         case 'admin':
//           Navigator.pushReplacementNamed(context, AppRoutes.admin);
//           break;
//         case 'owner':
//           Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
//           break;
//         case 'user':
//           Navigator.pushReplacementNamed(context, AppRoutes.userHome);
//           break;
//         default:
//           Navigator.pushReplacementNamed(context, AppRoutes.home);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }





















// Ensuite, dans le fichier build.gradle.kts de votre module (au niveau de l'application), ajoutez le plug-in google-services et tous les SDK Firebase que vous souhaitez utiliser dans votre application :

// Fichier Gradle du module (au niveau de l'application) (<project>/<app-module>/build.gradle.kts) :
// plugins {
//   id("com.android.application")

//   // Add the Google services Gradle plugin
//   id("com.google.gms.google-services")

//   ...
// }

// dependencies {
//   // Import the Firebase BoM
//   implementation(platform("com.google.firebase:firebase-bom:34.7.0"))


//   // TODO: Add the dependencies for Firebase products you want to use
//   // When using the BoM, don't specify versions in Firebase dependencies
//   implementation("com.google.firebase:firebase-analytics")


//   // Add the dependencies for any other desired Firebase products
//   // https://firebase.google.com/docs/android/setup#available-libraries
// }




// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // 🔹 Config générée par FlutterFire

// // Pages
// import 'views/auth/page_connexion.dart';
// import 'views/auth/register_page.dart';
// import 'views/home/page_acceuil.dart';
// import 'views/users/page_acceuil_users.dart';
// import 'views/owner/page_acceuil_owner.dart';
// import 'views/owner/mes_logement.dart';
// import 'views/admin/dashboard_page.dart';

// // ViewModels
// import 'viewmodels/auth_viewmodel.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 🔹 Initialisation Firebase avec options pour Web et Mobile
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // AuthViewModel (attention à ne pas lancer de code Firebase dans le constructeur)
//   final AuthViewModel _authVM = AuthViewModel();

//   MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AppImmobilier',
//       debugShowCheckedModeBanner: false,
      
//       // 🔹 Route initiale de test (on peut changer ensuite)
//       home: const SplashPage(),

//       routes: {
//         '/auth/login': (_) => PageConnexion(),
//         '/auth/register': (_) => RegisterPage(),
//         '/home': (_) => PageAcceuil(),
//         '/users/home': (_) => PageAcceuilUsers(),
//         '/owner/home': (_) => PageAcceuilOwner(),
//         '/owner/mes-logements': (_) => MesLogements(),
//         '/admin/dashboard': (_) => DashboardPage(),
//       },
//     );
//   }
// }

// /// 🔹 Page de test ou splash
// /// Permet de vérifier que Firebase est bien initialisé avant de naviguer
// class SplashPage extends StatelessWidget {
//   const SplashPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 🔹 Ici tu peux ajouter un futur qui vérifie l'authentification Firebase
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text('Chargement...', style: TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }
