import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';
import '../admin/dashboard_page.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;

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
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône maison
                    const Icon(Icons.home, size: 60, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text(
                      "Bienvenue",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // ERREURS
                    if (authViewModel.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authViewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        label: 'Email',
                        icon: Icons.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _inputDecoration(
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        suffix: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),

                    // Bouton connexion
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authViewModel.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await authViewModel.login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                                  if (success && context.mounted) {
                                    final user = authViewModel.currentUser;
                                    if (user?.role == 'admin') {
                                      Navigator.pushReplacementNamed(
                                         // context, '/admin');
                                          context, '/admin-home');
                                    } else if (user?.role == 'owner') {
                                      Navigator.pushReplacementNamed(
                                          context, '/owner-home');
                                    } else {
                                      Navigator.pushReplacementNamed(
                                          context, '/home');
                                    }
                                  }
                                }
                              },
                        child: authViewModel.isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Se connecter',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lien vers inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Pas encore de compte ? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text("Créer un compte"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../utils/validators.dart';

// class PageConnexion extends StatefulWidget {
//   const PageConnexion({super.key});

//   @override
//   State<PageConnexion> createState() => _PageConnexionState();
// }

// class _PageConnexionState extends State<PageConnexion> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
  
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();
    
//     return Scaffold(
//       appBar: AppBar(title: const Text('Connexion')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Afficher les erreurs
//               if (authViewModel.errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: Text(
//                     authViewModel.errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),
              
//               // Email
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 validator: Validators.validateEmail,
//                 keyboardType: TextInputType.emailAddress,
//               ),
              
//               const SizedBox(height: 16),
              
//               // Mot de passe
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Mot de passe',
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 validator: Validators.validatePassword,
//                 obscureText: true,
//               ),
              
//               const SizedBox(height: 24),
              
//               // Bouton connexion
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: authViewModel.isLoading ? null : () async {
//                     if (_formKey.currentState!.validate()) {
//                       final success = await authViewModel.login(
//                         _emailController.text.trim(),
//                         _passwordController.text.trim(),
//                       );
                      
//                       if (success && context.mounted) {
//                         // Navigation basée sur le rôle
//                         final user = authViewModel.currentUser;
//                         if (user?.role == 'admin') {
//                           Navigator.pushReplacementNamed(context, '/admin');
//                         } else if (user?.role == 'owner') {
//                           Navigator.pushReplacementNamed(context, '/owner');
//                         } else {
//                           Navigator.pushReplacementNamed(context, '/home');
//                         }
//                       }
//                     }
//                   },
//                   child: authViewModel.isLoading
//                       ? const CircularProgressIndicator()
//                       : const Text('Se connecter'),
//                 ),
//               ),
              
//               // Lien vers inscription
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/register');
//                 },
//                 child: const Text('Créer un compte'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

