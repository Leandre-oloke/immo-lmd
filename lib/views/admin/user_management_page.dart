import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/utilisateur_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final adminViewModel = context.read<AdminViewModel>();
    adminViewModel.loadAllUsers();
    adminViewModel.loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = context.watch<AdminViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          _buildStatsCard(adminViewModel),
          
          // Barre de recherche et filtres
          _buildSearchAndFilter(adminViewModel),
          
          // Liste des utilisateurs
          _buildUsersList(adminViewModel, authViewModel),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AdminViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Statistiques Utilisateurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildStatItem('Total', '${viewModel.totalUsers}', Icons.group)),
                Expanded(child: _buildStatItem('Propriétaires', '${viewModel.totalOwners}', Icons.business)),
                Expanded(child: _buildStatItem('Locataires', '${viewModel.totalUsers}', Icons.person)),
                Expanded(child: _buildStatItem('Admins', '${viewModel.totalAdmins}', Icons.admin_panel_settings)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(AdminViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous', viewModel),
                _buildFilterChip('Propriétaires', viewModel),
                _buildFilterChip('Locataires', viewModel),
                _buildFilterChip('Admins', viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AdminViewModel viewModel) {
    bool selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (value) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: selected ? Colors.blue.shade100 : Colors.grey.shade200,
        selectedColor: Colors.blue.shade200,
      ),
    );
  }

  Widget _buildUsersList(AdminViewModel adminViewModel, AuthViewModel authViewModel) {
    if (adminViewModel.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (adminViewModel.allUsers.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('Aucun utilisateur trouvé'),
        ),
      );
    }

    List<Utilisateur> filteredUsers = _filterUsers(
      adminViewModel.allUsers,
      _searchController.text,
      _selectedFilter,
    );

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final currentUser = authViewModel.currentUser;
            
            // L'admin peut modifier tous les utilisateurs sauf lui-même
            final canModify = currentUser?.role == 'admin' && currentUser?.id != user.id;
            // Ne peut pas modifier d'autres admins (sauf super-admin)
            final canModifyRole = canModify && user.role != 'admin';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor(user.role),
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  user.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            _getRoleLabel(user.role),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
                        ),
                        const Spacer(),
                        Text(
                          'Inscrit le ${_formatDate(user.dateCreation)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: canModify
                    ? PopupMenuButton<String>(
                        onSelected: (value) => _handleUserAction(value, user, adminViewModel, authViewModel),
                        itemBuilder: (context) => [
                          if (canModifyRole)
                            const PopupMenuItem(
                              value: 'change_role',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 20),
                                  SizedBox(width: 8),
                                  Text('Changer rôle'),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'view_details',
                            child: Row(
                              children: [
                                Icon(Icons.info, size: 20),
                                SizedBox(width: 8),
                                Text('Détails'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Utilisateur> _filterUsers(List<Utilisateur> users, String query, String filter) {
    List<Utilisateur> filtered = users;

    // Filtre par recherche
    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.nom.toLowerCase().contains(query.toLowerCase()) ||
               user.email.toLowerCase().contains(query.toLowerCase()) ||
               user.telephone?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();
    }

    // Filtre par rôle
    if (filter != 'Tous') {
      switch (filter) {
        case 'Propriétaires':
          filtered = filtered.where((user) => user.role == 'owner').toList();
          break;
        case 'Locataires':
          filtered = filtered.where((user) => user.role == 'user').toList();
          break;
        case 'Admins':
          filtered = filtered.where((user) => user.role == 'admin').toList();
          break;
      }
    }

    return filtered;
  }

  void _handleUserAction(String action, Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(user, viewModel, authViewModel);
        break;
      case 'view_details':
        _showUserDetails(user);
        break;
      case 'delete':
        _showDeleteDialog(user, viewModel, authViewModel);
        break;
    }
  }

  void _showChangeRoleDialog(Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
    String selectedRole = user.role;
    final currentUser = authViewModel.currentUser;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Changer le rôle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Utilisateur: ${user.nom}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Locataire')),
                      DropdownMenuItem(value: 'owner', child: Text('Propriétaire')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                    ],
                    onChanged: currentUser?.id == user.id 
                        ? null // Empêche de changer son propre rôle
                        : (value) {
                            setDialogState(() {
                              selectedRole = value!;
                            });
                          },
                    decoration: const InputDecoration(
                      labelText: 'Nouveau rôle',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (currentUser?.id == user.id)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Vous ne pouvez pas changer votre propre rôle',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (selectedRole != user.role && currentUser?.id != user.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_getRoleLabel(user.role)} → ${_getRoleLabel(selectedRole)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                if (currentUser?.id != user.id && selectedRole != user.role)
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _confirmRoleChange(user, selectedRole, viewModel);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Confirmer'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmRoleChange(Utilisateur user, String newRole, AdminViewModel viewModel) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Changement de rôle en cours...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      print('🔄 Tentative de changement de rôle...');
      print('📋 User ID: ${user.id}');
      print('📋 Ancien rôle: ${user.role}');
      print('📋 Nouveau rôle: $newRole');
      
      final success = await viewModel.updateUserRole(user.id, newRole);
      
      print('✅ Résultat: $success');
      
      // Fermer l'indicateur de chargement
      if (mounted) Navigator.pop(context);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rôle de ${user.nom} changé de ${_getRoleLabel(user.role)} à ${_getRoleLabel(newRole)}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Recharger les données
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Erreur lors du changement de rôle'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ ERREUR: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // Fermer l'indicateur de chargement en cas d'erreur
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Erreur lors du changement de rôle'),
                      Text(
                        'Détails: ${e.toString()}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'DÉTAILS',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Détails de l\'erreur'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _showUserDetails(Utilisateur user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de l\'utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Nom', user.nom),
              _buildDetailItem('Email', user.email),
              if (user.telephone != null)
                _buildDetailItem('Téléphone', user.telephone!),
              _buildDetailItem('Rôle', _getRoleLabel(user.role)),
              _buildDetailItem('Date d\'inscription', _formatDate(user.dateCreation)),
            ],
          ),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteDialog(Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
    final currentUser = authViewModel.currentUser;
    
    if (currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas supprimer votre propre compte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.nom}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmDelete(user, viewModel);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }


// important: supprimer un utilisateur est une action irréversible
  Future<void> _confirmDelete(Utilisateur user, AdminViewModel viewModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dernière confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cette action est irréversible.'),
            const SizedBox(height: 8),
            Text(
              'Supprimer ${user.nom} (${user.email}) ?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await viewModel.deleteUser(user.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recharger les données
        _loadData();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'owner':
        return Colors.blue;
      case 'user':
        return Colors.green;
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
        return Icons.person;
    }
  }

  String _getRoleLabel(String role) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/admin_viewmodel.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../models/utilisateur_model.dart';

// class UserManagementPage extends StatefulWidget {
//   const UserManagementPage({super.key});

//   @override
//   State<UserManagementPage> createState() => _UserManagementPageState();
// }

// class _UserManagementPageState extends State<UserManagementPage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedFilter = 'Tous';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   void _loadData() {
//     final adminViewModel = context.read<AdminViewModel>();
//     adminViewModel.loadAllUsers();
//     adminViewModel.loadStatistics();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final adminViewModel = context.watch<AdminViewModel>();
//     final authViewModel = context.watch<AuthViewModel>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gestion des Utilisateurs'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Statistiques
//           _buildStatsCard(adminViewModel),
          
//           // Barre de recherche et filtres
//           _buildSearchAndFilter(adminViewModel),
          
//           // Liste des utilisateurs
//           _buildUsersList(adminViewModel, authViewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCard(AdminViewModel viewModel) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'Statistiques Utilisateurs',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Expanded(child: _buildStatItem('Total', '${viewModel.totalUsers}', Icons.group)),
//                 Expanded(child: _buildStatItem('Propriétaires', '${viewModel.totalOwners}', Icons.business)),
//                 Expanded(child: _buildStatItem('Locataires', '${viewModel.totalUsers}', Icons.person)),
//                 Expanded(child: _buildStatItem('Admins', '${viewModel.totalAdmins}', Icons.admin_panel_settings)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.blue),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchAndFilter(AdminViewModel viewModel) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         children: [
//           // Barre de recherche
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Rechercher un utilisateur...',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _searchController.clear();
//                         setState(() {});
//                       },
//                     )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onChanged: (value) => setState(() {}),
//           ),
//           const SizedBox(height: 8),
          
//           // Filtres
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildFilterChip('Tous', viewModel),
//                 _buildFilterChip('Propriétaires', viewModel),
//                 _buildFilterChip('Locataires', viewModel),
//                 _buildFilterChip('Admins', viewModel),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, AdminViewModel viewModel) {
//     bool selected = _selectedFilter == label;
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: FilterChip(
//         label: Text(label),
//         selected: selected,
//         onSelected: (value) {
//           setState(() {
//             _selectedFilter = label;
//           });
//         },
//         backgroundColor: selected ? Colors.blue.shade100 : Colors.grey.shade200,
//         selectedColor: Colors.blue.shade200,
//       ),
//     );
//   }

//   Widget _buildUsersList(AdminViewModel adminViewModel, AuthViewModel authViewModel) {
//     if (adminViewModel.isLoading) {
//       return const Expanded(
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (adminViewModel.allUsers.isEmpty) {
//       return const Expanded(
//         child: Center(
//           child: Text('Aucun utilisateur trouvé'),
//         ),
//       );
//     }

//     List<Utilisateur> filteredUsers = _filterUsers(
//       adminViewModel.allUsers,
//       _searchController.text,
//       _selectedFilter,
//     );

//     return Expanded(
//       child: RefreshIndicator(
//         onRefresh: () async {
//           _loadData();
//         },
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: filteredUsers.length,
//           itemBuilder: (context, index) {
//             final user = filteredUsers[index];
//             final currentUser = authViewModel.currentUser;
            
//             // L'admin peut modifier tous les utilisateurs sauf lui-même
//             final canModify = currentUser?.role == 'admin' && currentUser?.id != user.id;
//             // Ne peut pas modifier d'autres admins (sauf super-admin)
//             final canModifyRole = canModify && user.role != 'admin';

//             return Card(
//               margin: const EdgeInsets.only(bottom: 12),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: _getRoleColor(user.role),
//                   child: Icon(
//                     _getRoleIcon(user.role),
//                     color: Colors.white,
//                   ),
//                 ),
//                 title: Text(
//                   user.nom,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(user.email),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Chip(
//                           label: Text(
//                             _getRoleLabel(user.role),
//                             style: TextStyle(
//                               color: _getRoleColor(user.role),
//                               fontSize: 12,
//                             ),
//                           ),
//                           backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
//                         ),
//                         const Spacer(),
//                         Text(
//                           'Inscrit le ${_formatDate(user.dateCreation)}',
//                           style: const TextStyle(fontSize: 11, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 trailing: canModify
//                     ? PopupMenuButton<String>(
//                         onSelected: (value) => _handleUserAction(value, user, adminViewModel, authViewModel),
//                         itemBuilder: (context) => [
//                           if (canModifyRole)
//                             const PopupMenuItem(
//                               value: 'change_role',
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.swap_horiz, size: 20),
//                                   SizedBox(width: 8),
//                                   Text('Changer rôle'),
//                                 ],
//                               ),
//                             ),
//                           const PopupMenuItem(
//                             value: 'view_details',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.info, size: 20),
//                                 SizedBox(width: 8),
//                                 Text('Détails'),
//                               ],
//                             ),
//                           ),
//                           const PopupMenuItem(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.delete, size: 20, color: Colors.red),
//                                 SizedBox(width: 8),
//                                 Text('Supprimer'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       )
//                     : null,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   List<Utilisateur> _filterUsers(List<Utilisateur> users, String query, String filter) {
//     List<Utilisateur> filtered = users;

//     // Filtre par recherche
//     if (query.isNotEmpty) {
//       filtered = filtered.where((user) {
//         return user.nom.toLowerCase().contains(query.toLowerCase()) ||
//                user.email.toLowerCase().contains(query.toLowerCase()) ||
//                user.telephone?.toLowerCase().contains(query.toLowerCase()) == true;
//       }).toList();
//     }

//     // Filtre par rôle
//     if (filter != 'Tous') {
//       switch (filter) {
//         case 'Propriétaires':
//           filtered = filtered.where((user) => user.role == 'owner').toList();
//           break;
//         case 'Locataires':
//           filtered = filtered.where((user) => user.role == 'user').toList();
//           break;
//         case 'Admins':
//           filtered = filtered.where((user) => user.role == 'admin').toList();
//           break;
//       }
//     }

//     return filtered;
//   }

//   void _handleUserAction(String action, Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
//     switch (action) {
//       case 'change_role':
//         _showChangeRoleDialog(user, viewModel, authViewModel);
//         break;
//       case 'view_details':
//         _showUserDetails(user);
//         break;
//       case 'delete':
//         _showDeleteDialog(user, viewModel, authViewModel);
//         break;
//     }
//   }

//   void _showChangeRoleDialog(Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
//     String selectedRole = user.role;
//     final currentUser = authViewModel.currentUser;
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Changer le rôle'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Utilisateur: ${user.nom}'),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: selectedRole,
//                 items: const [
//                   DropdownMenuItem(value: 'user', child: Text('Locataire')),
//                   DropdownMenuItem(value: 'owner', child: Text('Propriétaire')),
//                   DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
//                 ],
//                 onChanged: currentUser?.id == user.id 
//                     ? null // Empêche de changer son propre rôle
//                     : (value) {
//                         selectedRole = value!;
//                       },
//                 decoration: const InputDecoration(
//                   labelText: 'Nouveau rôle',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               if (currentUser?.id == user.id)
//                 const Padding(
//                   padding: EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     'Vous ne pouvez pas changer votre propre rôle',
//                     style: TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Annuler'),
//             ),
//             if (currentUser?.id != user.id)
//               ElevatedButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   await _confirmRoleChange(user, selectedRole, viewModel);
//                 },
//                 child: const Text('Confirmer'),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _confirmRoleChange(Utilisateur user, String newRole, AdminViewModel viewModel) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmer le changement'),
//         content: Text(
//           'Changer le rôle de ${user.nom} de "${_getRoleLabel(user.role)}" à "${_getRoleLabel(newRole)}" ?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Confirmer'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final success = await viewModel.updateUserRole(user.id, newRole);
//       if (success && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Rôle de ${user.nom} changé en ${_getRoleLabel(newRole)}'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//           ),
//         );
        
//         // Recharger les données
//         _loadData();
//       } else if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Erreur lors du changement de rôle'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showUserDetails(Utilisateur user) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Détails de l\'utilisateur'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildDetailItem('Nom', user.nom),
//               _buildDetailItem('Email', user.email),
//               if (user.telephone != null)
//                 _buildDetailItem('Téléphone', user.telephone!),
//               _buildDetailItem('Rôle', _getRoleLabel(user.role)),
//               _buildDetailItem('Date d\'inscription', _formatDate(user.dateCreation)),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fermer'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//           Text(value),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   void _showDeleteDialog(Utilisateur user, AdminViewModel viewModel, AuthViewModel authViewModel) {
//     final currentUser = authViewModel.currentUser;
    
//     if (currentUser?.id == user.id) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vous ne pouvez pas supprimer votre propre compte'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Confirmer la suppression'),
//           content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.nom}" ?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Annuler'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _confirmDelete(user, viewModel);
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Supprimer'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _confirmDelete(Utilisateur user, AdminViewModel viewModel) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Dernière confirmation'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Cette action est irréversible.'),
//             const SizedBox(height: 8),
//             Text(
//               'Supprimer ${user.nom} (${user.email}) ?',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Supprimer définitivement'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final success = await viewModel.deleteUser(user.id);
//       if (success && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Utilisateur supprimé avec succès'),
//             backgroundColor: Colors.green,
//           ),
//         );
        
//         // Recharger les données
//         _loadData();
//       } else if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Erreur lors de la suppression'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Color _getRoleColor(String role) {
//     switch (role) {
//       case 'admin':
//         return Colors.purple;
//       case 'owner':
//         return Colors.blue;
//       case 'user':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getRoleIcon(String role) {
//     switch (role) {
//       case 'admin':
//         return Icons.admin_panel_settings;
//       case 'owner':
//         return Icons.business;
//       case 'user':
//         return Icons.person;
//       default:
//         return Icons.person;
//     }
//   }

//   String _getRoleLabel(String role) {
//     switch (role) {
//       case 'admin':
//         return 'Administrateur';
//       case 'owner':
//         return 'Propriétaire';
//       case 'user':
//         return 'Locataire';
//       default:
//         return 'Utilisateur';
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }




