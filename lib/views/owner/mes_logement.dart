import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodels/owner_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';
import 'dart:io'; // Pour File
import '../components/app_drawer.dart';
import '../../models/utilisateur_model.dart';

class MesLogements extends StatefulWidget {
  const MesLogements({super.key});

  @override
  State<MesLogements> createState() => _MesLogementsState();
}

class _MesLogementsState extends State<MesLogements> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _adresseController = TextEditingController();
  final _prixController = TextEditingController();
  final _chambresController = TextEditingController();
  
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  
  // Pour l'édition
  Logement? _logementEnEdition;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyLogements();
    });
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _adresseController.dispose();
    _prixController.dispose();
    _chambresController.dispose();
    super.dispose();
  }

  void _loadMyLogements() {
    final authViewModel = context.read<AuthViewModel>();
    final ownerViewModel = context.read<OwnerViewModel>();
    
    if (authViewModel.currentUser != null && authViewModel.isOwner) {
      ownerViewModel.loadOwnerLogements(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    // Vérification de rôle
    if (!authViewModel.isOwner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mes Logements"),
          backgroundColor: Colors.green,
        ),
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
                'Vous devez être propriétaire pour gérer des logements',
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
        title: const Text("Gestion de mes logements"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _resetForm();
              _showAddEditLogementDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyLogements,
          ),
        ],
      ),
      body: _buildBody(ownerViewModel, currentUser!),
    );
  }

  Widget _buildBody(OwnerViewModel viewModel, Utilisateur currentUser) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Erreur",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMyLogements,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (viewModel.myLogements.isEmpty) {
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
              "Aucun logement publié",
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _resetForm();
                _showAddEditLogementDialog(context);
              },
              icon: const Icon(Icons.add_home),
              label: const Text("Ajouter un logement"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistiques rapides
        _buildQuickStats(viewModel),
        
        // Liste des logements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.myLogements.length,
            itemBuilder: (context, index) {
              final logement = viewModel.myLogements[index];
              return _buildLogementCard(logement, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(OwnerViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistiques",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  title: "Total",
                  value: viewModel.myLogements.length.toString(),
                  color: Colors.blue,
                ),
                _buildStatItem(
                  title: "Disponibles",
                  value: viewModel.availableLogements.length.toString(),
                  color: Colors.green,
                ),
                _buildStatItem(
                  title: "Occupés",
                  value: viewModel.occupiedLogements.length.toString(),
                  color: Colors.orange,
                ),
                _buildStatItem(
                  title: "Revenu estimé",
                  value: "${viewModel.ownerStats['estimatedRevenue']?.toStringAsFixed(0) ?? '0'}€/mois",
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLogementCard(Logement logement, OwnerViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image et status
          Stack(
            children: [
              _buildLogementImage(logement),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: logement.disponible ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    logement.disponible ? 'DISPONIBLE' : 'OCCUPÉ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        logement.titre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${logement.prix.toStringAsFixed(0)}€/mois",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        logement.adresse,
                        style: TextStyle(color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bed, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (logement.description.isNotEmpty)
                  Text(
                    logement.description,
                    style: TextStyle(color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await viewModel.toggleLogementAvailability(
                          logement.id,
                          !logement.disponible,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                logement.disponible 
                                  ? "Logement marqué comme occupé" 
                                  : "Logement marqué comme disponible",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        logement.disponible ? Icons.check_circle : Icons.cancel,
                        size: 18,
                      ),
                      label: Text(
                        logement.disponible ? "Marquer occupé" : "Marquer disponible",
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logement.disponible 
                            ? Colors.orange.shade50 
                            : Colors.green.shade50,
                        foregroundColor: logement.disponible 
                            ? Colors.orange 
                            : Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _loadLogementForEdit(logement);
                            _showAddEditLogementDialog(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, logement, viewModel);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogementImage(Logement logement) {
    if (logement.photos.isNotEmpty && logement.photos[0].isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Image.network(
            logement.photos[0],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultImage(logement);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return _buildDefaultImage(logement);
    }
  }

  Widget _buildDefaultImage(Logement logement) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: logement.disponible ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work,
            size: 60,
            color: logement.disponible ? Colors.green.shade300 : Colors.orange.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            "Aucune photo",
            style: TextStyle(
              color: logement.disponible ? Colors.green.shade400 : Colors.orange.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _loadLogementForEdit(Logement logement) {
    _logementEnEdition = logement;
    _isEditing = true;
    
    _titreController.text = logement.titre;
    _descriptionController.text = logement.description;
    _adresseController.text = logement.adresse;
    _prixController.text = logement.prix.toString();
    _chambresController.text = logement.nombreChambres.toString();
  }

  void _resetForm() {
    _logementEnEdition = null;
    _isEditing = false;
    _titreController.clear();
    _descriptionController.clear();
    _adresseController.clear();
    _prixController.clear();
    _chambresController.clear();
    _selectedImages.clear();
  }

  void _showAddEditLogementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(_isEditing ? "Modifier le logement" : "Nouveau logement"),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Photos
                      _buildPhotoGallery(setState),
                      
                      // Titre
                      TextFormField(
                        controller: _titreController,
                        decoration: const InputDecoration(
                          labelText: "Titre*",
                          hintText: "Ex: Studio moderne centre-ville",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le titre est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          hintText: "Décrivez votre logement...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      
                      // Adresse
                      TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          labelText: "Adresse complète*",
                          hintText: "Ex: 123 Rue de la Paix, 75001 Paris",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'adresse est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Prix
                      TextFormField(
                        controller: _prixController,
                        decoration: const InputDecoration(
                          labelText: "Prix mensuel (€)*",
                          hintText: "Ex: 750",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le prix est requis';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Prix invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Chambres
                      TextFormField(
                        controller: _chambresController,
                        decoration: const InputDecoration(
                          labelText: "Nombre de chambres*",
                          hintText: "Ex: 2",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nombre de chambres est requis';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetForm();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final ownerViewModel = context.read<OwnerViewModel>();
                      final authViewModel = context.read<AuthViewModel>();
                      final currentUser = authViewModel.currentUser!;

                      final logement = Logement(
                        id: _isEditing 
                            ? _logementEnEdition!.id 
                            : DateTime.now().millisecondsSinceEpoch.toString(),
                        titre: _titreController.text.trim(),
                        description: _descriptionController.text.trim(),
                        adresse: _adresseController.text.trim(),
                        prix: double.parse(_prixController.text),
                        superficie: 0, // Valeur par défaut puisque supprimé
                        nombreChambres: int.parse(_chambresController.text),
                        photos: _isEditing 
                            ? _logementEnEdition!.photos 
                            : [], // Les photos seront uploadées séparément
                        proprietaireId: currentUser.id,
                        proprietaireNom: currentUser.nom,
                        disponible: _isEditing 
                            ? _logementEnEdition!.disponible 
                            : true,
                        datePublication: _isEditing 
                            ? _logementEnEdition!.datePublication 
                            : DateTime.now(),
                       // equipements: [], // Vide puisque supprimé
                      );

                      // final success = _isEditing
                      //     ? await ownerViewModel.updateLogement(logement)
                      //     : await ownerViewModel.addLogement(logement);

                      // if (success && context.mounted) {
                      //   Navigator.pop(context);
                      //   _resetForm();
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text(
                      //         _isEditing 
                      //             ? "Logement modifié avec succès!" 
                      //             : "Logement ajouté avec succès!",
                      //       ),
                      //       backgroundColor: Colors.green,
                      //     ),
                      //   );
                      // }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(_isEditing ? "Modifier" : "Ajouter"),
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
            backgroundColor: Colors.green,
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
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la sélection: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context, 
    Logement logement,
    OwnerViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text(
            "Êtes-vous sûr de vouloir supprimer \"${logement.titre}\" ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await viewModel.deleteLogement(logement.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logement supprimé avec succès!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../models/logement_model.dart';

// // Vérifiez si votre classe s'appelle User ou Utilisateur
// // Si c'est User, changez toutes les références de Utilisateur à User
// // Si c'est Utilisateur, assurez-vous qu'il est bien importé

// class MesLogements extends StatefulWidget {
//   const MesLogements({super.key});

//   @override
//   State<MesLogements> createState() => _MesLogementsState();
// }

// class _MesLogementsState extends State<MesLogements> {
//   final _formKey = GlobalKey<FormState>();
//   final _titreController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _adresseController = TextEditingController();
//   final _prixController = TextEditingController();
//   final _superficieController = TextEditingController();
//   final _chambresController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMyLogements();
//     });
//   }

//   @override
//   void dispose() {
//     _titreController.dispose();
//     _descriptionController.dispose();
//     _adresseController.dispose();
//     _prixController.dispose();
//     _superficieController.dispose();
//     _chambresController.dispose();
//     super.dispose();
//   }

//   void _loadMyLogements() {
//     final authViewModel = context.read<AuthViewModel>();
//     final currentUser = authViewModel.currentUser;
    
//     if (currentUser != null) {
//       context.read<LogementViewModel>().loadMyLogements(currentUser.id);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final logementViewModel = context.watch<LogementViewModel>();
//     final authViewModel = context.watch<AuthViewModel>();
//     final currentUser = authViewModel.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Mes Logements"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               _showAddLogementDialog(context);
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadMyLogements,
//           ),
//         ],
//       ),
//       body: _buildBody(logementViewModel, currentUser),
//     );
//   }

//   Widget _buildBody(LogementViewModel viewModel, dynamic currentUser) {
//     if (viewModel.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (viewModel.errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 60, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               "Erreur",
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               viewModel.errorMessage!,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadMyLogements,
//               child: const Text("Réessayer"),
//             ),
//           ],
//         ),
//       );
//     }

//     if (currentUser == null) {
//       return const Center(
//         child: Text("Veuillez vous connecter pour voir vos logements"),
//       );
//     }

//     if (viewModel.myLogements.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.home, size: 80, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               "Aucun logement publié",
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "Commencez par ajouter votre premier logement",
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () {
//                 _showAddLogementDialog(context);
//               },
//               icon: const Icon(Icons.add),
//               label: const Text("Ajouter un logement"),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: viewModel.myLogements.length,
//       itemBuilder: (context, index) {
//         final logement = viewModel.myLogements[index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           child: ListTile(
//             leading: logement.photos.isNotEmpty
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       logement.photos.first,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(Icons.home, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   )
//                 : Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.home, color: Colors.grey),
//                   ),
//             title: Text(
//               logement.titre,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(logement.adresse),
//                 Text("${logement.prix} € / mois"),
//                 Text("${logement.superficie} m² - ${logement.nombreChambres} chambre(s)"),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Chip(
//                       label: Text(
//                         logement.disponible ? "Disponible" : "Non disponible",
//                         style: TextStyle(
//                           color: logement.disponible ? Colors.green : Colors.red,
//                           fontSize: 12,
//                         ),
//                       ),
//                       backgroundColor: logement.disponible
//                           ? Colors.green.shade50
//                           : Colors.red.shade50,
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//                     ),
//                     const Spacer(),
//                     Text(
//                       "Publié le ${_formatDate(logement.datePublication)}",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             trailing: PopupMenuButton<String>(
//               onSelected: (value) {
//                 _handlePopupAction(value, logement, context);
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, size: 20, color: Colors.blue),
//                       SizedBox(width: 8),
//                       Text('Modifier'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, size: 20, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Supprimer'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             onTap: () {
//               Navigator.pushNamed(
//                 context,
//                 '/logement-details',
//                 arguments: logement,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     return "${date.day}/${date.month}/${date.year}";
//   }

//   void _handlePopupAction(String action, Logement logement, BuildContext context) {
//     switch (action) {
//       case 'edit':
//         _showEditLogementDialog(context, logement);
//         break;
//       case 'delete':
//         _showDeleteConfirmationDialog(context, logement);
//         break;
//     }
//   }

//   void _showAddLogementDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Ajouter un logement"),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _titreController,
//                     decoration: const InputDecoration(
//                       labelText: "Titre*",
//                       hintText: "Ex: Bel appartement centre ville",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Le titre est requis';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: "Description",
//                       hintText: "Décrivez votre logement",
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _adresseController,
//                     decoration: const InputDecoration(
//                       labelText: "Adresse*",
//                       hintText: "Ex: 123 Rue de la Paix, Paris",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'L\'adresse est requise';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _prixController,
//                     decoration: const InputDecoration(
//                       labelText: "Prix mensuel (€)*",
//                       hintText: "Ex: 750",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Le prix est requis';
//                       }
//                       if (double.tryParse(value) == null) {
//                         return 'Prix invalide';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _superficieController,
//                           decoration: const InputDecoration(
//                             labelText: "Superficie (m²)*",
//                             hintText: "Ex: 45",
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'La superficie est requise';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'Superficie invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _chambresController,
//                           decoration: const InputDecoration(
//                             labelText: "Chambres*",
//                             hintText: "Ex: 2",
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Le nombre de chambres est requis';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'Nombre invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _clearForm();
//               },
//               child: const Text("Annuler"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   final logementViewModel =
//                       context.read<LogementViewModel>();
//                   final authViewModel = context.read<AuthViewModel>();

//                   final nouveauLogement = Logement(
//                     id: DateTime.now().millisecondsSinceEpoch.toString(),
//                     titre: _titreController.text.trim(),
//                     description: _descriptionController.text.trim(),
//                     adresse: _adresseController.text.trim(),
//                     prix: double.parse(_prixController.text),
//                     superficie: int.parse(_superficieController.text),
//                     nombreChambres: int.parse(_chambresController.text),
//                     photos: [],
//                     proprietaireId: authViewModel.currentUser?.id ?? '',
//                     disponible: true,
//                     datePublication: DateTime.now(),
//                   );

//                   final success =
//                       await logementViewModel.addLogement(nouveauLogement);

//                   if (success && context.mounted) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Logement ajouté avec succès!"),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                     _clearForm();
//                   }
//                 }
//               },
//               child: const Text("Ajouter"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditLogementDialog(BuildContext context, Logement logement) {
//     _titreController.text = logement.titre;
//     _descriptionController.text = logement.description;
//     _adresseController.text = logement.adresse;
//     _prixController.text = logement.prix.toString();
//     _superficieController.text = logement.superficie.toString();
//     _chambresController.text = logement.nombreChambres.toString();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Modifier le logement"),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: _titreController,
//                     decoration: const InputDecoration(
//                       labelText: "Titre",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Le titre est requis';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: "Description",
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _adresseController,
//                     decoration: const InputDecoration(
//                       labelText: "Adresse",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'L\'adresse est requise';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _prixController,
//                     decoration: const InputDecoration(
//                       labelText: "Prix mensuel (€)",
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Le prix est requis';
//                       }
//                       if (double.tryParse(value) == null) {
//                         return 'Prix invalide';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _superficieController,
//                           decoration: const InputDecoration(
//                             labelText: "Superficie (m²)",
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'La superficie est requise';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'Superficie invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _chambresController,
//                           decoration: const InputDecoration(
//                             labelText: "Chambres",
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Le nombre de chambres est requis';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'Nombre invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _clearForm();
//               },
//               child: const Text("Annuler"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   final logementViewModel = context.read<LogementViewModel>();
                  
//                   // D'abord supprimer l'ancien logement
//                   await logementViewModel.deleteLogement(logement.id);
                  
//                   // Créer un nouveau logement avec les modifications
//                   final nouveauLogement = Logement(
//                     id: DateTime.now().millisecondsSinceEpoch.toString(),
//                     titre: _titreController.text.trim(),
//                     description: _descriptionController.text.trim(),
//                     adresse: _adresseController.text.trim(),
//                     prix: double.parse(_prixController.text),
//                     superficie: int.parse(_superficieController.text),
//                     nombreChambres: int.parse(_chambresController.text),
//                     photos: logement.photos,
//                     proprietaireId: logement.proprietaireId,
//                     disponible: logement.disponible,
//                     datePublication: DateTime.now(),
//                   );

//                   final success = await logementViewModel.addLogement(nouveauLogement);

//                   if (success && context.mounted) {
//                     Navigator.pop(context);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Logement modifié avec succès!"),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                     _clearForm();
//                   }
//                 }
//               },
//               child: const Text("Enregistrer"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDeleteConfirmationDialog(
//     BuildContext context, 
//     Logement logement,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Confirmer la suppression"),
//           content: Text(
//             "Êtes-vous sûr de vouloir supprimer \"${logement.titre}\" ?",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Annuler"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final logementViewModel =
//                     context.read<LogementViewModel>();
//                 final success =
//                     await logementViewModel.deleteLogement(logement.id);

//                 if (success && context.mounted) {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Logement supprimé avec succès!"),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text("Supprimer"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _clearForm() {
//     _titreController.clear();
//     _descriptionController.clear();
//     _adresseController.clear();
//     _prixController.clear();
//     _superficieController.clear();
//     _chambresController.clear();
//   }
// }
