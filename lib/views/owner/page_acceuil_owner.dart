import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/owner_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';
import 'mes_logement.dart';
import '../components/app_drawer.dart';
import 'dart:io';
import '../../models/utilisateur_model.dart';

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
  
  // Gestion des photos
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerData();
    });
  }

  void _loadOwnerData() {
    final authViewModel = context.read<AuthViewModel>();
    final ownerViewModel = context.read<OwnerViewModel>();
    
    if (authViewModel.currentUser != null) {
      if (authViewModel.isOwner) {
        ownerViewModel.loadOwnerLogements(authViewModel.currentUser!.id);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    if (!authViewModel.isOwner) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Accès réservé aux propriétaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vous devez être propriétaire pour accéder à cette page',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    final ownerViewModel = context.watch<OwnerViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Propriétaire"),
        backgroundColor: Colors.green,
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
      body: ownerViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(ownerViewModel, currentUser!),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddLogementDialog(context, ownerViewModel, currentUser!);
        },
        icon: const Icon(Icons.add_home),
        label: const Text("Nouveau logement"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildContent(OwnerViewModel viewModel, Utilisateur currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(currentUser, viewModel),
        _buildStatistics(viewModel),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mes logements (${viewModel.myLogements.length})",
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
                icon: const Icon(Icons.list_alt),
                label: const Text("Gérer"),
              ),
            ],
          ),
        ),
        
        _buildLogementsList(viewModel),
      ],
    );
  }

  Widget _buildHeader(Utilisateur currentUser, OwnerViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.business,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour, ${currentUser.nom}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Propriétaire immobilier",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                count: viewModel.ownerStats['totalLogements']?.toString() ?? '0',
                label: "Total",
                icon: Icons.home,
                color: Colors.blue,
              ),
              _buildStatCard(
                count: viewModel.ownerStats['availableLogements']?.toString() ?? '0',
                label: "Disponibles",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                count: viewModel.ownerStats['occupiedLogements']?.toString() ?? '0',
                label: "Occupés",
                icon: Icons.bed,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(OwnerViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Statistiques financières",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      title: "Revenu estimé",
                      value: "${viewModel.ownerStats['estimatedRevenue']?.toStringAsFixed(0) ?? '0'}€",
                      icon: Icons.euro,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      title: "Taux d'occupation",
                      value: "${viewModel.ownerStats['occupancyRate']?.toString() ?? '0'}%",
                      icon: Icons.trending_up,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      title: "Prix moyen",
                      value: "${viewModel.ownerStats['averagePrice']?.toString() ?? '0'}€",
                      icon: Icons.attach_money,
                      color: Colors.purple,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      title: "Prix max/min",
                      value: "${viewModel.ownerStats['highestPrice']?.toStringAsFixed(0) ?? '0'}/${viewModel.ownerStats['lowestPrice']?.toStringAsFixed(0) ?? '0'}€",
                      icon: Icons.show_chart,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
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

  Widget _buildLogementsList(OwnerViewModel viewModel) {
    if (viewModel.myLogements.isEmpty) {
      return Expanded(
        child: Center(
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
                "Aucun logement",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Commencez par ajouter votre premier logement à louer",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final availableLogements = viewModel.availableLogements;
    final occupiedLogements = viewModel.occupiedLogements;

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (availableLogements.isNotEmpty) ...[
            const Text(
              "Disponibles",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...availableLogements.map((logement) => _buildLogementCard(logement, viewModel)).toList(),
            const SizedBox(height: 16),
          ],
          
          if (occupiedLogements.isNotEmpty) ...[
            const Text(
              "Occupés",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ...occupiedLogements.map((logement) => _buildLogementCard(logement, viewModel)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildLogementCard(Logement logement, OwnerViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildLogementImage(logement),
        title: Text(
          logement.titre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${logement.prix.toStringAsFixed(0)} €/mois"),
            const SizedBox(height: 4),
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
            Row(
              children: [
                Icon(
                  Icons.aspect_ratio,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  "${logement.superficie}m²",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.bed,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  "${logement.nombreChambres} chambre(s)",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                logement.disponible ? Icons.toggle_on : Icons.toggle_off,
                color: logement.disponible ? Colors.green : Colors.red,
                size: 30,
              ),
              onPressed: () async {
                final success = await viewModel.toggleLogementAvailability(
                  logement.id,
                  !logement.disponible,
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        logement.disponible 
                          ? "Logement marqué comme disponible" 
                          : "Logement marqué comme occupé",
                      ),
                    ),
                  );
                }
              },
            ),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Modifier'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'photos',
                  child: ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gérer photos'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Supprimer'),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    '/logement-details',
                    arguments: logement,
                  );
                } else if (value == 'photos') {
                  _showManagePhotosDialog(logement, viewModel);
                } else if (value == 'delete') {
                  _showDeleteDialog(logement.id, viewModel);
                }
              },
            ),
          ],
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
  }

  Widget _buildLogementImage(Logement logement) {
    if (logement.images.isNotEmpty && logement.images[0].isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logement.images[0],
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: logement.disponible ? Colors.green.shade50 : Colors.orange.shade50,
              ),
              child: Icon(
                logement.disponible ? Icons.home : Icons.home_work,
                color: logement.disponible ? Colors.green : Colors.orange,
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: logement.disponible ? Colors.green.shade50 : Colors.orange.shade50,
        ),
        child: Icon(
          logement.disponible ? Icons.home : Icons.home_work,
          color: logement.disponible ? Colors.green : Colors.orange,
          size: 30,
        ),
      );
    }
  }

  void _showManagePhotosDialog(Logement logement, OwnerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gérer les photos"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: logement.images.isEmpty
                    ? const Center(child: Text("Aucune photo"))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: logement.images.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  logement.images[index],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                    onPressed: () {
                                      // TODO: Implémenter la suppression de photo
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _pickImagesForLogement(logement, viewModel);
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text("Ajouter des photos"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _pickImagesForLogement(Logement logement, OwnerViewModel viewModel) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // TODO: Implémenter l'upload des images vers Firebase Storage
        // Pour l'instant, on montre juste un message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${images.length} photo(s) sélectionnée(s)"),
          ),
        );
        
        // TODO: Upload vers Firebase Storage et mettre à jour le logement
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(String logementId, OwnerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le logement"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce logement ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteLogement(logementId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logement supprimé avec succès"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddLogementDialog(
    BuildContext context,
    OwnerViewModel viewModel,
    Utilisateur currentUser,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Nouveau logement"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Galerie de photos
                    _buildPhotoGallery(setState),
                    
                    TextField(
                      controller: _titreController,
                      decoration: const InputDecoration(
                        labelText: "Titre*",
                        hintText: "Ex: Studio moderne centre-ville",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText: "Décrivez votre logement...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: "Adresse complète*",
                        hintText: "Ex: 123 Rue de la Paix, 75001 Paris",
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
                              hintText: "Ex: 750",
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
                              hintText: "Ex: 35",
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
                        labelText: "Nombre de chambres*",
                        hintText: "Ex: 2",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Équipements (optionnel)",
                        hintText: "Ex: WiFi, Climatisation, Garage...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearAllFields();
                    _selectedImages.clear();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print('🔄 Bouton "Ajouter le logement" cliqué');
                    
                    if (_validateDialogForm()) {
                      print('✅ Formulaire valide, création du logement...');
                      print('   Titre: ${_titreController.text}');
                      print('   Prix: ${_prixController.text}');
                      print('   Superficie: ${_superficieController.text}');
                      print('   Chambres: ${_chambresController.text}');
                      print('   Images sélectionnées: ${_selectedImages.length}');
                      
                      final nouveauLogement = Logement(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        titre: _titreController.text.trim(),
                        description: _descriptionController.text.trim(),
                        adresse: _adresseController.text.trim(),
                        prix: double.parse(_prixController.text),
                        superficie: int.parse(_superficieController.text), // CORRECTION CRITIQUE
                        nombreChambres: int.parse(_chambresController.text),
                        images: [], // Sera rempli par uploadMultipleImages
                        proprietaireId: currentUser.id,
                        proprietaireNom: currentUser.nom,
                        proprietaireNumero: currentUser.telephone, //=============================================================
                        disponible: true,
                        datePublication: DateTime.now(),
                       // equipements: [],
                      );
                      
                      print('📝 Logement créé avec ID: ${nouveauLogement.id}');
                      
                      try {
                        // Utiliser la méthode avec images
                        final success = await viewModel.addLogementWithPhotos(
                          nouveauLogement,
                          _selectedImages,
                        );
                        
                        if (success && context.mounted) {
                          print('✅ Succès - Fermeture dialogue');
                          Navigator.pop(context);
                          _clearAllFields();
                          _selectedImages.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logement ajouté avec succès!"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else if (context.mounted) {
                          print('❌ Échec - Erreur du ViewModel');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erreur: ${viewModel.errorMessage ?? 'Inconnue'}"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        print('❌ ERREUR pendant l\'appel à addLogementWithimages:');
                        print('   Message: $e');
                        print('   StackTrace: $stackTrace');
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erreur critique: $e"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    } else {
                      print('❌ Formulaire invalide');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Ajouter le logement"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPhotoGallery(void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Photos du logement",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Bouton pour ajouter des photos
        ElevatedButton.icon(
          onPressed: () async {
            await _pickImages(setState);
          },
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text("Ajouter des photos"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Affichage des photos sélectionnées
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _pickImages(void Function(void Function()) setState) async {
    print('📸 Début sélection d\'images...');
    
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images != null && images.isNotEmpty) {
        print('✅ ${images.length} image(s) sélectionnée(s)');
        
        // Vérifier chaque image
        for (var image in images) {
          final file = File(image.path);
          if (await file.exists()) {
            print('   ✓ ${image.name} (${file.lengthSync()} bytes)');
          } else {
            print('   ✗ ${image.name} (fichier inexistant)');
          }
        }
        
        setState(() {
          _selectedImages.addAll(images);
        });
      } else {
        print('ℹ️ Aucune image sélectionnée');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur sélection images: $e');
      print('StackTrace: $stackTrace');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur sélection: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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




