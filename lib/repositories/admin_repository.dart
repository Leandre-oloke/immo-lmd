import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur_model.dart';
import '../models/logement_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Récupère le nombre total d'utilisateurs
  Future<int> getTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0; // Handle null case
    } catch (e) {
      print('Erreur getTotalUsers: $e');
      return 0;
    }
  }
  
  /// Récupère le nombre total de logements
  Future<int> getTotalLogements() async {
    try {
      final snapshot = await _firestore.collection('logements').count().get();
      return snapshot.count ?? 0; // Handle null case
    } catch (e) {
      print('Erreur getTotalLogements: $e');
      return 0;
    }
  }
  
  /// Récupère des statistiques détaillées
  Future<Map<String, dynamic>> getDetailedStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final logementsSnapshot = await _firestore.collection('logements').get();
      
      int totalOwners = 0;
      int totalAdmins = 0;
      int activeLogements = 0;
      int inactiveLogements = 0;
      
      // Compter les utilisateurs par rôle
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? 'user';
        
        if (role == 'owner') totalOwners++;
        if (role == 'admin') totalAdmins++;
      }
      
      // Compter les logements par statut
      for (var doc in logementsSnapshot.docs) {
        final data = doc.data();
        final disponible = data['disponible'] ?? true;
        
        if (disponible) {
          activeLogements++;
        } else {
          inactiveLogements++;
        }
      }
      
      return {
        'totalOwners': totalOwners,
        'totalAdmins': totalAdmins,
        'activeLogements': activeLogements,
        'inactiveLogements': inactiveLogements,
      };
    } catch (e) {
      print('Erreur getDetailedStatistics: $e');
      return {
        'totalOwners': 0,
        'totalAdmins': 0,
        'activeLogements': 0,
        'inactiveLogements': 0,
      };
    }
  }
  
  /// Récupère tous les utilisateurs
  Future<List<Utilisateur>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('dateCreation', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Utilisateur.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur getAllUsers: $e');
      return [];
    }
  }
  
  /// Récupère tous les logements
  Future<List<Logement>> getAllLogements() async {
    try {
      final snapshot = await _firestore
          .collection('logements')
          .orderBy('datePublication', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Logement.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur getAllLogements: $e');
      return [];
    }
  }
  
  /// Met à jour le rôle d'un utilisateur
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur updateUserRole: $e');
      return false;
    }
  }
  
  /// Supprime un utilisateur
  Future<bool> deleteUser(String userId) async {
    try {
      // Vérifier s'il n'y a pas de logements associés
      final userLogements = await _firestore
          .collection('logements')
          .where('proprietaireId', isEqualTo: userId)
          .get();
      
      if (userLogements.docs.isNotEmpty) {
        throw Exception('L\'utilisateur a des logements associés');
      }
      
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Erreur deleteUser: $e');
      return false;
    }
  }
  
  /// Supprime un logement
  Future<bool> deleteLogement(String logementId) async {
    try {
      await _firestore.collection('logements').doc(logementId).delete();
      return true;
    } catch (e) {
      print('Erreur deleteLogement: $e');
      return false;
    }
  }
  
  /// Met à jour le statut d'un logement
  Future<bool> updateLogementStatus(String logementId, bool isActive) async {
    try {
      await _firestore.collection('logements').doc(logementId).update({
        'disponible': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur updateLogementStatus: $e');
      return false;
    }
  }
  
  /// Récupère les activités récentes
  Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('dateCreation', descending: true)
          .limit(10)
          .get();
      
      final logementsSnapshot = await _firestore
          .collection('logements')
          .orderBy('datePublication', descending: true)
          .limit(10)
          .get();
      
      final recentUsers = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Utilisateur.fromMap(data);
      }).toList();
      
      final recentLogements = logementsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Logement.fromMap(data);
      }).toList();
      
      return {
        'recentUsers': recentUsers,
        'recentLogements': recentLogements,
        'lastActivity': DateTime.now(),
      };
    } catch (e) {
      print('Erreur getRecentActivities: $e');
      return {
        'recentUsers': [],
        'recentLogements': [],
        'lastActivity': DateTime.now(),
      };
    }
  }

  /// Récupère les utilisateurs par rôle
  Future<Map<String, int>> getUsersByRole() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      final Map<String, int> roleCounts = {
        'admin': 0,
        'owner': 0,
        'user': 0,
      };
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? 'user';
        roleCounts[role] = (roleCounts[role] ?? 0) + 1;
      }
      
      return roleCounts;
    } catch (e) {
      print('Erreur getUsersByRole: $e');
      return {
        'admin': 0,
        'owner': 0,
        'user': 0,
      };
    }
  }

  /// Récupère les logements par statut de disponibilité
  Future<Map<String, int>> getLogementsByAvailability() async {
    try {
      final activeSnapshot = await _firestore
          .collection('logements')
          .where('disponible', isEqualTo: true)
          .count()
          .get();
      
      final inactiveSnapshot = await _firestore
          .collection('logements')
          .where('disponible', isEqualTo: false)
          .count()
          .get();
      
      return {
        'active': activeSnapshot.count ?? 0,
        'inactive': inactiveSnapshot.count ?? 0,
      };
    } catch (e) {
      print('Erreur getLogementsByAvailability: $e');
      return {
        'active': 0,
        'inactive': 0,
      };
    }
  }

  /// Récupère les logements par tranche de prix
  Future<Map<String, int>> getLogementsByPriceRange() async {
    try {
      final snapshot = await _firestore.collection('logements').get();
      
      final Map<String, int> priceRanges = {
        '0-500': 0,
        '501-1000': 0,
        '1001-1500': 0,
        '1501+': 0,
      };
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final prix = (data['prix'] ?? 0).toDouble();
        
        if (prix <= 500) {
          priceRanges['0-500'] = priceRanges['0-500']! + 1;
        } else if (prix <= 1000) {
          priceRanges['501-1000'] = priceRanges['501-1000']! + 1;
        } else if (prix <= 1500) {
          priceRanges['1001-1500'] = priceRanges['1001-1500']! + 1;
        } else {
          priceRanges['1501+'] = priceRanges['1501+']! + 1;
        }
      }
      
      return priceRanges;
    } catch (e) {
      print('Erreur getLogementsByPriceRange: $e');
      return {
        '0-500': 0,
        '501-1000': 0,
        '1001-1500': 0,
        '1501+': 0,
      };
    }
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/utilisateur_model.dart';
// import '../models/logement_model.dart';

