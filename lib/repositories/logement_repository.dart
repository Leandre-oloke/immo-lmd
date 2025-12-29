

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/logement_model.dart';

class LogementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Récupérer tous les logements
  Stream<List<Logement>> getAllLogements() {
    return _firestore
        .collection('logements')
        .where('disponible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Logement.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }
  
  // Récupérer les logements d'un propriétaire
  Stream<List<Logement>> getLogementsByOwner(String ownerId) {
    return _firestore
        .collection('logements')
        .where('proprietaireId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Logement.fromMap(doc.data()..['id'] = doc.id))
            .toList());
  }
  
  // Ajouter un logement
  Future<void> addLogement(Logement logement) async {
    await _firestore.collection('logements').doc(logement.id).set(logement.toMap());
  }
  
  // Mettre à jour un logement
  Future<void> updateLogement(Logement logement) async {
    await _firestore.collection('logements').doc(logement.id).update(logement.toMap());
  }
  
  // Supprimer un logement
  Future<void> deleteLogement(String logementId) async {
    await _firestore.collection('logements').doc(logementId).delete();
  }
}

