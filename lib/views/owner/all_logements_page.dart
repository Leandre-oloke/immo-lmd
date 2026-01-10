// lib/views/owner/all_logements_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/users_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';
import '../logement/logement_page.dart';

class AllLogementsPage extends StatefulWidget {
  const AllLogementsPage({super.key});

  @override
  State<AllLogementsPage> createState() => _AllLogementsPageState();
}

class _AllLogementsPageState extends State<AllLogementsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllLogements();
    });
  }

  void _loadAllLogements() {
    final userViewModel = context.read<UsersViewModel>();
    userViewModel.loadAllLogements();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UsersViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les logements'),
        backgroundColor: Colors.green,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                userViewModel.setSearchQuery(value);
              },
            ),
          ),

          // Filtres rapides
          _buildQuickFilters(userViewModel),

          // Résultats
          Expanded(
            child: userViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLogementsList(userViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(UsersViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text('Disponibles'),
            selected: viewModel.searchFilters['onlyAvailable'] == true,
            onSelected: (selected) {
              viewModel.setSearchFilters({
                ...viewModel.searchFilters,
                'onlyAvailable': selected,
              });
            },
          ),
          FilterChip(
            label: const Text('Moins de 500€'),
            selected: viewModel.searchFilters['maxPrice'] == 500,
            onSelected: (selected) {
              viewModel.setSearchFilters({
                ...viewModel.searchFilters,
                'maxPrice': selected ? 500 : null,
              });
            },
          ),
          FilterChip(
            label: const Text('1-2 chambres'),
            selected: viewModel.searchFilters['minChambres'] == 1 && 
                      viewModel.searchFilters['maxChambres'] == 2,
            onSelected: (selected) {
              viewModel.setSearchFilters({
                ...viewModel.searchFilters,
                'minChambres': selected ? 1 : null,
                'maxChambres': selected ? 2 : null,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogementsList(UsersViewModel viewModel) {
    if (viewModel.filteredLogements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun logement trouvé',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_searchController.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  viewModel.setSearchQuery('');
                },
                child: const Text('Effacer la recherche'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.filteredLogements.length,
      itemBuilder: (context, index) {
        final logement = viewModel.filteredLogements[index];
        return _buildLogementCard(logement, viewModel);
      },
    );
  }

  Widget _buildLogementCard(Logement logement, UsersViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: () {
          _showLogementDetails(context, logement, viewModel);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            _buildLogementImage(logement),
            
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: logement.disponible 
                              ? Colors.green.shade50 
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          logement.disponible ? 'Disponible' : 'Occupé',
                          style: TextStyle(
                            color: logement.disponible 
                                ? Colors.green 
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${logement.prix.toStringAsFixed(0)} €/mois',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
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
                        '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.apartment, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${logement.superficie}m²',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Propriétaire: ${logement.proprietaireNom}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          viewModel.isFavorite(logement.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: viewModel.isFavorite(logement.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                        onPressed: () {
                          if (viewModel.isFavorite(logement.id)) {
                            viewModel.removeFromFavorites(logement.id);
                          } else {
                            viewModel.addToFavorites(logement);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogementImage(Logement logement) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: logement.photos.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                logement.photos[0],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage(logement);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            )
          : _buildDefaultImage(logement),
    );
  }

  Widget _buildDefaultImage(Logement logement) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: logement.disponible 
            ? Colors.green.shade50 
            : Colors.orange.shade50,
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
            color: logement.disponible 
                ? Colors.green.shade300 
                : Colors.orange.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune photo',
            style: TextStyle(
              color: logement.disponible 
                  ? Colors.green.shade400 
                  : Colors.orange.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher les détails d'un logement (basée sur celle de logement_page.dart)
  void _showLogementDetails(BuildContext context, Logement logement, UsersViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec bouton fermer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            logement.titre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Images
                    _buildDetailsImageCarousel(logement),
                    const SizedBox(height: 20),
                    
                    // Prix et statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${logement.prix.toStringAsFixed(0)} €/mois",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: logement.disponible
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            logement.disponible ? "Disponible" : "Occupé",
                            style: TextStyle(
                              color: logement.disponible ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Adresse
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            logement.adresse,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Caractéristiques
                    const Text(
                      "Caractéristiques",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailsFeatureCard(
                          icon: Icons.aspect_ratio,
                          title: "Superficie",
                          value: "${logement.superficie} m²",
                        ),
                        _buildDetailsFeatureCard(
                          icon: Icons.bed,
                          title: "Chambres",
                          value: logement.nombreChambres.toString(),
                        ),
                        _buildDetailsFeatureCard(
                          icon: Icons.bathtub,
                          title: "Salles de bain",
                          value: "1", // À adapter si vous avez ce champ
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      logement.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    
                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (viewModel.isFavorite(logement.id)) {
                                viewModel.removeFromFavorites(logement.id);
                              } else {
                                viewModel.addToFavorites(logement);
                              }
                              Navigator.pop(context);
                              // Rafraîchir l'UI
                              setState(() {});
                            },
                            icon: Icon(
                              viewModel.isFavorite(logement.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: viewModel.isFavorite(logement.id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            label: Text(
                              viewModel.isFavorite(logement.id)
                                  ? "Retirer des favoris"
                                  : "Ajouter aux favoris",
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Contacter le propriétaire
                              // Vous pourriez ouvrir un dialogue de contact ici
                              _showContactDialog(context, logement);
                            },
                            icon: const Icon(Icons.message),
                            label: const Text("Contacter"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Informations propriétaire
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Propriétaire",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  logement.proprietaireNom,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailsImageCarousel(Logement logement) {
    if (logement.photos.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera, size: 60, color: Colors.grey),
              SizedBox(height: 8),
              Text("Aucune photo disponible", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: logement.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logement.photos[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsFeatureCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context, Logement logement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contacter le propriétaire"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Envoyez un message au propriétaire :"),
            const SizedBox(height: 16),
            Text(
              "Logement : ${logement.titre}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Propriétaire : ${logement.proprietaireNom}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter l'envoi de message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fonctionnalité de messagerie à implémenter"),
                ),
              );
            },
            child: const Text("Envoyer un message"),
          ),
        ],
      ),
    );
  }
}


// // lib/views/owner/all_logements_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/users_viewmodel.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../models/logement_model.dart';
// import '../logement/logement_page.dart';


// class AllLogementsPage extends StatefulWidget {
//   const AllLogementsPage({super.key});

//   @override
//   State<AllLogementsPage> createState() => _AllLogementsPageState();
// }

// class _AllLogementsPageState extends State<AllLogementsPage> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadAllLogements();
//     });
//   }

//   void _loadAllLogements() {
//     final userViewModel = context.read<UsersViewModel>();
//     userViewModel.loadAllLogements();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userViewModel = context.watch<UsersViewModel>();
//     final authViewModel = context.watch<AuthViewModel>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tous les logements'),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(
//         children: [
//           // Barre de recherche
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Rechercher un logement...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onChanged: (value) {
//                 userViewModel.setSearchQuery(value);
//               },
//             ),
//           ),

//           // Filtres rapides
//           _buildQuickFilters(userViewModel),

//           // Résultats
//           Expanded(
//             child: userViewModel.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildLogementsList(userViewModel),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickFilters(UsersViewModel viewModel) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Wrap(
//         spacing: 8,
//         runSpacing: 8,
//         children: [
//           FilterChip(
//             label: const Text('Disponibles'),
//             selected: viewModel.searchFilters['onlyAvailable'] == true,
//             onSelected: (selected) {
//               viewModel.setSearchFilters({
//                 ...viewModel.searchFilters,
//                 'onlyAvailable': selected,
//               });
//             },
//           ),
//           FilterChip(
//             label: const Text('Moins de 500€'),
//             selected: viewModel.searchFilters['maxPrice'] == 500,
//             onSelected: (selected) {
//               viewModel.setSearchFilters({
//                 ...viewModel.searchFilters,
//                 'maxPrice': selected ? 500 : null,
//               });
//             },
//           ),
//           FilterChip(
//             label: const Text('1-2 chambres'),
//             selected: viewModel.searchFilters['minChambres'] == 1 && 
//                       viewModel.searchFilters['maxChambres'] == 2,
//             onSelected: (selected) {
//               viewModel.setSearchFilters({
//                 ...viewModel.searchFilters,
//                 'minChambres': selected ? 1 : null,
//                 'maxChambres': selected ? 2 : null,
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLogementsList(UsersViewModel viewModel) {
//     if (viewModel.filteredLogements.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off, size: 60, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'Aucun logement trouvé',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             if (_searchController.text.isNotEmpty)
//               TextButton(
//                 onPressed: () {
//                   _searchController.clear();
//                   viewModel.setSearchQuery('');
//                 },
//                 child: const Text('Effacer la recherche'),
//               ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: viewModel.filteredLogements.length,
//       itemBuilder: (context, index) {
//         final logement = viewModel.filteredLogements[index];
//         return _buildLogementCard(logement, viewModel);
//       },
//     );
//   }

//   Widget _buildLogementCard(Logement logement, UsersViewModel viewModel) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 3,
//       child: InkWell(
//         onTap: () {
//           // Navigator.push(
//           //   context,
//           //   MaterialPageRoute(
//           //     builder: (context) => LogementPage(logement: logement),
//           //   ),
//           // );
//           // Utilisez simplement :
//           _showLogementDetails(context, logement);
          
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image
//             _buildLogementImage(logement),
            
//             // Informations
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           logement.titre,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: logement.disponible 
//                               ? Colors.green.shade50 
//                               : Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           logement.disponible ? 'Disponible' : 'Occupé',
//                           style: TextStyle(
//                             color: logement.disponible 
//                                 ? Colors.green 
//                                 : Colors.orange,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${logement.prix.toStringAsFixed(0)} €/mois',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           logement.adresse,
//                           style: TextStyle(color: Colors.grey.shade600),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(Icons.bed, size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       const SizedBox(width: 16),
//                       Icon(Icons.apartment, size: 16, color: Colors.grey.shade600),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${logement.superficie}m²',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   if (logement.description.isNotEmpty)
//                     Text(
//                       logement.description,
//                       style: TextStyle(color: Colors.grey.shade700),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Propriétaire: ${logement.proprietaireNom}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           viewModel.isFavorite(logement.id)
//                               ? Icons.favorite
//                               : Icons.favorite_border,
//                           color: viewModel.isFavorite(logement.id)
//                               ? Colors.red
//                               : Colors.grey,
//                         ),
//                         onPressed: () {
//                           if (viewModel.isFavorite(logement.id)) {
//                             viewModel.removeFromFavorites(logement.id);
//                           } else {
//                             viewModel.addToFavorites(logement);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLogementImage(Logement logement) {
//     return SizedBox(
//       height: 200,
//       width: double.infinity,
//       child: logement.photos.isNotEmpty
//           ? ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//               child: Image.network(
//                 logement.photos[0],
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return _buildDefaultImage(logement);
//                 },
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                           : null,
//                     ),
//                   );
//                 },
//               ),
//             )
//           : _buildDefaultImage(logement),
//     );
//   }

//   Widget _buildDefaultImage(Logement logement) {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: logement.disponible 
//             ? Colors.green.shade50 
//             : Colors.orange.shade50,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(12),
//           topRight: Radius.circular(12),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.home_work,
//             size: 60,
//             color: logement.disponible 
//                 ? Colors.green.shade300 
//                 : Colors.orange.shade300,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Aucune photo',
//             style: TextStyle(
//               color: logement.disponible 
//                   ? Colors.green.shade400 
//                   : Colors.orange.shade400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }