import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();

  String _selectedRole = 'user';
  final List<String> _roles = ['user', 'owner'];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add,
                        size: 60, color: Colors.green),
                    const SizedBox(height: 10),
                    const Text(
                      "Inscription",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    /// ERREUR
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
                                style:
                                    const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// NOM
                    TextFormField(
                      controller: _nomController,
                      decoration: _inputDecoration(
                        label: 'Nom complet',
                        icon: Icons.person,
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    /// EMAIL
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

                    /// TELEPHONE
                    TextFormField(
                      controller: _telephoneController,
                      decoration: _inputDecoration(
                        label: 'Téléphone',
                        icon: Icons.phone,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),

                    /// ROLE
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: _inputDecoration(
                        label: 'Type de compte',
                        icon: Icons.account_circle,
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role == 'user'
                                ? 'Locataire'
                                : 'Propriétaire',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                    const SizedBox(height: 12),

                    /// DESCRIPTION ROLE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'user'
                            ? Colors.blue.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedRole == 'user'
                                ? Icons.person
                                : Icons.home_work,
                            color: _selectedRole == 'user'
                                ? Colors.blue
                                : Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedRole == 'user'
                                  ? 'Recherchez et réservez des logements.'
                                  : 'Publiez et gérez vos logements.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// MOT DE PASSE
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
                              _isPasswordVisible =
                                  !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    /// CONFIRMATION
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _inputDecoration(
                        label: 'Confirmer mot de passe',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value !=
                            _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    /// BOUTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authViewModel.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!
                                    .validate()) {
                                  final success =
                                      await authViewModel.register(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _nomController.text.trim(),
                                    _telephoneController.text.trim(),
                                    _selectedRole,
                                  );
                                     if (success && context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                           content: Text(
                                            "Compte créé avec succès. Veuillez vous connecter.",
                                             ),
                                                 backgroundColor: Colors.green,
                                               ),
                                               );

                                             Navigator.pushReplacementNamed(context, '/login');
                                          }

                                  // if (success && context.mounted) {
                                  //   Navigator.pushReplacementNamed(
                                  //     context,
                                  //     _selectedRole == 'owner'
                                  //         ? '/owner-home'
                                  //         : '/home',
                                  //   );
                                  // }
                                }
                              },
                        child: authViewModel.isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                "Créer mon compte",
                                style:
                                    TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// LIEN LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Déjà un compte ? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/login');
                          },
                          child: const Text("Se connecter"),
                        )
                      ],
                    )
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

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _nomController = TextEditingController();
//   final _telephoneController = TextEditingController();
  
//   String _selectedRole = 'user'; // Valeur par défaut
//   final List<String> _roles = ['user', 'owner']; // 'user' = locataire, 'owner' = propriétaire
  
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _nomController.dispose();
//     _telephoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Créer un compte'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Afficher les erreurs
//               if (authViewModel.errorMessage != null)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.error_outline, color: Colors.red),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           authViewModel.errorMessage!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Nom
//               TextFormField(
//                 controller: _nomController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nom complet*',
//                   prefixIcon: Icon(Icons.person),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: Validators.validateName,
//               ),
//               const SizedBox(height: 16),

//               // Email
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email*',
//                   prefixIcon: Icon(Icons.email),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: Validators.validateEmail,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),

//               // Téléphone
//               TextFormField(
//                 controller: _telephoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Téléphone*',
//                   prefixIcon: Icon(Icons.phone),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: Validators.validatePhone,
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),

//               // Sélection du rôle
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade400),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Type de compte*',
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 4),
//                     DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: _selectedRole,
//                         isExpanded: true,
//                         items: _roles.map((role) {
//                           return DropdownMenuItem<String>(
//                             value: role,
//                             child: Text(
//                               role == 'user' ? 'Locataire' : 'Propriétaire',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedRole = value!;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Description du rôle
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: _selectedRole == 'user' 
//                     ? Colors.blue.shade50 
//                     : Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       _selectedRole == 'user' ? Icons.person : Icons.business,
//                       color: _selectedRole == 'user' ? Colors.blue : Colors.green,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _selectedRole == 'user'
//                           ? 'En tant que locataire, vous pouvez rechercher et réserver des logements.'
//                           : 'En tant que propriétaire, vous pouvez publier et gérer vos logements.',
//                         style: TextStyle(
//                           color: _selectedRole == 'user' 
//                             ? Colors.blue.shade800 
//                             : Colors.green.shade800,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Mot de passe
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Mot de passe*',
//                   prefixIcon: Icon(Icons.lock),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: Validators.validatePassword,
//                 obscureText: true,
//               ),
//               const SizedBox(height: 16),

