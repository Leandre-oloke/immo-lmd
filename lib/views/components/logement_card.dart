import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/logement_model.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../utils/contact_service.dart';
import '../../views/logement/details_bottom_sheet.dart';

class LogementCard extends StatelessWidget {
  final Logement logement;
  final VoidCallback onTap;
  final bool showOwnerInfo;
  final bool showActions;

  const LogementCard({
    super.key,
    required this.logement,
    required this.onTap,
    this.showOwnerInfo = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showLogementDetails(context, logement);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du logement
            _buildImageSection(context),
            
            // Informations principales
            _buildInfoSection(),
            
            // Actions supplémentaires (si activé)
            if (showActions) _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // ✅ Utilise Consumer pour écouter les changements du ViewModel
    return Consumer<LogementViewModel>(
      builder: (context, viewModel, child) {
        final isFavori = viewModel.isFavorite(logement.id);
        
        return Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: logement.images.isNotEmpty
                  ? Image.network(
                      logement.images.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.home,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.home,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            
            // Badge de disponibilité
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: logement.disponible 
                      ? Colors.green.withOpacity(0.9)
                      : Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  logement.disponible ? 'Disponible' : 'Occupé',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Badge prix
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${logement.prix} CFA/mois',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // ✅ Badge favori (mis à jour dynamiquement)
            if (isFavori)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Favori',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            logement.titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          if (logement.description.isNotEmpty)
            Column(
              children: [
                Text(
                  logement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          
          // Adresse
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  logement.adresse,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Caractéristiques
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureItem(
                icon: Icons.aspect_ratio,
                text: '${logement.superficie} m²',
              ),
              _buildFeatureItem(
                icon: Icons.bed,
                text: '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
              ),
              _buildFeatureItem(
                icon: Icons.photo_library,
                text: '${logement.images.length} photo${logement.images.length > 1 ? 's' : ''}',
              ),
            ],
          ),
          
          // Informations propriétaire (si activé)
          if (showOwnerInfo) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Propriétaire',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        logement.proprietaireNom,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // Fonctionnalité déplacée dans le bouton Contact
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    // ✅ Utilise Consumer pour écouter les changements en temps réel
    return Consumer<LogementViewModel>(
      builder: (context, viewModel, child) {
        final isFavori = viewModel.isFavorite(logement.id);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ Bouton favori corrigé avec gestion d'erreur
              TextButton.icon(
                onPressed: () async {
                  try {
                    await viewModel.toggleFavori(logement.id);
                    
                    if (!context.mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavori 
                            ? 'Retiré des favoris' 
                            : 'Ajouté aux favoris',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: isFavori ? Colors.orange : Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(
                  isFavori ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFavori ? Colors.red : Colors.grey.shade600,
                ),
                label: Text(
                  'Favori',
                  style: TextStyle(
                    color: isFavori ? Colors.red : Colors.grey.shade800,
                    fontWeight: isFavori ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              
              // Bouton partager
              TextButton.icon(
                onPressed: () {
                  _partagerLogement(context);
                },
                icon: Icon(
                  Icons.share,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                label: Text(
                  'Partager',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
              
              // Bouton contact
              ElevatedButton.icon(
                onPressed: () {
                  _contacterProprietaire(context);
                },
                icon: const Icon(Icons.message, size: 16),
                label: const Text('Contacter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour contacter le propriétaire
  void _contacterProprietaire(BuildContext context) {
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
                            SnackBar(
                              content: Text('Erreur: $e'),
                              duration: const Duration(seconds: 3),
                            ),
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
                            SnackBar(
                              content: Text('Erreur: $e'),
                              duration: const Duration(seconds: 3),
                            ),
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
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WhatsApp bientôt disponible'),
                      duration: Duration(seconds: 2),
                    ),
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

  // Méthode pour partager le logement
  void _partagerLogement(BuildContext context) async {
    try {
      await ContactService.partagerLogement(
        titre: logement.titre,
        description: logement.description,
        prix: logement.prix,
        adresse: logement.adresse,
        imageUrl: logement.images.isNotEmpty ? logement.images.first : null,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ========== VARIANTE COMPACTE ==========

class LogementCardCompact extends StatelessWidget {
  final Logement logement;
  final VoidCallback onTap;

  const LogementCardCompact({
    super.key,
    required this.logement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Utilise Consumer pour mettre à jour le badge favori
    return Consumer<LogementViewModel>(
      builder: (context, viewModel, child) {
        final isFavori = viewModel.isFavorite(logement.id);
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              leading: logement.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logement.images.first,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logement.adresse,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${logement.prix} CFA',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: logement.disponible
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          logement.disponible ? 'Disponible' : 'Occupé',
                          style: TextStyle(
                            fontSize: 10,
                            color: logement.disponible ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      // ✅ Badge favori mis à jour dynamiquement
                      if (isFavori) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite, size: 14, color: Colors.red),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/logement_model.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../../utils/contact_service.dart';
// import '../../views/logement/details_bottom_sheet.dart';
// class LogementCard extends StatelessWidget {
//   final Logement logement;
//   final VoidCallback onTap;
//   final bool showOwnerInfo;
//   final bool showActions;

//   const LogementCard({
//     super.key,
//     required this.logement,
//     required this.onTap,
//     this.showOwnerInfo = false,
//     this.showActions = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         //onTap: onTap,
//         onTap: () {
//           // ✅ MODIFIE ICI : Utilise showLogementDetails au lieu de onTap direct
//           showLogementDetails(context, logement);
//         },
        
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image du logement
//             _buildImageSection(),
            
//             // Informations principales
//             _buildInfoSection(),
            
//             // Actions supplémentaires (si activé)
//             if (showActions) _buildActionsSection(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//           ),
//           child: logement.images.isNotEmpty
//               ? Image.network(
//                   logement.images.first,
//                   height: 180,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 180,
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 180,
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: Icon(
//                           Icons.home,
//                           size: 60,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     );
//                   },
//                 )
//               : Container(
//                   height: 180,
//                   color: Colors.grey.shade200,
//                   child: const Center(
//                     child: Icon(
//                       Icons.home,
//                       size: 60,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//         ),
        
//         // Badge de disponibilité
//         Positioned(
//           top: 12,
//           right: 12,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: logement.disponible 
//                   ? Colors.green.withOpacity(0.9)
//                   : Colors.red.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               logement.disponible ? 'Disponible' : 'Occupé',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
        
//         // Badge prix
//         Positioned(
//           bottom: 12,
//           left: 12,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${logement.prix} CFA/mois',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
        
//         // Badge favori
//         if (logement.isFavori)
//           Positioned(
//             top: 12,
//             left: 12,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.favorite, size: 14, color: Colors.white),
//                   SizedBox(width: 4),
//                   Text(
//                     'Favori',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Titre
//           Text(
//             logement.titre,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
          
//           const SizedBox(height: 8),
          
//           // Description
//           if (logement.description.isNotEmpty)
//             Column(
//               children: [
//                 Text(
//                   logement.description,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
          
//           // Adresse
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on,
//                 size: 16,
//                 color: Colors.grey.shade600,
//               ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   logement.adresse,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 12),
          
//           // Caractéristiques
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildFeatureItem(
//                 icon: Icons.aspect_ratio,
//                 text: '${logement.superficie} m²',
//               ),
//               _buildFeatureItem(
//                 icon: Icons.bed,
//                 text: '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
//               ),
//               _buildFeatureItem(
//                 icon: Icons.photo_library,
//                 text: '${logement.images.length} photo${logement.images.length > 1 ? 's' : ''}',
//               ),
//             ],
//           ),
          
//           // Informations propriétaire (si activé)
//           if (showOwnerInfo) ...[
//             const SizedBox(height: 12),
//             const Divider(height: 1),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Propriétaire',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         logement.proprietaireNom,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.message),
//                   onPressed: () {
//                     // Cette fonctionnalité est maintenant dans le bouton Contact
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem({required IconData icon, required String text}) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: Colors.blue,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionsSection(BuildContext context) {
//     final logementVM = Provider.of<LogementViewModel>(context, listen: false);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Bouton favori
//           TextButton.icon(
//             onPressed: () {
//               logementVM.toggleFavori(logement.id);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     logement.isFavori 
//                       ? 'Retiré des favoris' 
//                       : 'Ajouté aux favoris',
//                   ),
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//             icon: Icon(
//               logement.isFavori ? Icons.favorite : Icons.favorite_border,
//               size: 18,
//               color: logement.isFavori ? Colors.red : null,
//             ),
//             label: Text(
//               logement.isFavori ? 'Favori' : 'Favori',
//               style: TextStyle(
//                 color: logement.isFavori ? Colors.red : null,
//               ),
//             ),
//           ),
          
//           // Bouton partager
//           TextButton.icon(
//             onPressed: () {
//               _partagerLogement(context);
//             },
//             icon: const Icon(
//               Icons.share,
//               size: 18,
//             ),
//             label: const Text('Partager'),
//           ),
          
//           // Bouton contact
//           ElevatedButton.icon(
//             onPressed: () {
//               _contacterProprietaire(context);
//             },
//             icon: const Icon(Icons.message, size: 16),
//             label: const Text('Contacter'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Méthode pour contacter le propriétaire
//   void _contacterProprietaire(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Contacter le propriétaire',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 logement.proprietaireNom,
//                 style: const TextStyle(fontSize: 16),
//               ),
//               Text(
//                 logement.proprietaireNumero,
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 20),
              
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Bouton Appeler
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         try {
//                           await ContactService.appeler(logement.proprietaireNumero);
//                         } catch (e) {
//                           if (!context.mounted) return;
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Erreur: $e'),
//                               duration: const Duration(seconds: 3),
//                             ),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.phone, color: Colors.green),
//                       label: const Text('Appeler'),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
                  
//                   // Bouton SMS
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () async {
//                         Navigator.pop(context);
//                         try {
//                           await ContactService.envoyerSMS(
//                             logement.proprietaireNumero,
//                             'Bonjour ${logement.proprietaireNom}, je suis intéressé par votre logement "${logement.titre}" situé à ${logement.adresse}.',
//                           );
//                         } catch (e) {
//                           if (!context.mounted) return;
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Erreur: $e'),
//                               duration: const Duration(seconds: 3),
//                             ),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.sms, color: Colors.blue),
//                       label: const Text('SMS'),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 10),
              
//               // Bouton WhatsApp (optionnel)
//               ElevatedButton.icon(
//                 onPressed: () {
//                   if (!context.mounted) return;
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('WhatsApp bientôt disponible'),
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.chat, color: Colors.white),
//                 label: const Text('WhatsApp'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Méthode pour partager le logement
//   void _partagerLogement(BuildContext context) async {
//     try {
//       await ContactService.partagerLogement(
//         titre: logement.titre,
//         description: logement.description,
//         prix: logement.prix,
//         adresse: logement.adresse,
//         imageUrl: logement.images.isNotEmpty ? logement.images.first : null,
//       );
//     } catch (e) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur lors du partage: $e'),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }

// // Variante compacte pour les listes denses
// class LogementCardCompact extends StatelessWidget {
//   final Logement logement;
//   final VoidCallback onTap;

//   const LogementCardCompact({
//     super.key,
//     required this.logement,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.only(bottom: 8),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: ListTile(
//           leading: logement.images.isNotEmpty
//               ? ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     logement.images.first,
//                     width: 60,
//                     height: 60,
//                     fit: BoxFit.cover,
//                   ),
//                 )
//               : Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.home, color: Colors.grey),
//                 ),
//           title: Text(
//             logement.titre,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 logement.adresse,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//               const SizedBox(height: 2),
//               Row(
//                 children: [
//                   Text(
//                     '${logement.prix} CFA',
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: logement.disponible
//                           ? Colors.green.shade50
//                           : Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       logement.disponible ? 'Disponible' : 'Occupé',
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: logement.disponible ? Colors.green : Colors.red,
//                       ),
//                     ),
//                   ),
//                   if (logement.isFavori) ...[
//                     const SizedBox(width: 8),
//                     const Icon(Icons.favorite, size: 14, color: Colors.red),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//           trailing: const Icon(Icons.chevron_right),
//         ),
//       ),
//     );
//   }
// }









//=======================
// import 'package:flutter/material.dart';
// import '../../models/logement_model.dart';

// class LogementCard extends StatelessWidget {
//   final Logement logement;
//   final VoidCallback onTap;
//   final bool showOwnerInfo;
//   final bool showActions;

//   const LogementCard({
//     super.key,
//     required this.logement,
//     required this.onTap,
//     this.showOwnerInfo = false,
//     this.showActions = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image du logement
//             _buildImageSection(),
            
//             // Informations principales
//             _buildInfoSection(),
            
//             // Actions supplémentaires (si activé)
//             if (showActions) _buildActionsSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSection() {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//           ),
//           child: logement.images.isNotEmpty
//               ? Image.network(
//                   logement.images.first,
//                   height: 180,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 180,
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 180,
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: Icon(
//                           Icons.home,
//                           size: 60,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     );
//                   },
//                 )
//               : Container(
//                   height: 180,
//                   color: Colors.grey.shade200,
//                   child: const Center(
//                     child: Icon(
//                       Icons.home,
//                       size: 60,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//         ),
        
//         // Badge de disponibilité
//         Positioned(
//           top: 12,
//           right: 12,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: logement.disponible 
//                   ? Colors.green.withOpacity(0.9)
//                   : Colors.red.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               logement.disponible ? 'Disponible' : 'Occupé',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
        
//         // Badge prix
//         Positioned(
//           bottom: 12,
//           left: 12,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '${logement.prix} CFA/mois',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Titre
//           Text(
//             logement.titre,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
          
//           const SizedBox(height: 8),
          
//           // Description
//           if (logement.description.isNotEmpty)
//             Column(
//               children: [
//                 Text(
//                   logement.description,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade700,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
          
//           // Adresse
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on,
//                 size: 16,
//                 color: Colors.grey.shade600,
//               ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   logement.adresse,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 12),
          
//           // Caractéristiques
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildFeatureItem(
//                 icon: Icons.aspect_ratio,
//                 text: '${logement.superficie} m²',
//               ),
//               _buildFeatureItem(
//                 icon: Icons.bed,
//                 text: '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
//               ),
//               _buildFeatureItem(
//                 icon: Icons.photo_library,
//                 text: '${logement.images.length} photo${logement.images.length > 1 ? 's' : ''}',
//               ),
//             ],
//           ),
          
//           // Informations propriétaire (si activé)
//           if (showOwnerInfo) ...[
//             const SizedBox(height: 12),
//             const Divider(height: 1),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Propriétaire',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         'Contact disponible',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.message),
//                   onPressed: () {
//                     // TODO: Ouvrir la messagerie avec le propriétaire
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem({required IconData icon, required String text}) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: Colors.blue,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionsSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Bouton favori
//           TextButton.icon(
//             onPressed: () {
//               // TODO: Ajouter aux favoris
//             },
//             icon: const Icon(
//               Icons.favorite_border,
//               size: 18,
//             ),
//             label: const Text('Favori'),
//           ),
          
//           // Bouton partager
//           TextButton.icon(
//             onPressed: () {
//               // TODO: Partager le logement
//             },
//             icon: const Icon(
//               Icons.share,
//               size: 18,
//             ),
//             label: const Text('Partager'),
//           ),
          
//           // Bouton contact
//           ElevatedButton.icon(
//             onPressed: onTap,
//             icon: const Icon(Icons.message, size: 16),
//             label: const Text('Contacter'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Variante compacte pour les listes denses
// class LogementCardCompact extends StatelessWidget {
//   final Logement logement;
//   final VoidCallback onTap;

//   const LogementCardCompact({
//     super.key,
//     required this.logement,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: logement.images.isNotEmpty
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   logement.images.first,
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.home, color: Colors.grey),
//               ),
//         title: Text(
//           logement.titre,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               logement.adresse,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 2),
//             Row(
//               children: [
//                 Text(
//                   '${logement.prix} CFA',
//                   style: const TextStyle(
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: logement.disponible
//                         ? Colors.green.shade50
//                         : Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     logement.disponible ? 'Disponible' : 'Occupé',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: logement.disponible ? Colors.green : Colors.red,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: onTap,
//       ),
//     );
//   }
// }