// class AdminRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   /// Récupère le nombre total d'utilisateurs
//   Future<int> getTotalUsers() async {
//     final snapshot = await _firestore.collection('users').count().get();
//     return snapshot.count;
//   }
  
//   /// Récupère le nombre total de logements
//   Future<int> getTotalLogements() async {
//     final snapshot = await _firestore.collection('logements').count().get();
//     return snapshot.count;
//   }
  
//   /// Récupère des statistiques détaillées
//   Future<Map<String, dynamic>> getDetailedStatistics() async {
//     final usersSnapshot = await _firestore.collection('users').get();
//     final logementsSnapshot = await _firestore.collection('logements').get();
    
//     int totalOwners = 0;
//     int totalAdmins = 0;
//     int activeLogements = 0;
//     int inactiveLogements = 0;
    
//     // Compter les utilisateurs par rôle
//     for (var doc in usersSnapshot.docs) {
//       final data = doc.data();
//       final role = data['role'] ?? 'user';
      
//       if (role == 'owner') totalOwners++;
//       if (role == 'admin') totalAdmins++;
//     }
    
//     // Compter les logements par statut
//     for (var doc in logementsSnapshot.docs) {
//       final data = doc.data();
//       final disponible = data['disponible'] ?? true;
      
//       if (disponible) {
//         activeLogements++;
//       } else {
//         inactiveLogements++;
//       }
//     }
    
//     return {
//       'totalOwners': totalOwners,
//       'totalAdmins': totalAdmins,
//       'activeLogements': activeLogements,
//       'inactiveLogements': inactiveLogements,
//     };
//   }
  
//   /// Récupère tous les utilisateurs
//   Future<List<Utilisateur>> getAllUsers() async {
//     final snapshot = await _firestore.collection('users').get();
    
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return Utilisateur.fromMap(data);
//     }).toList();
//   }
  
//   /// Récupère tous les logements
//   Future<List<Logement>> getAllLogements() async {
//     final snapshot = await _firestore.collection('logements').get();
    
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return Logement.fromMap(data);
//     }).toList();
//   }
  
//   /// Met à jour le rôle d'un utilisateur
//   Future<bool> updateUserRole(String userId, String newRole) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         'role': newRole,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
  
//   /// Supprime un utilisateur
//   Future<bool> deleteUser(String userId) async {
//     try {
//       // Vérifier s'il n'y a pas de logements associés
//       final userLogements = await _firestore
//           .collection('logements')
//           .where('proprietaireId', isEqualTo: userId)
//           .get();
      
//       if (userLogements.docs.isNotEmpty) {
//         throw Exception('L\'utilisateur a des logements associés');
//       }
      
//       await _firestore.collection('users').doc(userId).delete();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
  
//   /// Supprime un logement
//   Future<bool> deleteLogement(String logementId) async {
//     try {
//       await _firestore.collection('logements').doc(logementId).delete();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
  
//   /// Met à jour le statut d'un logement
//   Future<bool> updateLogementStatus(String logementId, bool isActive) async {
//     try {
//       await _firestore.collection('logements').doc(logementId).update({
//         'disponible': isActive,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
  
//   /// Récupère les activités récentes
//   Future<Map<String, dynamic>> getRecentActivities() async {
//     final usersSnapshot = await _firestore
//         .collection('users')
//         .orderBy('dateCreation', descending: true)
//         .limit(10)
//         .get();
    
//     final logementsSnapshot = await _firestore
//         .collection('logements')
//         .orderBy('datePublication', descending: true)
//         .limit(10)
//         .get();
    
//     final recentUsers = usersSnapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return Utilisateur.fromMap(data);
//     }).toList();
    
//     final recentLogements = logementsSnapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return Logement.fromMap(data);
//     }).toList();
    
//     return {
//       'recentUsers': recentUsers,
//       'recentLogements': recentLogements,
//       'lastActivity': DateTime.now(),
//     };
//   }
// }