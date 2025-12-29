import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';

// Vérifiez si votre classe s'appelle User ou Utilisateur
// Si c'est User, changez toutes les références de Utilisateur à User
// Si c'est Utilisateur, assurez-vous qu'il est bien importé

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
  final _superficieController = TextEditingController();
  final _chambresController = TextEditingController();

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
    _superficieController.dispose();
    _chambresController.dispose();
    super.dispose();
  }

  void _loadMyLogements() {
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
        title: const Text("Mes Logements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddLogementDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyLogements,
          ),
        ],
      ),
      body: _buildBody(logementViewModel, currentUser),
    );
  }

  Widget _buildBody(LogementViewModel viewModel, dynamic currentUser) {
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
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
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

    if (currentUser == null) {
      return const Center(
        child: Text("Veuillez vous connecter pour voir vos logements"),
      );
    }

    if (viewModel.myLogements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Aucun logement publié",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Commencez par ajouter votre premier logement",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _showAddLogementDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("Ajouter un logement"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.myLogements.length,
      itemBuilder: (context, index) {
        final logement = viewModel.myLogements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: logement.photos.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      logement.photos.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.home, color: Colors.grey),
                        );
                      },
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
                Text(logement.adresse),
                Text("${logement.prix} € / mois"),
                Text("${logement.superficie} m² - ${logement.nombreChambres} chambre(s)"),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        logement.disponible ? "Disponible" : "Non disponible",
                        style: TextStyle(
                          color: logement.disponible ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: logement.disponible
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                    const Spacer(),
                    Text(
                      "Publié le ${_formatDate(logement.datePublication)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                _handlePopupAction(value, logement, context);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Modifier'),
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
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _handlePopupAction(String action, Logement logement, BuildContext context) {
    switch (action) {
      case 'edit':
        _showEditLogementDialog(context, logement);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, logement);
        break;
    }
  }

  void _showAddLogementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un logement"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: "Titre*",
                      hintText: "Ex: Bel appartement centre ville",
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Décrivez votre logement",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(
                      labelText: "Adresse*",
                      hintText: "Ex: 123 Rue de la Paix, Paris",
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _superficieController,
                          decoration: const InputDecoration(
                            labelText: "Superficie (m²)*",
                            hintText: "Ex: 45",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La superficie est requise';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Superficie invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _chambresController,
                          decoration: const InputDecoration(
                            labelText: "Chambres*",
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final logementViewModel =
                      context.read<LogementViewModel>();
                  final authViewModel = context.read<AuthViewModel>();

                  final nouveauLogement = Logement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titre: _titreController.text.trim(),
                    description: _descriptionController.text.trim(),
                    adresse: _adresseController.text.trim(),
                    prix: double.parse(_prixController.text),
                    superficie: int.parse(_superficieController.text),
                    nombreChambres: int.parse(_chambresController.text),
                    photos: [],
                    proprietaireId: authViewModel.currentUser?.id ?? '',
                    disponible: true,
                    datePublication: DateTime.now(),
                  );

                  final success =
                      await logementViewModel.addLogement(nouveauLogement);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logement ajouté avec succès!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _clearForm();
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

  void _showEditLogementDialog(BuildContext context, Logement logement) {
    _titreController.text = logement.titre;
    _descriptionController.text = logement.description;
    _adresseController.text = logement.adresse;
    _prixController.text = logement.prix.toString();
    _superficieController.text = logement.superficie.toString();
    _chambresController.text = logement.nombreChambres.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le logement"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: "Titre",
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(
                      labelText: "Adresse",
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
                  TextFormField(
                    controller: _prixController,
                    decoration: const InputDecoration(
                      labelText: "Prix mensuel (€)",
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _superficieController,
                          decoration: const InputDecoration(
                            labelText: "Superficie (m²)",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La superficie est requise';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Superficie invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _chambresController,
                          decoration: const InputDecoration(
                            labelText: "Chambres",
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final logementViewModel = context.read<LogementViewModel>();
                  
                  // D'abord supprimer l'ancien logement
                  await logementViewModel.deleteLogement(logement.id);
                  
                  // Créer un nouveau logement avec les modifications
                  final nouveauLogement = Logement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titre: _titreController.text.trim(),
                    description: _descriptionController.text.trim(),
                    adresse: _adresseController.text.trim(),
                    prix: double.parse(_prixController.text),
                    superficie: int.parse(_superficieController.text),
                    nombreChambres: int.parse(_chambresController.text),
                    photos: logement.photos,
                    proprietaireId: logement.proprietaireId,
                    disponible: logement.disponible,
                    datePublication: DateTime.now(),
                  );

                  final success = await logementViewModel.addLogement(nouveauLogement);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logement modifié avec succès!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _clearForm();
                  }
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context, 
    Logement logement,
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
                final logementViewModel =
                    context.read<LogementViewModel>();
                final success =
                    await logementViewModel.deleteLogement(logement.id);

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

  void _clearForm() {
    _titreController.clear();
    _descriptionController.clear();
    _adresseController.clear();
    _prixController.clear();
    _superficieController.clear();
    _chambresController.clear();
  }
}
