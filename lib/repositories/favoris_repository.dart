import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favori_model.dart';
import '../models/logement_model.dart';

class FavorisRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _collectionName => 'favoris';
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // ✅ Ajouter un logement aux favoris (sans modifier la collection logements)
  Future<void> ajouterFavori(String logementId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    final favoriId = '${userId}_$logementId';
    
    await _firestore.collection(_collectionName).doc(favoriId).set({
      'id': favoriId,
      'userId': userId,
      'logementId': logementId,
      'dateAjout': Timestamp.now(),
    });
    
    print('✅ Favori ajouté: $logementId');
  }
  
  // ✅ Retirer un logement des favoris
  Future<void> retirerFavori(String logementId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');
    
    final favoriId = '${userId}_$logementId';
    await _firestore.collection(_collectionName).doc(favoriId).delete();
    
    print('✅ Favori retiré: $logementId');
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
    final userId = _currentUserId;
    if (userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('dateAjout', descending: true)
          .get();
      
      if (querySnapshot.docs.isEmpty) return [];
      
      final logementIds = querySnapshot.docs
          .map((doc) => doc.data()['logementId'] as String)
          .toList();
      
      // Firestore limite à 10 éléments dans whereIn, donc on divise si nécessaire
      List<Logement> logements = [];
      
      for (int i = 0; i < logementIds.length; i += 10) {
        final batch = logementIds.skip(i).take(10).toList();
        
        final logementsSnapshot = await _firestore
            .collection('logements')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        logements.addAll(
          logementsSnapshot.docs.map((doc) => Logement.fromMap({
            ...doc.data(),
            'id': doc.id,
            'isFavori': true, // Forcé à true car on est dans les favoris
          })).toList(),
        );
      }
      
      return logements;
      
    } catch (e) {
      print('❌ Erreur récupération favoris: $e');
      rethrow;
    }
  }
  
  // ✅ Toggle favori
  Future<void> toggleFavori(String logementId, bool isCurrentlyFavori) async {
    if (isCurrentlyFavori) {
      await retirerFavori(logementId);
    } else {
      await ajouterFavori(logementId);
    }
  }
  
  // ✅ Récupérer les IDs des favoris (utile pour vérifier rapidement)
  Future<Set<String>> getFavorisIds() async {
    final userId = _currentUserId;
    if (userId == null) return {};
    
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => doc.data()['logementId'] as String)
          .toSet();
    } catch (e) {
      print('❌ Erreur récupération IDs favoris: $e');
      return {};
    }
  }
}