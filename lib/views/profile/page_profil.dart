import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_drawer.dart';
import '../components/app_end_drawer.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({super.key});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEditing(dynamic currentUser) {
    setState(() {
      _isEditing = true;
      _nomController.text = currentUser.nom;
      _telephoneController.text = currentUser.telephone;
      _emailController.text = currentUser.email;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nomController.clear();
      _telephoneController.clear();
      _emailController.clear();
    });
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'owner':
        return 'Propriétaire';
      case 'user':
        return 'Locataire';
      default:
        return 'Utilisateur';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'owner':
        return Colors.green;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'owner':
        return Icons.business;
      case 'user':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    // Si pas d'utilisateur connecté
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        drawer: const AppDrawer(),
        endDrawer: const AppEndDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                "Aucun utilisateur connecté",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                "Veuillez vous connecter pour voir votre profil",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _startEditing(currentUser),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEditing,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      endDrawer: const AppEndDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du profil
            _buildProfileHeader(currentUser),
            
            const SizedBox(height: 24),
            
            // Informations personnelles
            _buildPersonalInfoSection(currentUser),
            
            const SizedBox(height: 24),
            
            // Statistiques (selon le rôle)
            _buildStatsSection(currentUser),
            
            const SizedBox(height: 24),
            
            // Actions
            _buildActionsSection(context, authViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic currentUser) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getRoleColor(currentUser.role),
              child: Icon(
                _getRoleIcon(currentUser.role),
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser.nom,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      _getRoleDisplayName(currentUser.role),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getRoleColor(currentUser.role),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(dynamic currentUser) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations personnelles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isEditing) ...[
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom complet",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelEditing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implémenter la mise à jour du profil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mise à jour du profil à venir'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        _cancelEditing();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildInfoItem(
                icon: Icons.person,
                label: "Nom",
                value: currentUser.nom,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.email,
                label: "Email",
                value: currentUser.email,
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.phone,
                label: "Téléphone",
                value: currentUser.telephone.isNotEmpty 
                    ? currentUser.telephone 
                    : "Non renseigné",
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: "Membre depuis",
                value: currentUser.dateCreation != null
                    ? "${currentUser.dateCreation.day}/${currentUser.dateCreation.month}/${currentUser.dateCreation.year}"
                    : "Date inconnue",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(dynamic currentUser) {
    final List<Map<String, dynamic>> stats = [];
    
    // Statistiques selon le rôle
    if (currentUser.role == 'owner') {
      stats.addAll([
        {'label': 'Logements publiés', 'value': '0', 'icon': Icons.home},
        {'label': 'Logements disponibles', 'value': '0', 'icon': Icons.check_circle},
        {'label': 'Logements occupés', 'value': '0', 'icon': Icons.bed},
        {'label': 'Revenu estimé', 'value': '0€', 'icon': Icons.euro},
      ]);
    } else if (currentUser.role == 'user') {
      stats.addAll([
        {'label': 'Réservations', 'value': '0', 'icon': Icons.calendar_today},
        {'label': 'Favoris', 'value': '0', 'icon': Icons.favorite},
        {'label': 'Visites', 'value': '0', 'icon': Icons.visibility},
      ]);
    } else if (currentUser.role == 'admin') {
      stats.addAll([
        {'label': 'Utilisateurs', 'value': '0', 'icon': Icons.people},
        {'label': 'Logements', 'value': '0', 'icon': Icons.apartment},
        {'label': 'Propriétaires', 'value': '0', 'icon': Icons.business},
      ]);
    }

    if (stats.isEmpty) return const SizedBox();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentUser.role == 'owner' ? "Mes statistiques" : "Statistiques",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(stat['icon'], color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          stat['value'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['label'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, AuthViewModel authViewModel) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.orange),
              title: const Text('Changer le mot de passe'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.purple),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.security, color: Colors.green),
              title: const Text('Confidentialité'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await authViewModel.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}






// import 'package:flutter/material.dart';
// import '../components/app_drawer.dart';
// import '../components/app_end_drawer.dart';

// // Page de profil utilisateur
// // StatelessWidget car ne nécessite pas de gestion d'état

// class PageProfil extends StatelessWidget {
//   const PageProfil({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profil")),
//       drawer: const AppDrawer(),
//       endDrawer: const AppEndDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               "Nom: Léandre OLOKE",
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "Email: exemple@mail.com",
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 12),
//             Text(
//               "Rôle: Locataire",
//               style: TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
