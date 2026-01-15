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







