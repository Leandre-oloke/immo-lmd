import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/logement_card.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PageAcceuil extends StatefulWidget {
  const PageAcceuil({super.key});

  @override
  State<PageAcceuil> createState() => _PageAcceuilState();
}

class _PageAcceuilState extends State<PageAcceuil> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogementViewModel>().loadAllLogements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logementViewModel = context.watch<LogementViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logements disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(authViewModel),
      body: _buildBody(logementViewModel),
    );
  }

  Widget _buildDrawer(AuthViewModel authViewModel) {
    final currentUser = authViewModel.currentUser;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête du drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 40,
                  ),
                  radius: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser?.nom ?? 'Invité',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Menu items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          if (currentUser?.role == 'admin')
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Administration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin');
              },
            ),
          
          if (currentUser?.role == 'owner')
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Espace Propriétaire'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/owner-home');
              },
            ),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favoris'),
            onTap: () {
              // TODO: Naviguer vers les favoris
              Navigator.pop(context);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historique'),
            onTap: () {
              // TODO: Naviguer vers l'historique
              Navigator.pop(context);
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers paramètres
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers aide
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              Navigator.pop(context);
              await authViewModel.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LogementViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des logements...'),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.loadAllLogements();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (viewModel.logements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun logement disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revenez plus tard pour découvrir de nouveaux logements',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        viewModel.loadAllLogements();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.logements.length,
        itemBuilder: (context, index) {
          final logement = viewModel.logements[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LogementCard(
              logement: logement,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/logement-details',
                  arguments: logement,
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// // import 'package:flutter/material.dart';
// // import '../components/app_drawer.dart';
// // import '../components/app_end_drawer.dart';

// // class PageAcceuil extends StatelessWidget {
// //   const PageAcceuil({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Accueil'),
// //         actions: [
// //           Builder(
// //             builder: (context) => IconButton(
// //               icon: const Icon(Icons.settings),
// //               onPressed: () {
// //                 Scaffold.of(context).openEndDrawer();
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //       drawer: const AppDrawer(),
// //       endDrawer: const AppEndDrawer(),

// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // =========================
// //             // Carte de bienvenue
// //             // =========================
// //             Card(
// //               elevation: 4,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: const Padding(
// //                 padding: EdgeInsets.all(20),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'Bienvenue 👋',
// //                       style: TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     SizedBox(height: 8),
// //                     Text(
// //                       'Trouvez facilement des logements et gérez vos annonces '
// //                       'en toute simplicité.',
// //                       style: TextStyle(fontSize: 16),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(height: 20),

// //             // =========================
// //             // Section actions rapides
// //             // =========================
// //             Text(
// //               'Actions rapides',
// //               style: theme.textTheme.titleLarge,
// //             ),

// //             const SizedBox(height: 12),

// //             GridView.count(
// //               crossAxisCount: 2,
// //               shrinkWrap: true,
// //               physics: const NeverScrollableScrollPhysics(),
// //               crossAxisSpacing: 12,
// //               mainAxisSpacing: 12,
// //               children: [
// //                 _ActionCard(
// //                   icon: Icons.search,
// //                   label: 'Rechercher\nlogement',
// //                   onTap: () {},
// //                 ),
// //                 _ActionCard(
// //                   icon: Icons.add_home,
// //                   label: 'Publier\nannonce',
// //                   onTap: () {},
// //                 ),
// //                 _ActionCard(
// //                   icon: Icons.person,
// //                   label: 'Mon profil',
// //                   onTap: () {},
// //                 ),
// //                 _ActionCard(
// //                   icon: Icons.dashboard,
// //                   label: 'Dashboard',
// //                   onTap: () {},
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 24),

// //             // =========================
// //             // Astuce
// //             // =========================
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: theme.colorScheme.primary.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(
// //                   color: theme.colorScheme.primary.withOpacity(0.4),
// //                   width: 1.5,
// //                 ),
// //               ),
// //               child: const Row(
// //                 children: [
// //                   Icon(Icons.info_outline),
// //                   SizedBox(width: 12),
// //                   Expanded(
// //                     child: Text(
// //                       'Astuce : complétez votre profil pour augmenter '
// //                       'vos chances de réservation.',
// //                       style: TextStyle(fontSize: 15),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // =========================
// // // Carte d’action réutilisable
// // // =========================
// // class _ActionCard extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final VoidCallback onTap;

// //   const _ActionCard({
// //     required this.icon,
// //     required this.label,
// //     required this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return InkWell(
// //       onTap: onTap,
// //       borderRadius: BorderRadius.circular(16),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: Colors.grey.shade300),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 6,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, size: 36, color: theme.colorScheme.primary),
// //             const SizedBox(height: 10),
// //             Text(
// //               label,
// //               textAlign: TextAlign.center,
// //               style: const TextStyle(
// //                 fontSize: 15,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