//               // Confirmation mot de passe
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Confirmer le mot de passe*',
//                   prefixIcon: Icon(Icons.lock),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Veuillez confirmer le mot de passe';
//                   }
//                   if (value != _passwordController.text) {
//                     return 'Les mots de passe ne correspondent pas';
//                   }
//                   return null;
//                 },
//                 obscureText: true,
//               ),
//               const SizedBox(height: 24),

//               // Bouton d'inscription
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: authViewModel.isLoading ? null : () async {
//                     if (_formKey.currentState!.validate()) {
//                       final success = await authViewModel.register(
//                         _emailController.text.trim(),
//                         _passwordController.text.trim(),
//                         _nomController.text.trim(),
//                         _telephoneController.text.trim(),
//                         _selectedRole, // Ajout du rôle
//                       );

//                       if (success && context.mounted) {
//                         // Redirection selon le rôle
//                         final user = authViewModel.currentUser;
//                         if (user?.role == 'owner') {
//                           Navigator.pushReplacementNamed(context, '/owner-home');
//                         } else {
//                           Navigator.pushReplacementNamed(context, '/home');
//                         }
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: authViewModel.isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text(
//                           'Créer mon compte',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Lien vers connexion
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Déjà un compte ?'),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/login');
//                     },
//                     child: const Text('Se connecter'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }










// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../viewmodels/auth_viewmodel.dart';
// // import '../../utils/validators.dart';

// // class RegisterPage extends StatefulWidget {
// //   const RegisterPage({super.key});

// //   @override
// //   State<RegisterPage> createState() => _RegisterPageState();
// // }

// // class _RegisterPageState extends State<RegisterPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _confirmPasswordController = TextEditingController();
// //   final _nomController = TextEditingController();
// //   final _telephoneController = TextEditingController();
  
// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     _confirmPasswordController.dispose();
// //     _nomController.dispose();
// //     _telephoneController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final authViewModel = context.watch<AuthViewModel>();
    
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Créer un compte'),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               // Afficher les erreurs
// //               if (authViewModel.errorMessage != null)
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   margin: const EdgeInsets.only(bottom: 20),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.shade50,
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: Colors.red.shade200),
// //                   ),
// //                   child: Text(
// //                     authViewModel.errorMessage!,
// //                     style: const TextStyle(color: Colors.red),
// //                   ),
// //                 ),
              
// //               // Nom
// //               TextFormField(
// //                 controller: _nomController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Nom complet *',
// //                   prefixIcon: Icon(Icons.person),
// //                   hintText: 'Ex: Jean Dupont',
// //                 ),
// //                 validator: Validators.validateName,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 16),
              
// //               // Email
// //               TextFormField(
// //                 controller: _emailController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Email *',
// //                   prefixIcon: Icon(Icons.email),
// //                   hintText: 'exemple@email.com',
// //                 ),
// //                 validator: Validators.validateEmail,
// //                 keyboardType: TextInputType.emailAddress,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 16),
              
// //               // Téléphone
// //               TextFormField(
// //                 controller: _telephoneController,
// //                 decoration: const InputDecoration(
// //                   labelText: 'Téléphone *',
// //                   prefixIcon: Icon(Icons.phone),
// //                   hintText: '0612345678',
// //                 ),
// //                 validator: Validators.validatePhone,
// //                 keyboardType: TextInputType.phone,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 16),
              
