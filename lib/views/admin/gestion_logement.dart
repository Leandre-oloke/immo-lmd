import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/logement_model.dart';

class AdminLogementsPage extends StatefulWidget {
  const AdminLogementsPage({super.key});

  @override
  State<AdminLogementsPage> createState() => _AdminLogementsPageState();
}

class _AdminLogementsPageState extends State<AdminLogementsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAllLogements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminViewModel = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Logements'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un logement...',
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
          ),

          // Liste des logements
          Expanded(
            child: _buildLogementsList(adminViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildLogementsList(AdminViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Logement> filteredLogements = viewModel.searchLogements(_searchController.text);

    if (filteredLogements.isEmpty) {
      return const Center(
        child: Text('Aucun logement trouvé'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLogements.length,
      itemBuilder: (context, index) {
        final logement = filteredLogements[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: logement.photos.isNotEmpty
                ? Image.network(
                    logement.photos.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.home, size: 40),
            title: Text(
              logement.titre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${logement.prix} €/mois'),
                Text(logement.adresse),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        logement.disponible ? 'Disponible' : 'Occupé',
                        style: TextStyle(
                          color: logement.disponible ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: logement.disponible
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        logement.disponible ? Icons.toggle_on : Icons.toggle_off,
                        color: logement.disponible ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        _toggleLogementStatus(logement, viewModel);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteLogementDialog(logement, viewModel);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleLogementStatus(Logement logement, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Changer le statut'),
          content: Text(
            'Voulez-vous ${logement.disponible ? 'désactiver' : 'activer'} le logement "${logement.titre}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.toggleLogementStatus(
                  logement.id,
                  !logement.disponible,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        logement.disponible
                            ? 'Logement désactivé'
                            : 'Logement activé',
                      ),
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

  void _showDeleteLogementDialog(Logement logement, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le logement'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le logement "${logement.titre}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.deleteLogement(logement.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logement supprimé avec succès'),
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
}