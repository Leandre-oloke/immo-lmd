import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Afficher les erreurs
              if (authViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 16),
              
              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: Validators.validatePassword,
                obscureText: true,
              ),
              
              const SizedBox(height: 24),
              
              // Bouton connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authViewModel.isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await authViewModel.login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      
                      if (success && context.mounted) {
                        // Navigation basée sur le rôle
                        final user = authViewModel.currentUser;
                        if (user?.role == 'admin') {
                          Navigator.pushReplacementNamed(context, '/admin');
                        } else if (user?.role == 'owner') {
                          Navigator.pushReplacementNamed(context, '/owner');
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    }
                  },
                  child: authViewModel.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Se connecter'),
                ),
              ),
              
              // Lien vers inscription
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';

// class PageConnexion extends StatefulWidget {
//   const PageConnexion({super.key});

//   @override
//   State<PageConnexion> createState() => _PageConnexionState();
// }

// class _PageConnexionState extends State<PageConnexion> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login(BuildContext context) async {
//     final authVM = context.read<AuthViewModel>();

//     if (_emailController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Veuillez remplir tous les champs")),
//       );
//       return;
//     }

//     final success = await authVM.login(
//       _emailController.text.trim(),
//       _passwordController.text.trim(),
//     );

//     if (!mounted) return;

//     if (success) {
//       Navigator.pushReplacementNamed(context, authVM.nextRoute);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Erreur de connexion"),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = context.watch<AuthViewModel>().isLoading;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Connexion"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Mot de passe',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),

//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : () => _login(context),
//                 child: isLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Text("Se connecter"),
//               ),
//             ),

//             const SizedBox(height: 12),

//             TextButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/auth/register');
//               },
//               child: const Text("Créer un compte"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//}