// //               // Mot de passe
// //               TextFormField(
// //                 controller: _passwordController,
// //                 decoration: InputDecoration(
// //                   labelText: 'Mot de passe *',
// //                   prefixIcon: const Icon(Icons.lock),
// //                   suffixIcon: IconButton(
// //                     icon: Icon(
// //                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
// //                     ),
// //                     onPressed: () {
// //                       setState(() => _obscurePassword = !_obscurePassword);
// //                     },
// //                   ),
// //                   hintText: 'Minimum 6 caractères',
// //                 ),
// //                 validator: Validators.validatePassword,
// //                 obscureText: _obscurePassword,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 16),
              
// //               // Confirmation mot de passe
// //               TextFormField(
// //                 controller: _confirmPasswordController,
// //                 decoration: InputDecoration(
// //                   labelText: 'Confirmer le mot de passe *',
// //                   prefixIcon: const Icon(Icons.lock_outline),
// //                   suffixIcon: IconButton(
// //                     icon: Icon(
// //                       _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
// //                     ),
// //                     onPressed: () {
// //                       setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
// //                     },
// //                   ),
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'Veuillez confirmer le mot de passe';
// //                   }
// //                   if (value != _passwordController.text) {
// //                     return 'Les mots de passe ne correspondent pas';
// //                   }
// //                   return null;
// //                 },
// //                 obscureText: _obscureConfirmPassword,
// //                 textInputAction: TextInputAction.done,
// //               ),
// //               const SizedBox(height: 30),
              
// //               // Bouton d'inscription
// //               SizedBox(
// //                 height: 50,
// //                 child: ElevatedButton(
// //                   onPressed: authViewModel.isLoading ? null : _handleRegister,
// //                   style: ElevatedButton.styleFrom(
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   child: authViewModel.isLoading
// //                       ? const SizedBox(
// //                           width: 20,
// //                           height: 20,
// //                           child: CircularProgressIndicator(strokeWidth: 2),
// //                         )
// //                       : const Text('Créer mon compte'),
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
              
// //               // Lien vers connexion
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Text('Déjà un compte ?'),
// //                   TextButton(
// //                     onPressed: () {
// //                       Navigator.pushReplacementNamed(context, '/login');
// //                     },
// //                     child: const Text('Se connecter'),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _handleRegister() async {
// //     print("🔄 [REGISTER] Début handleRegister");
    
// //     if (_formKey.currentState!.validate()) {
// //       print("✅ [REGISTER] Formulaire valide");
      
// //       final authViewModel = context.read<AuthViewModel>();
      
// //       try {
// //         print("📝 [REGISTER] Appel à register()");
// //         final success = await authViewModel.register(
// //           _emailController.text.trim(),
// //           _passwordController.text.trim(),
// //           _nomController.text.trim(),
// //           _telephoneController.text.trim(),
// //         );
        
// //         print("📊 [REGISTER] Résultat register: $success");
        
// //         if (success && context.mounted) {
// //           print("✅ [REGISTER] Inscription réussie, navigation...");
          
// //           // Vérifier le rôle pour la redirection
// //           final user = authViewModel.currentUser;
// //           print("👤 [REGISTER] Utilisateur après inscription: ${user?.role}");
          
// //           if (user?.role == 'owner') {
// //             Navigator.pushReplacementNamed(context, '/owner-home');
// //           } else if (user?.role == 'admin') {
// //             Navigator.pushReplacementNamed(context, '/admin');
// //           } else {
// //             Navigator.pushReplacementNamed(context, '/home');
// //           }
// //         } else if (!success && context.mounted) {
// //           print("❌ [REGISTER] Inscription échouée");
// //           // L'erreur est déjà affichée par le ViewModel
// //         }
        
// //       } catch (e, stackTrace) {
// //         print("❌ [REGISTER] EXCEPTION dans handleRegister: $e");
// //         print("📝 [REGISTER] Stack trace: $stackTrace");
        
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text('Erreur: $e'),
// //               backgroundColor: Colors.red,
// //             ),
// //           );
// //         }
// //       }
// //     } else {
// //       print("❌ [REGISTER] Formulaire invalide");
// //     }
    
// //     print("🏁 [REGISTER] Fin handleRegister");
// //   }
// // }



