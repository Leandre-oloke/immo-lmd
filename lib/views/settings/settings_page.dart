import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/utilisateur_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'Français';
  String _selectedCurrency = 'EUR (€)';

  final List<String> _languages = ['Français', 'English', 'Español', 'Deutsch'];
  final List<String> _currencies = ['EUR (€)', 'USD (\$)', 'GBP (£)', 'CFA (F)'];

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // En-tête profil
          _buildProfileHeader(currentUser),
          
          // Section Compte
          _buildSettingsSection(
            title: 'COMPTE',
            children: [
              _buildSettingItem(
                icon: Icons.person,
                title: 'Profil',
                subtitle: 'Gérer vos informations personnelles',
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _buildSettingItem(
                icon: Icons.lock,
                title: 'Sécurité',
                subtitle: 'Mot de passe, authentification',
                onTap: () {
                  _showSecurityDialog();
                },
              ),
              _buildSettingItem(
                icon: Icons.notifications_active,
                title: 'Notifications',
                subtitle: 'Contrôler vos notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              if (currentUser?.role == 'owner') ...[
                _buildSettingItem(
                  icon: Icons.business,
                  title: 'Préférences propriétaire',
                  subtitle: 'Paramètres spécifiques aux propriétaires',
                  onTap: () {
                    _showOwnerPreferences();
                  },
                ),
              ],
            ],
          ),
          
          // Section Application
          _buildSettingsSection(
            title: 'APPLICATION',
            children: [
              _buildSettingItem(
                icon: Icons.language,
                title: 'Langue',
                subtitle: _selectedLanguage,
                onTap: () {
                  _showLanguageSelector();
                },
              ),
              _buildSettingItem(
                icon: Icons.monetization_on,
                title: 'Devise',
                subtitle: _selectedCurrency,
                onTap: () {
                  _showCurrencySelector();
                },
              ),
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                subtitle: 'Activer/désactiver le thème sombre',
                trailing: Switch(
                  value: _darkMode,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Confidentialité',
                subtitle: 'Politique de confidentialité',
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
              ),
              _buildSettingItem(
                icon: Icons.description,
                title: 'Conditions d\'utilisation',
                subtitle: 'Lire les conditions générales',
                onTap: () {
                  Navigator.pushNamed(context, '/terms');
                },
              ),
            ],
          ),
          
          // Section Support
          _buildSettingsSection(
            title: 'SUPPORT',
            children: [
              _buildSettingItem(
                icon: Icons.help_outline,
                title: 'Aide & Support',
                subtitle: 'Centre d\'aide et FAQ',
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              _buildSettingItem(
                icon: Icons.contact_support,
                title: 'Nous contacter',
                subtitle: 'Support technique et commercial',
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
              ),
              _buildSettingItem(
                icon: Icons.bug_report,
                title: 'Signaler un problème',
                subtitle: 'Bug, suggestion ou problème',
                onTap: () {
                  _showReportDialog();
                },
              ),
              _buildSettingItem(
                icon: Icons.star_rate,
                title: 'Noter l\'application',
                subtitle: 'Donnez-nous votre avis',
                onTap: () {
                  _rateApp();
                },
              ),
            ],
          ),
          
          // Section À propos
          _buildSettingsSection(
            title: 'À PROPOS',
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: 'À propos de l\'application',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              _buildSettingItem(
                icon: Icons.update,
                title: 'Vérifier les mises à jour',
                subtitle: 'Dernière vérification: Aujourd\'hui',
                onTap: () {
                  _checkForUpdates();
                },
              ),
            ],
          ),
          
          // Bouton Déconnexion
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await authViewModel.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'Déconnexion',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Informations version
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'ImmoLMD v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2024 ImmoLMD. Tous droits réservés.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Utilisateur? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.green.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green,
            child: Text(
              user?.nom.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nom ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'email@exemple.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    user?.role == 'owner' ? 'Propriétaire' : 
                    user?.role == 'user' ? 'Locataire' : 'Administrateur',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(_languages[index]),
                value: _languages[index],
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la devise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(_currencies[index]),
                value: _currencies[index],
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sécurité'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Options de sécurité disponibles:'),
            SizedBox(height: 16),
            Text('• Changer le mot de passe'),
            Text('• Authentification à deux facteurs'),
            Text('• Historique de connexion'),
            Text('• Appareils connectés'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/change-password');
            },
            child: const Text('Changer mot de passe'),
          ),
        ],
      ),
    );
  }

  void _showOwnerPreferences() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Préférences Propriétaire'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paramètres spécifiques:'),
            SizedBox(height: 16),
            Text('• Notifications de réservation'),
            Text('• Alertes de paiement'),
            Text('• Rapports mensuels'),
            Text('• Paramètres de commission'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Décrivez le problème ou votre suggestion:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre problème ici...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Envoyer le rapport
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rapport envoyé avec succès!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=com.example.immolmd';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vous avez la dernière version de l\'application!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}