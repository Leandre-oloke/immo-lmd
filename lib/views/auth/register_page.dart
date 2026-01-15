import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';

/// ===============================
/// PAGE D'INSCRIPTION
/// ===============================
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
      // ===============================
      // APP BAR
      // ===============================
      appBar: AppBar(
        title: const Text("Créer un compte"),
        backgroundColor: const Color.fromARGB(255, 247, 143, 212),
        automaticallyImplyLeading: false,
      ),

      // ===============================
      // CONTENU PRINCIPAL
      // ===============================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 143, 8, 136),
              Color.fromARGB(255, 57, 6, 99),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ===============================
                    // LOGO
                    // ===============================
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.95),
                      child: const Icon(
                        Icons.person_add,
                        size: 46,
                        color: Color.fromARGB(255, 248, 93, 253),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===============================
                    // TITRE
                    // ===============================
                    const Text(
                      "Inscription",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Créez votre compte pour accéder à l'application",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // ===============================
                    // CARTE FORMULAIRE
                    // ===============================
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Message d'erreur
                              if (authViewModel.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),

                              // Nom
                              _buildTextField(
                                controller: _nomController,
                                label: 'Nom complet',
                                icon: Icons.person,
                                validator: Validators.validateName,
                              ),
                              const SizedBox(height: 12),

                              // Email
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email,
                                validator: Validators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),

                              // Téléphone
                              _buildTextField(
                                controller: _telephoneController,
                                label: 'Téléphone',
                                icon: Icons.phone,
                                validator: Validators.validatePhone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              // Rôle
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

                              // Description rôle
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
                                        style: TextStyle(
                                          color: _selectedRole == 'user'
                                              ? Colors.blue.shade800
                                              : Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Mot de passe
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Mot de passe',
                                icon: Icons.lock,
                                validator: Validators.validatePassword,
                                obscureText: !_isPasswordVisible,
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
                              const SizedBox(height: 12),

                              // Confirmation mot de passe
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirmer mot de passe',
                                icon: Icons.lock_outline,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                                obscureText: !_isConfirmPasswordVisible,
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
                              const SizedBox(height: 24),

                              // Bouton
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authViewModel.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            final success = await authViewModel.register(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                              _nomController.text.trim(),
                                              _telephoneController.text.trim(),
                                              _selectedRole,
                                            );
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Compte créé avec succès. Veuillez vous connecter."),
                                                backgroundColor: Colors.green,
                                              ));
                                              Navigator.pushReplacementNamed(
                                                  context, '/login');
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        const Color.fromARGB(255, 247, 143, 212),
                                  ),
                                  child: authViewModel.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Créer mon compte",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lien vers connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Déjà un compte ?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
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

  // ===============================
  // FONCTION UTILE POUR LES CHAMPS
  // ===============================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
