import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/logement_model.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../components/logement_card.dart';
import '../../utils/contact_service.dart'; // ✅ Ajout pour le partage
import 'details_bottom_sheet.dart'; 


class LogementPage extends StatelessWidget {
  const LogementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logementVM = context.watch<LogementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logements disponibles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implémenter les filtres
            },
          ),
        ],
      ),
      body: _buildBody(context, logementVM),
    );
  }

  Widget _buildBody(BuildContext context, LogementViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Chargement des logements..."),
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
              "Erreur de chargement",
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
              child: const Text("Réessayer"),
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
              "Aucun logement disponible",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Revenez plus tard pour découvrir de nouveaux logements",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.loadAllLogements();
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
                //_showLogementDetails(context, logement);
                showLogementDetails(context, logement);
              },
              showOwnerInfo: true,
              showActions: true,
            ),
          );
        },
      ),
    );
  }

  // void _showLogementDetails(BuildContext context, Logement logement) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.9,
  //         minChildSize: 0.5,
  //         maxChildSize: 0.95,
  //         expand: false,
  //         builder: (context, scrollController) {
  //           return SingleChildScrollView(
  //             controller: scrollController,
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // En-tête avec bouton fermer
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         logement.titre,
  //                         style: const TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.close),
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
                    
  //                   // Images
  //                   _buildImageCarousel(logement),
  //                   const SizedBox(height: 20),
                    
  //                   // Prix et statut
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         "${logement.prix} €/mois",
  //                         style: const TextStyle(
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.blue,
  //                         ),
  //                       ),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                         decoration: BoxDecoration(
  //                           color: logement.disponible
  //                               ? Colors.green.shade50
  //                               : Colors.red.shade50,
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         child: Text(
  //                           logement.disponible ? "Disponible" : "Occupé",
  //                           style: TextStyle(
  //                             color: logement.disponible ? Colors.green : Colors.red,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
                    
  //                   // Adresse
  //                   Row(
  //                     children: [
  //                       const Icon(Icons.location_on, color: Colors.grey, size: 20),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           logement.adresse,
  //                           style: const TextStyle(fontSize: 16),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 20),
                    
  //                   // Caractéristiques
  //                   const Text(
  //                     "Caractéristiques",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       _buildFeatureCard(
  //                         icon: Icons.aspect_ratio,
  //                         title: "Superficie",
  //                         value: "${logement.superficie} m²",
  //                       ),
  //                       _buildFeatureCard(
  //                         icon: Icons.bed,
  //                         title: "Chambres",
  //                         value: logement.nombreChambres.toString(),
  //                       ),
  //                       _buildFeatureCard(
  //                         icon: Icons.bathtub,
  //                         title: "Salles de bain",
  //                         value: "1", // À adapter si vous avez ce champ
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 20),
                    
  //                   // Description
  //                   const Text(
  //                     "Description",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     logement.description,
  //                     style: const TextStyle(fontSize: 16, height: 1.5),
  //                   ),
  //                   const SizedBox(height: 30),
                    
  //                   // Boutons d'action
  //                   Consumer<LogementViewModel>(
  //                     builder: (context, viewModel, child) {
  //                       return Column(
  //                         children: [
  //                           Row(
  //                             children: [
  //                               // Bouton Favoris
  //                               Expanded(
  //                                 child: OutlinedButton.icon(
  //                                   onPressed: () {
  //                                     viewModel.toggleFavori(logement.id);
  //                                     ScaffoldMessenger.of(context).showSnackBar(
  //                                       SnackBar(
  //                                         content: Text(
  //                                           logement.isFavori 
  //                                             ? 'Retiré des favoris' 
  //                                             : 'Ajouté aux favoris',
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                   icon: Icon(
  //                                     logement.isFavori ? Icons.favorite : Icons.favorite_border,
  //                                     color: logement.isFavori ? Colors.red : null,
  //                                   ),
  //                                   label: Text(logement.isFavori ? "Favori" : "Favoris"),
  //                                   style: OutlinedButton.styleFrom(
  //                                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                                   ),
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 12),
                                
  //                               // Bouton Contacter
  //                               Expanded(
  //                                 child: ElevatedButton.icon(
  //                                   onPressed: () {
  //                                     _showContactOptions(context, logement);
  //                                   },
  //                                   icon: const Icon(Icons.message),
  //                                   label: const Text("Contacter"),
  //                                   style: ElevatedButton.styleFrom(
  //                                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(height: 10),
                            
  //                           // Bouton Partager
  //                           ElevatedButton.icon(
  //                             onPressed: () async {
  //                               try {
  //                                 await ContactService.partagerLogement(
  //                                   titre: logement.titre,
  //                                   description: logement.description,
  //                                   prix: logement.prix,
  //                                   adresse: logement.adresse,
  //                                   imageUrl: logement.images.isNotEmpty ? logement.images.first : null,
  //                                 );
  //                               } catch (e) {
  //                                 if (!context.mounted) return;
  //                                 ScaffoldMessenger.of(context).showSnackBar(
  //                                   SnackBar(content: Text('Erreur: $e')),
  //                                 );
  //                               }
  //                             },
  //                             icon: const Icon(Icons.share),
  //                             label: const Text("Partager ce logement"),
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Colors.green,
  //                               minimumSize: const Size(double.infinity, 50),
  //                             ),
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   ),
  //                   const SizedBox(height: 20),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Méthode pour afficher les options de contact
  void _showContactOptions(BuildContext context, Logement logement) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contacter le propriétaire',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                logement.proprietaireNom,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                logement.proprietaireNumero,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton Appeler
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ContactService.appeler(logement.proprietaireNumero);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.phone, color: Colors.green),
                      label: const Text('Appeler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Bouton SMS
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ContactService.envoyerSMS(
                            logement.proprietaireNumero,
                            'Bonjour ${logement.proprietaireNom}, je suis intéressé par votre logement "${logement.titre}" situé à ${logement.adresse}.',
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.sms, color: Colors.blue),
                      label: const Text('SMS'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Bouton WhatsApp (optionnel)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implémenter WhatsApp si nécessaire
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp bientôt disponible')),
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel(Logement logement) {
    if (logement.images.isEmpty) {
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
        itemCount: logement.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logement.images[index],
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

  Widget _buildFeatureCard({
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
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/logement_model.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../components/logement_card.dart';

// class LogementPage extends StatelessWidget {
//   const LogementPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final logementVM = context.watch<LogementViewModel>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Logements disponibles"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // TODO: Implémenter la recherche
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () {
//               // TODO: Implémenter les filtres
//             },
//           ),
//         ],
//       ),
//       body: _buildBody(logementVM),
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
//             Text("Chargement des logements..."),
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
//               "Erreur de chargement",
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
//               child: const Text("Réessayer"),
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
//               "Aucun logement disponible",
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "Revenez plus tard pour découvrir de nouveaux logements",
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
//           final logement = viewModel.logements[index]; // Pas besoin de type explicite

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: LogementCard(
//               logement: logement,
//               onTap: () {
//                 _showLogementDetails(context, logement);
//               },
//               showOwnerInfo: true,
//               showActions: true,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showLogementDetails(BuildContext context, Logement logement) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.9,
//           minChildSize: 0.5,
//           maxChildSize: 0.95,
//           expand: false,
//           builder: (context, scrollController) {
//             return SingleChildScrollView(
//               controller: scrollController,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // En-tête avec bouton fermer
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           logement.titre,
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Images
//                     _buildImageCarousel(logement),
//                     const SizedBox(height: 20),
                    
//                     // Prix et statut
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "${logement.prix} €/mois",
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: logement.disponible
//                                 ? Colors.green.shade50
//                                 : Colors.red.shade50,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             logement.disponible ? "Disponible" : "Occupé",
//                             style: TextStyle(
//                               color: logement.disponible ? Colors.green : Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Adresse
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on, color: Colors.grey, size: 20),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             logement.adresse,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Caractéristiques
//                     const Text(
//                       "Caractéristiques",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildFeatureCard(
//                           icon: Icons.aspect_ratio,
//                           title: "Superficie",
//                           value: "${logement.superficie} m²",
//                         ),
//                         _buildFeatureCard(
//                           icon: Icons.bed,
//                           title: "Chambres",
//                           value: logement.nombreChambres.toString(),
//                         ),
//                         _buildFeatureCard(
//                           icon: Icons.bathtub,
//                           title: "Salles de bain",
//                           value: "1", // À adapter si vous avez ce champ
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Description
//                     const Text(
//                       "Description",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       logement.description,
//                       style: const TextStyle(fontSize: 16, height: 1.5),
//                     ),
//                     const SizedBox(height: 30),
                    
//                     // Boutons d'action
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               // TODO: Ajouter aux favoris
//                               Navigator.pop(context,
//                               '/favoris'
                              

//                               );
//                             },
//                             icon: const Icon(Icons.favorite_border),
//                             label: const Text("Favoris"),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
                             
//                               // TODO: Contacter le propriétaire
//                             },
//                             icon: const Icon(Icons.message),
//                             label: const Text("Contacter"),
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildImageCarousel(Logement logement) {
//     if (logement.images.isEmpty) {
//       return Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.photo_camera, size: 60, color: Colors.grey),
//               SizedBox(height: 8),
//               Text("Aucune photo disponible", style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       );
//     }

//     return SizedBox(
//       height: 200,
//       child: PageView.builder(
//         itemCount: logement.images.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 logement.images[index],
//                 fit: BoxFit.cover,
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
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey.shade200,
//                     child: const Center(
//                       child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeatureCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.blue, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
// }
