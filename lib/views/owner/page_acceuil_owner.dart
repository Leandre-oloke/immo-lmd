import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';
import 'mes_logement.dart';
import '../components/app_drawer.dart';

class PageAcceuilOwner extends StatefulWidget {
  const PageAcceuilOwner({super.key});

  @override
  State<PageAcceuilOwner> createState() => _PageAcceuilOwnerState();
}

class _PageAcceuilOwnerState extends State<PageAcceuilOwner> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _superficieController = TextEditingController();
  final TextEditingController _chambresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerLogements();
    });
  }

  @override
  void dispose() {
    _titreController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    _adresseController.dispose();
    _superficieController.dispose();
    _chambresController.dispose();
    super.dispose();
  }

  void _loadOwnerLogements() {
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    
    if (currentUser != null) {
      context.read<LogementViewModel>().loadMyLogements(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logementViewModel = context.watch<LogementViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Propriétaire"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statistiques
          _buildHeader(currentUser, logementViewModel),
          
          // Section d'ajout rapide (optionnel)
          _buildQuickAddSection(context, logementViewModel, currentUser),
          
          // Titre de la liste
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mes logements (${logementViewModel.myLogements.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MesLogements(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Voir tout"),
                ),
              ],
            ),
          ),
          
          // Liste des logements
          _buildLogementsList(logementViewModel),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddLogementDialog(context, logementViewModel, currentUser);
        },
        icon: const Icon(Icons.add),
        label: const Text("Ajouter"),
      ),
    );
  }

  Widget _buildHeader(dynamic currentUser, LogementViewModel viewModel) {
    final disponibleCount = viewModel.myLogements
        .where((logement) => logement.disponible)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
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
            "Bonjour, ${currentUser?.nom ?? currentUser?.displayName ?? 'Propriétaire'}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentUser?.email ?? '',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                count: viewModel.myLogements.length.toString(),
                label: "Total",
                icon: Icons.home,
                color: Colors.blue,
              ),
              _buildStatCard(
                count: disponibleCount.toString(),
                label: "Disponibles",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                count: (viewModel.myLogements.length - disponibleCount).toString(),
                label: "Occupés",
                icon: Icons.do_not_disturb,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(
    BuildContext context,
    LogementViewModel viewModel,
    dynamic currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ajouter un logement rapidement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: "Titre",
                  hintText: "Ex: Studio moderne",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prixController,
                      decoration: const InputDecoration(
                        labelText: "Prix (€)",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _chambresController,
                      decoration: const InputDecoration(
                        labelText: "Chambres",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_validateQuickForm()) {
                      final nouveauLogement = Logement(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        titre: _titreController.text.trim(),
                        description: "À compléter...",
                        adresse: "À compléter...",
                        prix: double.parse(_prixController.text),
                        superficie: 0,
                        nombreChambres: int.parse(_chambresController.text),
                        photos: [],
                        proprietaireId: currentUser?.id ?? '',
                        disponible: true,
                        datePublication: DateTime.now(),
                      );

                      final success = await viewModel.addLogement(nouveauLogement);
                      
                      if (success && context.mounted) {
                        _clearQuickForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Logement ajouté! Complétez les informations."),
                            action: SnackBarAction(
                              label: "Éditer",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MesLogements(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Ajouter rapidement"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateQuickForm() {
    if (_titreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le titre est requis")),
      );
      return false;
    }
    
    if (_prixController.text.isEmpty || double.tryParse(_prixController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prix invalide")),
      );
      return false;
    }
    
    if (_chambresController.text.isEmpty || int.tryParse(_chambresController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre de chambres invalide")),
      );
      return false;
    }
    
    return true;
  }

  void _clearQuickForm() {
    _titreController.clear();
    _prixController.clear();
    _chambresController.clear();
  }

  Widget _buildLogementsList(LogementViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.myLogements.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Aucun logement",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "Commencez par ajouter votre premier logement",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddLogementDialog(context, viewModel, null);
                },
                icon: const Icon(Icons.add),
                label: const Text("Ajouter un logement"),
              ),
            ],
          ),
        ),
      );
    }

    final recentLogements = viewModel.myLogements
        .take(3)
        .toList(); // Afficher seulement 3 logements récents

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recentLogements.length,
        itemBuilder: (context, index) {
          final logement = recentLogements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: logement.photos.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logement.photos.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.home, color: Colors.grey),
                    ),
              title: Text(
                logement.titre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${logement.prix} €/mois"),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          logement.adresse,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  logement.disponible ? "Disponible" : "Occupé",
                  style: TextStyle(
                    color: logement.disponible ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: logement.disponible
                    ? Colors.green.shade50
                    : Colors.red.shade50,
              ),
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

  void _showAddLogementDialog(
    BuildContext context,
    LogementViewModel viewModel,
    dynamic currentUser,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouveau logement"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titreController,
                  decoration: const InputDecoration(
                    labelText: "Titre*",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: "Adresse*",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _prixController,
                        decoration: const InputDecoration(
                          labelText: "Prix (€)*",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _superficieController,
                        decoration: const InputDecoration(
                          labelText: "Superficie (m²)*",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chambresController,
                  decoration: const InputDecoration(
                    labelText: "Chambres*",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearAllFields();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_validateDialogForm()) {
                  final nouveauLogement = Logement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titre: _titreController.text.trim(),
                    description: _descriptionController.text.trim(),
                    adresse: _adresseController.text.trim(),
                    prix: double.parse(_prixController.text),
                    superficie: int.parse(_superficieController.text),
                    nombreChambres: int.parse(_chambresController.text),
                    photos: [],
                    proprietaireId: currentUser?.id ?? '',
                    disponible: true,
                    datePublication: DateTime.now(),
                  );

                  final success = await viewModel.addLogement(nouveauLogement);
                  
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _clearAllFields();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logement ajouté avec succès!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  bool _validateDialogForm() {
    if (_titreController.text.isEmpty) {
      _showError("Le titre est requis");
      return false;
    }
    
    if (_adresseController.text.isEmpty) {
      _showError("L'adresse est requise");
      return false;
    }
    
    if (_prixController.text.isEmpty || double.tryParse(_prixController.text) == null) {
      _showError("Prix invalide");
      return false;
    }
    
    if (_superficieController.text.isEmpty || int.tryParse(_superficieController.text) == null) {
      _showError("Superficie invalide");
      return false;
    }
    
    if (_chambresController.text.isEmpty || int.tryParse(_chambresController.text) == null) {
      _showError("Nombre de chambres invalide");
      return false;
    }
    
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearAllFields() {
    _titreController.clear();
    _descriptionController.clear();
    _adresseController.clear();
    _prixController.clear();
    _superficieController.clear();
    _chambresController.clear();
  }
}