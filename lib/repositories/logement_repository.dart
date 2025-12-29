//import '../models/logement_model.dart';

/// Repository pour gérer les logements
//class LogementRepository {
  // TODO: Remplacer par récupération réelle depuis Firebase ou API

  /// Récupère la liste des logements (simulation)
 // Future<List<LogementModel>> fetchLogements() async {
  //   await Future.delayed(const Duration(seconds: 1)); // Simule un délai réseau

    //return const [
    //   LogementModel(
    //     id: '1',
    //     titre: 'Appartement à Cotonou',
    //     prix: 150000,
    //     imageUrl: 'https://via.placeholder.com/150',
    //     description: 'Appartement moderne à Cotonou',
    //     adresse: 'Cotonou, Bénin',

    //   ),
    //   LogementModel(
    //     id: '2',
    //     titre: 'Maison à Porto-Novo',
    //     prix: 250000,
    //     imageUrl: 'https://via.placeholder.com/150',
    //     description: 'Belle maison à Porto-Novo',
    //     adresse: 'Porto-Novo, Bénin',
    //   ),
    // ];
  //}
//}

// import '../models/logement_model.dart';

// class LogementRepository {
//   List<LogementModel> _logements = [];

//   Future<List<LogementModel>> fetchLogements() async {
//     await Future.delayed(Duration(seconds: 1));
//     return _logements;
//   }

//   Future<void> addLogement(LogementModel logement) async {
//     await Future.delayed(Duration(milliseconds: 500));
//     _logements.add(logement);
//   }
// }


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

