import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/logement_model.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../components/logement_card.dart';
import 'details_bottom_sheet.dart';

class MesFavorisPage extends StatefulWidget {
  const MesFavorisPage({super.key});

  @override
  State<MesFavorisPage> createState() => _MesFavorisPageState();
}

class _MesFavorisPageState extends State<MesFavorisPage> {
  @override
  void initState() {
    super.initState();
    // ✅ Debug : Vérifier l'authentification
    _debugAuth();
    
    // Charger les favoris au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogementViewModel>().loadFavoris();
    });
  }

  // 🐛 Méthode de debug
  void _debugAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    print('════════════════════════════════');
    print('🔍 DEBUG AUTHENTIFICATION');
    print('════════════════════════════════');
    print('👤 User ID: ${user?.uid}');
    print('📧 Email: ${user?.email}');
    print('✅ Est connecté: ${user != null}');
    
    if (user != null) {
      // Vérifier le rôle
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        print('📄 Document user existe: ${userDoc.exists}');
        print('🎭 Rôle: ${userDoc.data()?['role']}');
        print('📋 Données: ${userDoc.data()}');
      } catch (e) {
        print('❌ Erreur lecture user: $e');
      }
      
      // Vérifier la collection favoris
      try {
        final favorisSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favoris')
            .get();
        
        print('💖 Nombre de favoris: ${favorisSnapshot.docs.length}');
        print('📝 IDs favoris: ${favorisSnapshot.docs.map((d) => d.id).toList()}');
      } catch (e) {
        print('❌ Erreur lecture favoris: $e');
      }
    } else {
      print('❌ AUCUN UTILISATEUR CONNECTÉ');
    }
    print('════════════════════════════════');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        actions: [
          Consumer<LogementViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.favoris.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  _showClearConfirmationDialog(context, viewModel);
                },
                tooltip: 'Vider les favoris',
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<LogementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingFavoris) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Chargement de vos favoris..."),
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
                    viewModel.loadFavoris();
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }

        if (viewModel.favoris.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Aucun favori",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Ajoutez des logements à vos favoris\npour les retrouver ici",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Parcourir les logements"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadFavoris();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.favoris.length,
            itemBuilder: (context, index) {
              final logement = viewModel.favoris[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LogementCard(
                  logement: logement,
                  onTap: () {
                    showLogementDetails(context, logement);
                  },
                  showOwnerInfo: true,
                  showActions: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showClearConfirmationDialog(
    BuildContext context,
    LogementViewModel viewModel,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Vider les favoris'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer tous vos favoris ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // ✅ Afficher un indicateur de chargement
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(width: 16),
                        Text('Suppression en cours...'),
                      ],
                    ),
                    duration: Duration(seconds: 30),
                  ),
                );
                
                try {
                  await viewModel.clearFavorites();
                  
                  if (!context.mounted) return;
                  
                  // ✅ Cacher le SnackBar de chargement
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
                  // Afficher confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tous les favoris ont été supprimés'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/logement_model.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../components/logement_card.dart';
// import 'details_bottom_sheet.dart';

// class MesFavorisPage extends StatefulWidget {
//   const MesFavorisPage({super.key});

//   @override
//   State<MesFavorisPage> createState() => _MesFavorisPageState();
// }

// class _MesFavorisPageState extends State<MesFavorisPage> {
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Debug : Vérifier l'authentification
//     _debugAuth();
    
//     // Charger les favoris au démarrage
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LogementViewModel>().loadFavoris();
//     });
//   }

//   // 🐛 Méthode de debug
//   void _debugAuth() async {
//     final user = FirebaseAuth.instance.currentUser;
//     print('════════════════════════════════');
//     print('🔍 DEBUG AUTHENTIFICATION');
//     print('════════════════════════════════');
//     print('👤 User ID: ${user?.uid}');
//     print('📧 Email: ${user?.email}');
//     print('✅ Est connecté: ${user != null}');
    
//     if (user != null) {
//       // Vérifier le rôle
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
        
//         print('📄 Document user existe: ${userDoc.exists}');
//         print('🎭 Rôle: ${userDoc.data()?['role']}');
//         print('📋 Données: ${userDoc.data()}');
//       } catch (e) {
//         print('❌ Erreur lecture user: $e');
//       }
      
//       // Vérifier la collection favoris
//       try {
//         final favorisSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('favoris')
//             .get();
        
//         print('💖 Nombre de favoris: ${favorisSnapshot.docs.length}');
//         print('📝 IDs favoris: ${favorisSnapshot.docs.map((d) => d.id).toList()}');
//       } catch (e) {
//         print('❌ Erreur lecture favoris: $e');
//       }
//     } else {
//       print('❌ AUCUN UTILISATEUR CONNECTÉ');
//     }
//     print('════════════════════════════════');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mes Favoris'),
//         actions: [
//           Consumer<LogementViewModel>(
//             builder: (context, viewModel, child) {
//               if (viewModel.favoris.isEmpty) return const SizedBox.shrink();
              
//               return IconButton(
//                 icon: const Icon(Icons.delete_sweep),
//                 onPressed: () {
//                   _showClearConfirmationDialog(context, viewModel);
//                 },
//                 tooltip: 'Vider les favoris',
//               );
//             },
//           ),
//         ],
//       ),
//       body: _buildBody(context),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Consumer<LogementViewModel>(
//       builder: (context, viewModel, child) {
//         if (viewModel.isLoadingFavoris) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text("Chargement de vos favoris..."),
//               ],
//             ),
//           );
//         }

//         if (viewModel.errorMessage != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Erreur de chargement",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     viewModel.errorMessage!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     viewModel.loadFavoris();
//                   },
//                   child: const Text("Réessayer"),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (viewModel.favoris.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Aucun favori",
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Ajoutez des logements à vos favoris\npour les retrouver ici",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.search),
//                   label: const Text("Parcourir les logements"),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () async {
//             await viewModel.loadFavoris();
//           },
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: viewModel.favoris.length,
//             itemBuilder: (context, index) {
//               final logement = viewModel.favoris[index];

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: LogementCard(
//                   logement: logement,
//                   onTap: () {
//                     showLogementDetails(context, logement);
//                   },
//                   showOwnerInfo: true,
//                   showActions: true,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _showClearConfirmationDialog(
//     BuildContext context,
//     LogementViewModel viewModel,
//   ) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Vider les favoris'),
//           content: const Text(
//             'Êtes-vous sûr de vouloir supprimer tous vos favoris ?',
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Annuler'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
                
//                 // ✅ Afficher un indicateur de chargement
//                 if (!context.mounted) return;
                
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Row(
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                         SizedBox(width: 16),
//                         Text('Suppression en cours...'),
//                       ],
//                     ),
//                     duration: Duration(seconds: 30),
//                   ),
//                 );
                
//                 try {
//                   await viewModel.clearFavorites();
                  
//                   if (!context.mounted) return;
                  
//                   // ✅ Cacher le SnackBar de chargement
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
//                   // Afficher confirmation
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Tous les favoris ont été supprimés'),
//                       backgroundColor: Colors.green,
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 } catch (e) {
//                   if (!context.mounted) return;
                  
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Erreur: $e'),
//                       backgroundColor: Colors.red,
//                       duration: const Duration(seconds: 3),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';






// import '../../models/logement_model.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import '../components/logement_card.dart';
// import 'details_bottom_sheet.dart';

// class MesFavorisPage extends StatefulWidget {
//   const MesFavorisPage({super.key});

//   @override
//   State<MesFavorisPage> createState() => _MesFavorisPageState();
// }

// class _MesFavorisPageState extends State<MesFavorisPage> {
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Charger les favoris au démarrage
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LogementViewModel>().loadFavoris();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mes Favoris'),
//         actions: [
//           Consumer<LogementViewModel>(
//             builder: (context, viewModel, child) {
//               if (viewModel.favoris.isEmpty) return const SizedBox.shrink();
              
//               return IconButton(
//                 icon: const Icon(Icons.delete_sweep),
//                 onPressed: () {
//                   _showClearConfirmationDialog(context, viewModel);
//                 },
//                 tooltip: 'Vider les favoris',
//               );
//             },
//           ),
//         ],
//       ),
//       body: _buildBody(context),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Consumer<LogementViewModel>(
//       builder: (context, viewModel, child) {
//         if (viewModel.isLoadingFavoris) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text("Chargement de vos favoris..."),
//               ],
//             ),
//           );
//         }

//         if (viewModel.errorMessage != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Erreur de chargement",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     viewModel.errorMessage!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     viewModel.loadFavoris();
//                   },
//                   child: const Text("Réessayer"),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (viewModel.favoris.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Aucun favori",
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Ajoutez des logements à vos favoris\npour les retrouver ici",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(Icons.search),
//                   label: const Text("Parcourir les logements"),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () async {
//             await viewModel.loadFavoris();
//           },
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: viewModel.favoris.length,
//             itemBuilder: (context, index) {
//               final logement = viewModel.favoris[index];

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: LogementCard(
//                   logement: logement,
//                   onTap: () {
//                     showLogementDetails(context, logement);
//                   },
//                   showOwnerInfo: true,
//                   showActions: true,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _showClearConfirmationDialog(
//     BuildContext context,
//     LogementViewModel viewModel,
//   ) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Vider les favoris'),
//           content: const Text(
//             'Êtes-vous sûr de vouloir supprimer tous vos favoris ?',
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Annuler'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
                
//                 // ✅ Afficher un indicateur de chargement
//                 if (!context.mounted) return;
                
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Row(
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                         SizedBox(width: 16),
//                         Text('Suppression en cours...'),
//                       ],
//                     ),
//                     duration: Duration(seconds: 30),
//                   ),
//                 );
                
//                 try {
//                   await viewModel.clearFavorites();
                  
//                   if (!context.mounted) return;
                  
//                   // ✅ Cacher le SnackBar de chargement
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
//                   // Afficher confirmation
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Tous les favoris ont été supprimés'),
//                       backgroundColor: Colors.green,
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 } catch (e) {
//                   if (!context.mounted) return;
                  
//                   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Erreur: $e'),
//                       backgroundColor: Colors.red,
//                       duration: const Duration(seconds: 3),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }