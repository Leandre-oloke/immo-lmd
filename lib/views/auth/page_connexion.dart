import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/validators.dart';

/// ===============================
/// PAGE DE CONNEXION
/// ===============================
class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  // ===============================
  // FORMULAIRE & CONTROLLERS
  // ===============================
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
      // ===============================
      // APP BAR (SANS FLÈCHE DE RETOUR)
      // ===============================
      appBar: AppBar(
        title: const Text("Connexion"),
        backgroundColor: const Color.fromARGB(255, 247, 143, 212),
        automaticallyImplyLeading: false, // ❌ enlève la flèche retour
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
                        Icons.home,
                        size: 46,
                        color: Color.fromARGB(255, 248, 93, 253),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===============================
                    // TITRE
                    // ===============================
                    const Text(
                      "Bienvenue",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Connectez-vous pour accéder à votre espace",
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
                              // ===============================
                              // MESSAGE D'ERREUR
                              // ===============================
                              if (authViewModel.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),

                              // ===============================
                              // EMAIL
                              // ===============================
                              TextFormField(
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ===============================
                              // MOT DE PASSE
                              // ===============================
                              TextFormField(
                                controller: _passwordController,
                                validator: Validators.validatePassword,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Mot de passe oublié ?",
                                    style: TextStyle(color: Color(0xFF8A2BE2)),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ===============================
                              // BOUTON CONNEXION
                              // ===============================
                              SizedBox(
                                width: double.infinity,
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
                                              Navigator.pushReplacementNamed(
                                                  context, '/user-home');
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color.fromARGB(255, 247, 143, 212),
                                  ),
                                  child: authViewModel.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          "Se connecter",
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

                    // ===============================
                    // INSCRIPTION
                    // ===============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Pas de compte ?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}
