// lib/views/auth/page_connexion.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../routes/routes.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({super.key});

  @override
  State<PageConnexion> createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();

    try {
      await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted && authViewModel.isLoggedIn) {
        final user = authViewModel.currentUser;
        if (user != null) {
          if (user.role == 'admin') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
          } else if (user.role == 'owner') {
            Navigator.pushReplacementNamed(context, AppRoutes.ownerHome);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.userHome);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Google à venir prochainement'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleFacebookLogin() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion Facebook à venir prochainement'),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo de l'application
                      _buildLogo(),

                      const SizedBox(height: 40),

                      // Carte de connexion
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: size.width > 600 ? 450 : double.infinity,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.white,
                        //   borderRadius: BorderRadius.circular(30),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: Colors.black.withOpacity(0.1),
                        //       blurRadius: 30,
                        //       offset: const Offset(0, 10),
                        //     ),
                        //   ],
                        // ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Titre
                              const Text(
                                'Bienvenue sur ExpatBenin !',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Connectez-vous pour continuer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Formulaire
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildEmailField(),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(),
                                    const SizedBox(height: 16),
                                    _buildRememberMeAndForgotPassword(),
                                    const SizedBox(height: 24),
                                    _buildLoginButton(authViewModel),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Séparateur
                              _buildDivider(),

                              const SizedBox(height: 24),

                              // Boutons sociaux
                              _buildSocialButtons(),

                              const SizedBox(height: 24),

                              // Lien inscription
                              _buildSignUpLink(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Lien mode invité
                      _buildGuestLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66E3EA), Color(0xFF764ba2)],
            ),
          ),
          child: Image.asset(
            'assets/image/logo_projet.png',
            fit: BoxFit.contain,

            width: 60,
            height: 60,
          ),
        ),
      ),
    );
  }

  // Widget _buildLogo() {
  //   return Container(
  //     width: 120,
  //     height: 120,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       shape: BoxShape.circle,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: ClipOval(
  //       child: Container(
  //         padding: const EdgeInsets.all(20),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [
  //               const Color.fromARGB(255, 102, 227, 234),
  //               const Color(0xFF764ba2),
  //             ],
  //           ),
  //         ),
  //         child: const Icon(
  //           Icons.home_work,
  //           size: 60,
  //           color: Colors.white,
  //           // NetworkImage (..'/utils/image/logo_projet.png'),
  //           // size: 60,
  //           // color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'exemple@email.com',
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF667eea)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF667eea)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: const Color(0xFF667eea),
            ),
            const Text('Se souvenir de moi', style: TextStyle(fontSize: 14)),
          ],
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réinitialisation du mot de passe à venir'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthViewModel authViewModel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authViewModel.isLoading ? null : _handleEmailLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: authViewModel.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Se connecter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Bouton Google
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _handleGoogleLogin,
            icon: Image.network(
              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 28);
              },
            ),
            label: const Text(
              'Continuer avec Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Bouton Facebook
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _handleFacebookLogin,
            icon: const Icon(
              Icons.facebook,
              color: Color(0xFF1877F2),
              size: 28,
            ),
            label: const Text(
              'Continuer avec Facebook',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Vous n'avez pas de compte ?",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          child: const Text(
            "S'inscrire",
            style: TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestLink() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      icon: const Icon(Icons.arrow_forward, color: Colors.white),
      label: const Text(
        'Continuer en tant qu\'invité',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
 





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../utils/validators.dart';
// import '../admin/dashboard_page.dart';

// class PageConnexion extends StatefulWidget {
//   const PageConnexion({super.key});

//   @override
//   State<PageConnexion> createState() => _PageConnexionState();
// }

// class _PageConnexionState extends State<PageConnexion> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
  
//   bool _isPasswordVisible = false;

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
//       backgroundColor: Colors.grey.shade100,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Card(
//             elevation: 6,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Icône maison
//                     const Icon(Icons.home, size: 60, color: Colors.green),
//                     const SizedBox(height: 12),
//                     const Text(
//                       "Bienvenue",
//                       style:
//                           TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 24),

//                     // ERREURS
//                     if (authViewModel.errorMessage != null)
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         margin: const EdgeInsets.only(bottom: 16),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.error, color: Colors.red),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 authViewModel.errorMessage!,
//                                 style: const TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     // Email
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: _inputDecoration(
//                         label: 'Email',
//                         icon: Icons.email,
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: Validators.validateEmail,
//                     ),
//                     const SizedBox(height: 16),

//                     // Mot de passe
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: !_isPasswordVisible,
//                       decoration: _inputDecoration(
//                         label: 'Mot de passe',
//                         icon: Icons.lock,
//                         suffix: IconButton(
//                           icon: Icon(_isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off),
//                           onPressed: () {
//                             setState(() {
//                               _isPasswordVisible = !_isPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: Validators.validatePassword,
//                     ),
//                     const SizedBox(height: 24),

//                     // Bouton connexion
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: authViewModel.isLoading
//                             ? null
//                             : () async {
//                                 if (_formKey.currentState!.validate()) {
//                                   final success = await authViewModel.login(
//                                     _emailController.text.trim(),
//                                     _passwordController.text.trim(),
//                                   );

//                                   if (success && context.mounted) {
//                                     final user = authViewModel.currentUser;
//                                     if (user?.role == 'admin') {
//                                       Navigator.pushReplacementNamed(
//                                          // context, '/admin');
//                                           context, '/admin-home');
//                                     } else if (user?.role == 'owner') {
//                                       Navigator.pushReplacementNamed(
//                                           context, '/owner-home');
//                                     } else {
//                                       Navigator.pushReplacementNamed(
//                                           context, '/home');
//                                     }
//                                   }
//                                 }
//                               },
//                         child: authViewModel.isLoading
//                             ? const CircularProgressIndicator()
//                             : const Text(
//                                 'Se connecter',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Lien vers inscription
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Pas encore de compte ? "),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushReplacementNamed(
//                                 context, '/register');
//                           },
//                           child: const Text("Créer un compte"),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//     Widget? suffix,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),
//       suffixIcon: suffix,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );
//   }
// }





