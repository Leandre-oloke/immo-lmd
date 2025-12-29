import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Attendre un court instant pour l'effet visuel
    await Future.delayed(const Duration(seconds: 1));
    
    // Initialiser l'utilisateur
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.initializeUser();
    
    // La redirection sera gérée par RootWidget dans main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(
              Icons.home,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Titre
            const Text(
              'Location App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Sous-titre
            const Text(
              'Trouvez votre logement idéal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            // Indicateur de chargement
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Texte de chargement
            const Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../repositories/auth_repository.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     await Future.delayed(const Duration(seconds: 1));

//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       Navigator.pushReplacementNamed(context, '/auth/login');
//     } else {
//       final role = await AuthRepository().getUserRole(user.uid);

//       if (role == 'admin') {
//         Navigator.pushReplacementNamed(context, '/admin/dashboard');
//       } else if (role == 'owner') {
//         Navigator.pushReplacementNamed(context, '/owner/home');
//       } else {
//         Navigator.pushReplacementNamed(context, '/users/home');
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
