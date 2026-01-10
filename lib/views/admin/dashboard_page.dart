import 'package:app_mobile/views/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import 'user_management_page.dart';
import 'gestion_logement.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHomePage(),
    const UserManagementPage(),
    const AdminLogementsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Logements',
          ),
        ],
      ),
    );
  }
}

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminViewModel = context.watch<AdminViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques Générales',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Cartes de statistiques
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                'Utilisateurs',
                '${adminViewModel.totalUsers}',
                Icons.group,
                Colors.blue,
              ),
              _buildStatCard(
                'Logements',
                '${adminViewModel.totalLogements}',
                Icons.home,
                Colors.green,
              ),
              _buildStatCard(
                'Propriétaires',
                '${adminViewModel.totalOwners}',
                Icons.business,
                Colors.orange,
              ),
              _buildStatCard(
                'Logements Actifs',
                '${adminViewModel.activeLogements}',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            'Actions Rapides',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Actions rapides
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                'Gérer les utilisateurs',
                Icons.group,
                () {
                  // Navigation vers la gestion des utilisateurs
                 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  
                },
              ),
              _buildActionCard(
                'Voir les logements',
                Icons.home,
                () {
                  // Navigation vers la gestion des logements
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLogementsPage(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                'Voir les activités',
                Icons.history,
                () {
                  // Navigation vers les activités

                },
              ),
              _buildActionCard(
                'Paramètres',
                Icons.settings,
                () {
                  // Navigation vers les paramètres
                 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';

// class DashboardPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Dashboard Admin")),
//       body: Center(child: Text("Statistiques et gestion admin")),
//     );
//   }
// }
