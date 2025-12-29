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
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Afficher les erreurs
              if (authViewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // Nom
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Ex: Jean Dupont',
                ),
                validator: Validators.validateName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'exemple@email.com',
                ),
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Téléphone
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone *',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '0612345678',
                ),
                validator: Validators.validatePhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  hintText: 'Minimum 6 caractères',
                ),
                validator: Validators.validatePassword,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Confirmation mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le mot de passe';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),
              
              // Bouton d'inscription
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authViewModel.isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authViewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer mon compte'),
                ),
              ),
              const SizedBox(height: 20),
              
              // Lien vers connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Déjà un compte ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    print("🔄 [REGISTER] Début handleRegister");
    
    if (_formKey.currentState!.validate()) {
      print("✅ [REGISTER] Formulaire valide");
      
      final authViewModel = context.read<AuthViewModel>();
      
      try {
        print("📝 [REGISTER] Appel à register()");
        final success = await authViewModel.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nomController.text.trim(),
          _telephoneController.text.trim(),
        );
        
        print("📊 [REGISTER] Résultat register: $success");
        
        if (success && context.mounted) {
          print("✅ [REGISTER] Inscription réussie, navigation...");
          
          // Vérifier le rôle pour la redirection
          final user = authViewModel.currentUser;
          print("👤 [REGISTER] Utilisateur après inscription: ${user?.role}");
          
          if (user?.role == 'owner') {
            Navigator.pushReplacementNamed(context, '/owner-home');
          } else if (user?.role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (!success && context.mounted) {
          print("❌ [REGISTER] Inscription échouée");
          // L'erreur est déjà affichée par le ViewModel
        }
        
      } catch (e, stackTrace) {
        print("❌ [REGISTER] EXCEPTION dans handleRegister: $e");
        print("📝 [REGISTER] Stack trace: $stackTrace");
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print("❌ [REGISTER] Formulaire invalide");
    }
    
    print("🏁 [REGISTER] Fin handleRegister");
  }
}




// import 'package:flutter/material.dart';
// import '../components/custom_button.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState(); //permet de créer l'état associé à ce widget
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController emailController = TextEditingController(); // Email
//   final TextEditingController passwordController = TextEditingController(); // Mot de passe
//   final TextEditingController nameController = TextEditingController(); // Nom
//   final TextEditingController confirmPasswordController = TextEditingController(); // Confirmation
//   final TextEditingController lastNameController = TextEditingController(); // Prénom

// // Libère les ressources utilisées par les contrôleurs de texte lorsque le widget est supprimé de l'arbre des widgets
// // dispose est une méthode du cycle de vie d'un StatefulWidget
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     nameController.dispose();
//     confirmPasswordController.dispose();
//     lastNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Inscription")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Nom'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: lastNameController,
//               decoration: const InputDecoration(labelText: 'Prénom'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Mot de passe'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: confirmPasswordController,
//               decoration:
//                   const InputDecoration(labelText: 'Confirmer le mot de passe'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),

//             CustomButton(
//               text: "S'inscrire",
//               onPressed: () {
//                 // TODO: AuthViewModel register
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
