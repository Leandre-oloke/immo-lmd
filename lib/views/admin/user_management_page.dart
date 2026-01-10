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
                _buildStatItem('Total', '${viewModel.totalUsers}', Icons.group),
                _buildStatItem('Propriétaires', '${viewModel.totalOwners}', Icons.business),
                _buildStatItem('Locataires', '${viewModel.totalUsers - viewModel.totalOwners}', Icons.person),
                _buildStatItem('Admins', '${viewModel.totalAdmins}', Icons.admin_panel_settings),
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

    List<Utilisateur> filteredUsers = _filterUsers(
      adminViewModel.allUsers,
      _searchController.text,
      _selectedFilter,
    );

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          final currentUser = authViewModel.currentUser;
          final canModify = currentUser?.role == 'admin' && currentUser?.id != user.id;

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
                      onSelected: (value) => _handleUserAction(value, user, adminViewModel),
                      itemBuilder: (context) => [
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
    );
  }

  List<Utilisateur> _filterUsers(List<Utilisateur> users, String query, String filter) {
    List<Utilisateur> filtered = users;

    // Filtre par recherche
    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.nom.toLowerCase().contains(query.toLowerCase()) ||
               user.email.toLowerCase().contains(query.toLowerCase());
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

  void _handleUserAction(String action, Utilisateur user, AdminViewModel viewModel) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(user, viewModel);
        break;
      case 'delete':
        _showDeleteDialog(user, viewModel);
        break;
    }
  }

  void _showChangeRoleDialog(Utilisateur user, AdminViewModel viewModel) {
    String selectedRole = user.role;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Changer le rôle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Utilisateur: ${user.nom}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Locataire')),
                  DropdownMenuItem(value: 'owner', child: Text('Propriétaire')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Nouveau rôle',
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
              onPressed: () async {
                final success = await viewModel.updateUserRole(user.id, selectedRole);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rôle de ${user.nom} changé en ${_getRoleLabel(selectedRole)}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Utilisateur user, AdminViewModel viewModel) {
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
                final success = await viewModel.deleteUser(user.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
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
}