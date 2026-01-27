import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/logement_model.dart';

class FavorisRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _collectionName => 'favoris';
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // ✅ Ajouter un logement aux favoris
  Future<void> ajouterFavori(String logementId) async {
    print('═══════════════════════════════════════');
    print('➕ AJOUT FAVORI');
    print('═══════════════════════════════════════');
    
    final userId = _currentUserId;
    print('👤 User ID: $userId');
    print('🏠 Logement ID: $logementId');
    
    if (userId == null) {
      print('❌ Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }
    
    final favoriId = '${userId}_$logementId';
    print('🆔 Favori ID: $favoriId');
    print('📍 Chemin: favoris/$favoriId');
    
    try {
      final data = {
        'id': favoriId,
        'userId': userId,
        'logementId': logementId,
        'dateAjout': Timestamp.now(),
      };
      
      print('📝 Données à écrire: $data');
      
      await _firestore.collection(_collectionName).doc(favoriId).set(data);
      
      print('✅ Favori ajouté avec succès dans Firestore');
      
      // Vérification
      final doc = await _firestore.collection(_collectionName).doc(favoriId).get();
      print('✅ Vérification: Document existe = ${doc.exists}');
      if (doc.exists) {
        print('📊 Données sauvegardées: ${doc.data()}');
      }
      
    } catch (e) {
      print('❌ ERREUR lors de l\'ajout: $e');
      print('📍 Type erreur: ${e.runtimeType}');
      rethrow;
    }
    
    print('═══════════════════════════════════════');
  }
  
  // ✅ Retirer un logement des favoris
  Future<void> retirerFavori(String logementId) async {
    print('═══════════════════════════════════════');
    print('➖ RETRAIT FAVORI');
    print('═══════════════════════════════════════');
    
    final userId = _currentUserId;
    print('👤 User ID: $userId');
    print('🏠 Logement ID: $logementId');
    
    if (userId == null) {
      print('❌ Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }
    
    final favoriId = '${userId}_$logementId';
    print('🆔 Favori ID: $favoriId');
    
    try {
      await _firestore.collection(_collectionName).doc(favoriId).delete();
      print('✅ Favori retiré avec succès');
    } catch (e) {
      print('❌ ERREUR lors du retrait: $e');
      rethrow;
    }
    
    print('═══════════════════════════════════════');
  }
  
  // ✅ Vérifier si un logement est en favori
  Future<bool> estFavori(String logementId) async {
    final userId = _currentUserId;
    if (userId == null) return false;
    
    final favoriId = '${userId}_$logementId';
    final doc = await _firestore.collection(_collectionName).doc(favoriId).get();
    return doc.exists;
  }
  
  // ✅ Récupérer tous les favoris de l'utilisateur
  Future<List<Logement>> getFavoris() async {
    print('═══════════════════════════════════════');
    print('📥 GET FAVORIS');
    print('═══════════════════════════════════════');
    
    final userId = _currentUserId;
    print('👤 User ID: $userId');
    
    if (userId == null) {
      print('❌ Utilisateur non connecté');
      return [];
    }
    
    try {
      print('🔍 Requête: favoris WHERE userId == $userId');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('dateAjout', descending: true)
          .get();
      
      print('📊 Nombre de documents favoris: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('ℹ️ Aucun favori trouvé');
        return [];
      }
      
      // Afficher tous les favoris trouvés
      for (var doc in querySnapshot.docs) {
        print('💖 Favori: ${doc.id} = ${doc.data()}');
      }
      
      final logementIds = querySnapshot.docs
          .map((doc) => doc.data()['logementId'] as String)
          .toList();
      
      print('🏠 IDs logements à charger: $logementIds');
      
      // Firestore limite à 10 éléments dans whereIn
      List<Logement> logements = [];
      
      for (int i = 0; i < logementIds.length; i += 10) {
        final batch = logementIds.skip(i).take(10).toList();
        print('📦 Batch ${i ~/ 10 + 1}: $batch');
        
        final logementsSnapshot = await _firestore
            .collection('logements')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        print('📊 Logements trouvés pour ce batch: ${logementsSnapshot.docs.length}');
        
        for (var doc in logementsSnapshot.docs) {
          try {
            print('🏠 Chargement logement: ${doc.id}');
            final data = doc.data();
            final logement = Logement.fromMap({
              ...data,
              'id': doc.id,
              'isFavori': true,
            });
            logements.add(logement);
            print('✅ Logement ajouté: ${logement.titre}');
          } catch (e) {
            print('❌ Erreur parsing logement ${doc.id}: $e');
          }
        }
      }
      
      print('✅ Total logements favoris chargés: ${logements.length}');
      print('═══════════════════════════════════════');
      
      return logements;
      
    } catch (e) {
      print('❌ ERREUR getFavoris: $e');
      print('📍 Type erreur: ${e.runtimeType}');
      print('═══════════════════════════════════════');
      rethrow;
    }
  }
  
  // ✅ Toggle favori
  Future<void> toggleFavori(String logementId, bool isCurrentlyFavori) async {
    print('🔄 Toggle: ${isCurrentlyFavori ? "RETIRER" : "AJOUTER"}');
    if (isCurrentlyFavori) {
      await retirerFavori(logementId);
    } else {
      await ajouterFavori(logementId);
    }
  }
  
  // ✅ Récupérer les IDs des favoris
  Future<Set<String>> getFavorisIds() async {
    print('═══════════════════════════════════════');
    print('🆔 GET FAVORIS IDS');
    print('═══════════════════════════════════════');
    
    final userId = _currentUserId;
    print('👤 User ID: $userId');
    
    if (userId == null) {
      print('❌ Utilisateur non connecté');
      return {};
    }
    
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      print('📊 Nombre de favoris: ${querySnapshot.docs.length}');
      
      final ids = querySnapshot.docs
          .map((doc) => doc.data()['logementId'] as String)
          .toSet();
      
      print('🆔 IDs: $ids');
      print('═══════════════════════════════════════');
      
      return ids;
    } catch (e) {
      print('❌ Erreur getFavorisIds: $e');
      print('═══════════════════════════════════════');
      return {};
    }
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/logement_model.dart';

// class FavorisRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   String? get _currentUserId => _auth.currentUser?.uid;
  
//   // ✅ Référence à la sous-collection favoris de l'utilisateur
//   CollectionReference _getFavorisCollection() {
//     final userId = _currentUserId;
//     if (userId == null) {
//       throw Exception('Utilisateur non connecté');
//     }
//     return _firestore.collection('users').doc(userId).collection('favoris');
//   }
  
//   // ✅ Ajouter un logement aux favoris
//   Future<void> ajouterFavori(String logementId) async {
//     try {
//       await _getFavorisCollection().doc(logementId).set({
//         'logementId': logementId,
//         'userId': _currentUserId,
//         'dateAjout': FieldValue.serverTimestamp(),
//       });
      
//       print('✅ Favori ajouté: $logementId');
//     } catch (e) {
//       print('❌ Erreur ajout favori: $e');
//       rethrow;
//     }
//   }
  
//   // ✅ Retirer un logement des favoris
//   Future<void> retirerFavori(String logementId) async {
//     try {
//       await _getFavorisCollection().doc(logementId).delete();
//       print('✅ Favori retiré: $logementId');
//     } catch (e) {
//       print('❌ Erreur retrait favori: $e');
//       rethrow;
//     }
//   }
  
//   // ✅ Vérifier si un logement est en favori
//   Future<bool> estFavori(String logementId) async {
//     try {
//       final doc = await _getFavorisCollection().doc(logementId).get();
//       return doc.exists;
//     } catch (e) {
//       print('❌ Erreur vérification favori: $e');
//       return false;
//     }
//   }
  
//   // ✅ Récupérer tous les favoris de l'utilisateur
//   Future<List<Logement>> getFavoris() async {
//     try {
//       final userId = _currentUserId;
//       if (userId == null) {
//         throw Exception('Utilisateur non connecté');
//       }
      
//       print('🔍 Chargement favoris pour user: $userId');
      
//       // 1. Récupérer les IDs des favoris
//       final favorisSnapshot = await _getFavorisCollection()
//           .orderBy('dateAjout', descending: true)
//           .get();
      
//       print('📊 ${favorisSnapshot.docs.length} favoris trouvés');
      
//       if (favorisSnapshot.docs.isEmpty) {
//         return [];
//       }
      
//       final logementIds = favorisSnapshot.docs.map((doc) => doc.id).toList();
//       print('📝 IDs: $logementIds');
      
//       // 2. Récupérer les logements (par batch de 10 car whereIn limite à 10)
//       List<Logement> logements = [];
      
//       for (int i = 0; i < logementIds.length; i += 10) {
//         final batch = logementIds.skip(i).take(10).toList();
        
//         final logementsSnapshot = await _firestore
//             .collection('logements')
//             .where(FieldPath.documentId, whereIn: batch)
//             .get();
        
//         for (var doc in logementsSnapshot.docs) {
//           try {
//             // ✅ Utiliser fromMap au lieu de fromFirestore
//             final data = doc.data() as Map<String, dynamic>;
//             final logement = Logement.fromMap({
//               ...data,
//               'id': doc.id,
//             });
//             logements.add(logement.copyWith(isFavori: true));
//           } catch (e) {
//             print('❌ Erreur parsing logement ${doc.id}: $e');
//           }
//         }
//       }
      
//       print('✅ ${logements.length} logements favoris chargés');
//       return logements;
      
//     } catch (e) {
//       print('❌ Erreur getFavoris: $e');
//       rethrow;
//     }
//   }
  
//   // ✅ Toggle favori
//   Future<void> toggleFavori(String logementId, bool isCurrentlyFavori) async {
//     if (isCurrentlyFavori) {
//       await retirerFavori(logementId);
//     } else {
//       await ajouterFavori(logementId);
//     }
//   }
  
//   // ✅ Récupérer les IDs des favoris
//   Future<Set<String>> getFavorisIds() async {
//     try {
//       if (_currentUserId == null) return {};
      
//       final snapshot = await _getFavorisCollection().get();
//       return snapshot.docs.map((doc) => doc.id).toSet();
      
//     } catch (e) {
//       print('❌ Erreur getFavorisIds: $e');
//       return {};
//     }
//   }
  
//   // ✅ Stream des favoris (temps réel)
//   Stream<List<String>> streamFavorisIds() {
//     if (_currentUserId == null) {
//       return Stream.value([]);
//     }
    
//     return _getFavorisCollection().snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => doc.id).toList();
//     });
//   }
// }





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/favori_model.dart';
// import '../models/logement_model.dart';

// class FavorisRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   String get _collectionName => 'favoris';
//   String? get _currentUserId => _auth.currentUser?.uid;
  
//   // ✅ Ajouter un logement aux favoris (sans modifier la collection logements)
//   Future<void> ajouterFavori(String logementId) async {
//     final userId = _currentUserId;
//     if (userId == null) throw Exception('Utilisateur non connecté');
    
//     final favoriId = '${userId}_$logementId';
    
//     await _firestore.collection(_collectionName).doc(favoriId).set({
//       'id': favoriId,
//       'userId': userId,
//       'logementId': logementId,
//       'dateAjout': Timestamp.now(),
//     });
    
//     print('✅ Favori ajouté: $logementId');
//   }
  
//   // ✅ Retirer un logement des favoris
//   Future<void> retirerFavori(String logementId) async {
//     final userId = _currentUserId;
//     if (userId == null) throw Exception('Utilisateur non connecté');
    
//     final favoriId = '${userId}_$logementId';
//     await _firestore.collection(_collectionName).doc(favoriId).delete();
    
//     print('✅ Favori retiré: $logementId');
//   }
  
//   // ✅ Vérifier si un logement est en favori
//   Future<bool> estFavori(String logementId) async {
//     final userId = _currentUserId;
//     if (userId == null) return false;
    
//     final favoriId = '${userId}_$logementId';
//     final doc = await _firestore.collection(_collectionName).doc(favoriId).get();
//     return doc.exists;
//   }
  
//   // ✅ Récupérer tous les favoris de l'utilisateur
//   Future<List<Logement>> getFavoris() async {
//     final userId = _currentUserId;
//     if (userId == null) return [];
    
//     try {
//       final querySnapshot = await _firestore
//           .collection(_collectionName)
//           .where('userId', isEqualTo: userId)
//           .orderBy('dateAjout', descending: true)
//           .get();
      
//       if (querySnapshot.docs.isEmpty) return [];
      
//       final logementIds = querySnapshot.docs
//           .map((doc) => doc.data()['logementId'] as String)
//           .toList();
      
//       // Firestore limite à 10 éléments dans whereIn, donc on divise si nécessaire
//       List<Logement> logements = [];
      
//       for (int i = 0; i < logementIds.length; i += 10) {
//         final batch = logementIds.skip(i).take(10).toList();
        
//         final logementsSnapshot = await _firestore
//             .collection('logements')
//             .where(FieldPath.documentId, whereIn: batch)
//             .get();
        
//         logements.addAll(
//           logementsSnapshot.docs.map((doc) => Logement.fromMap({
//             ...doc.data(),
//             'id': doc.id,
//             'isFavori': true, // Forcé à true car on est dans les favoris
//           })).toList(),
//         );
//       }
      
//       return logements;
      
//     } catch (e) {
//       print('❌ Erreur récupération favoris: $e');
//       rethrow;
//     }
//   }
  
//   // ✅ Toggle favori
//   Future<void> toggleFavori(String logementId, bool isCurrentlyFavori) async {
//     if (isCurrentlyFavori) {
//       await retirerFavori(logementId);
//     } else {
//       await ajouterFavori(logementId);
//     }
//   }
  
//   // ✅ Récupérer les IDs des favoris (utile pour vérifier rapidement)
//   Future<Set<String>> getFavorisIds() async {
//     final userId = _currentUserId;
//     if (userId == null) return {};
    
//     try {
//       final querySnapshot = await _firestore
//           .collection(_collectionName)
//           .where('userId', isEqualTo: userId)
//           .get();
      
//       return querySnapshot.docs
//           .map((doc) => doc.data()['logementId'] as String)
//           .toSet();
//     } catch (e) {
//       print('❌ Erreur récupération IDs favoris: $e');
//       return {};
//     }
//   }
// }