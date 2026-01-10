import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _initialized = false;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    print("📱 SplashPage initState()");
    
    // Délai pour s'assurer que le widget est monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (_initialized) return; // Éviter les appels multiples
    _initialized = true;
    
    print("🔄 Début de l'initialisation");
    
    try {
      // Initialiser l'utilisateur
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      // Timeout pour éviter l'attente infinie
      await authViewModel.initializeUser().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("⏰ Timeout - continuation sans utilisateur");
          return;
        },
      );
      
      print("✅ Utilisateur chargé: ${authViewModel.currentUser?.email ?? 'null'}");
      
      // Petit délai pour l'animation
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navigation selon l'état de connexion
      final user = authViewModel.currentUser;
      
      if (user == null) {
        print("➡️ Redirection vers /login (non connecté)");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("➡️ Utilisateur connecté, rôle: ${user.role}");
        switch (user.role) {
          case 'admin':
            print("➡️ Redirection vers /admin-home");
            Navigator.pushReplacementNamed(context, '/admin-home');
            break;
          case 'owner':
            print("➡️ Redirection vers /owner-home");
            Navigator.pushReplacementNamed(context, '/owner-home');
            break;
          case 'user':
            print("➡️ Redirection vers /user-home");
            Navigator.pushReplacementNamed(context, '/user-home');
            break;
          default:
            print("➡️ Redirection vers /home (rôle inconnu)");
            Navigator.pushReplacementNamed(context, '/home');
        }
      }
      
    } catch (e, stackTrace) {
      _errorOccurred = true;
      print("❌ ERREUR dans _initializeApp: $e");
      print("📝 Stack trace: $stackTrace");
      
      if (mounted) {
        // En cas d'erreur, aller à la page d'accueil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Retry après délai
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
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
            // Logo/Animation
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.home,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            
            // Indicateur de chargement
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            
            // Texte
            const Text(
              'Chargement...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            
            // Message d'erreur si besoin
            if (_errorOccurred)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.error, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      'Problème de connexion',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorOccurred = false;
                          _initialized = false;
                        });
                        _initializeApp();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     // Attendre un court instant pour l'effet visuel
//     await Future.delayed(const Duration(seconds: 1));
    
//     // Initialiser l'utilisateur
//     final authViewModel = context.read<AuthViewModel>();
//     await authViewModel.initializeUser();
    
//     // La redirection sera gérée par RootWidget dans main.dart
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             const Icon(
//               Icons.home,
//               size: 100,
//               color: Colors.white,
//             ),
//             const SizedBox(height: 20),
//             // Titre
//             const Text(
//               'Location App',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             // Sous-titre
//             const Text(
//               'Trouvez votre logement idéal',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 50),
//             // Indicateur de chargement
//             const CircularProgressIndicator(
//               color: Colors.white,
//             ),
//             const SizedBox(height: 20),
//             // Texte de chargement
//             const Text(
//               'Chargement...',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
