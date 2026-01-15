import 'package:cloud_firestore/cloud_firestore.dart';

class Favori {
  String id;
  String userId;
  String logementId;
  DateTime dateAjout;
  
  Favori({
    required this.id,
    required this.userId,
    required this.logementId,
    required this.dateAjout,
  });
  
  factory Favori.fromMap(Map<String, dynamic> data) {
    return Favori(
      id: data['id'] ?? '',  // ✅ Virgule manquante ici
      userId: data['userId'] ?? '',
      logementId: data['logementId'] ?? '',
      dateAjout: (data['dateAjout'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'logementId': logementId,
      'dateAjout': Timestamp.fromDate(dateAjout),
    };
  }
}