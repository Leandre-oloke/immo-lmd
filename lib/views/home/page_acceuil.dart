import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/logement_card.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../components/app_drawer.dart';

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
        title: const Text('Bienvenue sur Location App'),
        actions: [
          if (authViewModel.currentUser != null) ...[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Connexion',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(logementViewModel, authViewModel),
      floatingActionButton: _buildFloatingActionButton(authViewModel),
    );
  }

  Widget _buildBody(LogementViewModel viewModel, AuthViewModel authViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section de bienvenue
        _buildWelcomeSection(authViewModel),
        
        // Section logements disponibles
        Expanded(
          child: _buildLogementsSection(viewModel, authViewModel),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(AuthViewModel authViewModel) {
    final user = authViewModel.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user != null 
                ? 'Bonjour, ${user.nom} ! 👋'
                : 'Bienvenue sur Location App ! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user != null
                ? 'Trouvez votre prochain logement idéal'
                : 'Connectez-vous pour profiter de toutes les fonctionnalités',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          if (user == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Se connecter'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Créer un compte'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLogementsSection(LogementViewModel viewModel, AuthViewModel authViewModel) {
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
            Icon(
              Icons.home_work,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun logement disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Revenez plus tard pour découvrir de nouveaux logements',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            if (authViewModel.isOwner)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/owner-home');
                },
                icon: const Icon(Icons.add_home),
                label: const Text('Ajouter un logement'),
              ),
          ],
        ),
      );
    }

    // Filtrer uniquement les logements disponibles
    final availableLogements = viewModel.logements
        .where((logement) => logement.disponible)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        viewModel.loadAllLogements();
      },
      child: Column(
        children: [
          // En-tête de section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logements disponibles (${availableLogements.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterDialog(viewModel);
                  },
                ),
              ],
            ),
          ),
          
          // Liste des logements
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableLogements.length,
              itemBuilder: (context, index) {
                final logement = availableLogements[index];
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
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(AuthViewModel authViewModel) {
    if (authViewModel.isOwner) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/owner-home');
        },
        icon: const Icon(Icons.add_home),
        label: const Text('Ajouter'),
        backgroundColor: Colors.green,
      );
    }
    return null;
  }

  void _showFilterDialog(LogementViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les résultats'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Exemple de filtres - à adapter selon vos besoins
                const Text('Filtres disponibles :'),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Disponibles uniquement'),
                  value: true, // À connecter à votre état de filtre
                  onChanged: (value) {
                    // TODO: Implémenter le filtre
                  },
                ),
                // Ajoutez d'autres filtres selon vos besoins
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Appliquer les filtres
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../components/logement_card.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../../viewmodels/auth_viewmodel.dart';

// class PageAcceuil extends StatefulWidget {
//   const PageAcceuil({super.key});

//   @override
//   State<PageAcceuil> createState() => _PageAcceuilState();
// }

// class _PageAcceuilState extends State<PageAcceuil> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LogementViewModel>().loadAllLogements();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final logementViewModel = context.watch<LogementViewModel>();
//     final authViewModel = context.watch<AuthViewModel>();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Logements disponibles'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // TODO: Implémenter la recherche
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               Navigator.pushNamed(context, '/profile');
//             },
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(authViewModel),
//       body: _buildBody(logementViewModel),
//     );
//   }

//   Widget _buildDrawer(AuthViewModel authViewModel) {
//     final currentUser = authViewModel.currentUser;
    
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           // En-tête du drawer
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.person,
//                     color: Colors.blue,
//                     size: 40,
//                   ),
//                   radius: 30,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   currentUser?.nom ?? 'Invité',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   currentUser?.email ?? '',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
          
//           // Menu items
//           ListTile(
//             leading: const Icon(Icons.home),
//             title: const Text('Accueil'),
//             onTap: () {
//               Navigator.pop(context);
//             },
//           ),
          
//           if (currentUser?.role == 'admin')
//             ListTile(
//               leading: const Icon(Icons.admin_panel_settings),
//               title: const Text('Administration'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/admin');
//               },
//             ),
          
//           if (currentUser?.role == 'owner')
//             ListTile(
//               leading: const Icon(Icons.business),
//               title: const Text('Espace Propriétaire'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/owner-home');
//               },
//             ),
          
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profil'),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, '/profile');
//             },
//           ),
          
//           ListTile(
//             leading: const Icon(Icons.favorite),
//             title: const Text('Favoris'),
//             onTap: () {
//               // TODO: Naviguer vers les favoris
//               Navigator.pop(context);
//             },
//           ),
          
//           ListTile(
//             leading: const Icon(Icons.history),
//             title: const Text('Historique'),
//             onTap: () {
//               // TODO: Naviguer vers l'historique
//               Navigator.pop(context);
//             },
//           ),
          
//           const Divider(),
          
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Paramètres'),
//             onTap: () {
//               Navigator.pop(context);
//               // TODO: Naviguer vers paramètres
//             },
//           ),
          
//           ListTile(
//             leading: const Icon(Icons.help),
//             title: const Text('Aide'),
//             onTap: () {
//               Navigator.pop(context);
//               // TODO: Naviguer vers aide
//             },
//           ),
          
//           const Divider(),
          
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Déconnexion'),
//             onTap: () async {
//               Navigator.pop(context);
//               await authViewModel.logout();
//               Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(LogementViewModel viewModel) {
//     if (viewModel.isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Chargement des logements...'),
//           ],
//         ),
//       );
//     }

//     if (viewModel.errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 60, color: Colors.red),
//             const SizedBox(height: 16),
//             const Text(
//               'Erreur de chargement',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 viewModel.errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 viewModel.loadAllLogements();
//               },
//               child: const Text('Réessayer'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (viewModel.logements.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.home, size: 80, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'Aucun logement disponible',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Revenez plus tard pour découvrir de nouveaux logements',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         viewModel.loadAllLogements();
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: viewModel.logements.length,
//         itemBuilder: (context, index) {
//           final logement = viewModel.logements[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: LogementCard(
//               logement: logement,
//               onTap: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/logement-details',
//                   arguments: logement,
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

