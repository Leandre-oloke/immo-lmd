import 'package:flutter/foundation.dart';

class Logement {
  String id;
  String titre;
  String description;
  String adresse;
  double prix;
  int superficie;
  int nombreChambres;
  List<String> images; // ✅ CHANGÉ de 'photos' à 'images'
  String proprietaireId;
  String proprietaireNom; 
  String proprietaireNumero;
  bool disponible;
  bool isFavori;
  DateTime datePublication;
  
  Logement({
    required this.id,
    required this.titre,
    required this.description,
    required this.adresse,
    required this.prix,
    required this.superficie,
    required this.nombreChambres,
    this.images = const [], // ✅ CHANGÉ
    required this.proprietaireId,
    required this.proprietaireNom,
    required this.proprietaireNumero,
    this.disponible = true,
    this.isFavori = false,
    required this.datePublication,
  });
  
  factory Logement.fromMap(Map<String, dynamic> data) {
    return Logement(
      id: data['id'] ?? '',
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      adresse: data['adresse'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      superficie: data['superficie'] ?? 0,
      nombreChambres: data['nombreChambres'] ?? 0,
      images: List<String>.from(data['images'] ?? []), // ✅ CHANGÉ
      proprietaireId: data['proprietaireId'] ?? '',
      proprietaireNom: data['proprietaireNom'] ?? '',
      proprietaireNumero: data['proprietaireNumero'] ?? '',
      disponible: data['disponible'] ?? true,
      isFavori: data['isFavori'] ?? false, // ✅ Récupère depuis Firestore
      datePublication: data['datePublication'] != null
          ? DateTime.parse(data['datePublication'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'adresse': adresse,
      'prix': prix,
      'superficie': superficie,
      'nombreChambres': nombreChambres,
      'images': images, // ✅ CHANGÉ
      'proprietaireId': proprietaireId,
      'proprietaireNom': proprietaireNom,
      'proprietaireNumero': proprietaireNumero,
      'disponible': disponible,
      'isFavori': isFavori, // ✅ Sauvegarde dans Firestore
      'datePublication': datePublication.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Logement(id: $id, titre: $titre, propriétaire: $proprietaireNom, numéro: $proprietaireNumero, prix: $prix€)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Logement &&
        other.id == id &&
        other.titre == titre &&
        other.description == description &&
        other.adresse == adresse &&
        other.prix == prix &&
        other.superficie == superficie &&
        other.nombreChambres == nombreChambres &&
        listEquals(other.images, images) && // ✅ CHANGÉ
        other.proprietaireId == proprietaireId &&
        other.proprietaireNom == proprietaireNom &&
        other.proprietaireNumero == proprietaireNumero &&
        other.disponible == disponible &&
        other.isFavori == isFavori && // ✅ CHANGÉ en ajoutant isFavori
        other.datePublication == datePublication;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      titre,
      description,
      adresse,
      prix,
      superficie,
      nombreChambres,
      Object.hashAll(images), // ✅ CHANGÉ
      proprietaireId,
      proprietaireNom,
      proprietaireNumero,
      disponible,
      isFavori, // ✅ CHANGÉ en ajoutant isFavori
      datePublication,
    );
  }
}

extension LogementCopyWith on Logement {
  Logement copyWith({
    String? id,
    String? titre,
    String? description,
    String? adresse,
    double? prix,
    int? superficie,
    int? nombreChambres,
    List<String>? images, // ✅ CHANGÉ
    String? proprietaireId,
    String? proprietaireNom,
    String? proprietaireNumero,
    bool? disponible,
    bool? isFavori, // ✅ CHANGÉ en ajoutant isFavori
    DateTime? datePublication,
  }) {
    return Logement(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      adresse: adresse ?? this.adresse,
      prix: prix ?? this.prix,
      superficie: superficie ?? this.superficie,
      nombreChambres: nombreChambres ?? this.nombreChambres,
      images: images ?? this.images, // ✅ CHANGÉ
      proprietaireId: proprietaireId ?? this.proprietaireId,
      proprietaireNom: proprietaireNom ?? this.proprietaireNom,
      proprietaireNumero: proprietaireNumero ?? this.proprietaireNumero,
      disponible: disponible ?? this.disponible,
      isFavori: isFavori ?? this.isFavori, // ✅ CHANGÉ en ajoutant isFavori
      datePublication: datePublication ?? this.datePublication,
    );
  }
}









// import 'package:flutter/foundation.dart';

// class Logement {
//   String id;
//   String titre;
//   String description;
//   String adresse;
//   double prix;
//   int superficie;
//   int nombreChambres;
//   List<String> images;
//   String proprietaireId;
//   String proprietaireNom; // AJOUTEZ CETTE LIGNE
//   bool disponible;
//   DateTime datePublication;
//   //final List<String> images; // <-- Ajout des images
  
//   Logement({
//     required this.id,
//     required this.titre,
//     required this.description,
//     required this.adresse,
//     required this.prix,
//     required this.superficie,
//     required this.nombreChambres,
//     this.images = const [],
//     required this.proprietaireId,
//     required this.proprietaireNom, // AJOUTEZ CETTE LIGNE
//     this.disponible = true,
//     required this.datePublication,
//   });
  
//   factory Logement.fromMap(Map<String, dynamic> data) {
//     return Logement(
//       id: data['id'] ?? '',
//       titre: data['titre'] ?? '',
//       description: data['description'] ?? '',
//       adresse: data['adresse'] ?? '',
//       prix: (data['prix'] ?? 0).toDouble(),
//       superficie: data['superficie'] ?? 0,
//       nombreChambres: data['nombreChambres'] ?? 0,
//       images: List<String>.from(data['images'] ?? []),
//       proprietaireId: data['proprietaireId'] ?? '',
//       proprietaireNom: data['proprietaireNom'] ?? '', // AJOUTEZ CETTE LIGNE
//       disponible: data['disponible'] ?? true,
//       datePublication: data['datePublication'] != null
//           ? DateTime.parse(data['datePublication'])
//           : DateTime.now(),
//     );
//   }
  
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'titre': titre,
//       'description': description,
//       'adresse': adresse,
//       'prix': prix,
//       'superficie': superficie,
//       'nombreChambres': nombreChambres,
//       'images': images,
//       'proprietaireId': proprietaireId,
//       'proprietaireNom': proprietaireNom, // AJOUTEZ CETTE LIGNE
//       'disponible': disponible,
//       'datePublication': datePublication.toIso8601String(),
//     };
//   }

//   @override
//   String toString() {
//     return 'Logement(id: $id, titre: $titre, propriétaire: $proprietaireNom, prix: $prix€)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
    
//     return other is Logement &&
//         other.id == id &&
//         other.titre == titre &&
//         other.description == description &&
//         other.adresse == adresse &&
//         other.prix == prix &&
//         other.superficie == superficie &&
//         other.nombreChambres == nombreChambres &&
//         listEquals(other.images, images) &&
//         other.proprietaireId == proprietaireId &&
//         other.proprietaireNom == proprietaireNom && // AJOUTEZ CETTE LIGNE
//         other.disponible == disponible &&
//         other.datePublication == datePublication;
//   }

//   @override
//   int get hashCode {
//     return Object.hash(
//       id,
//       titre,
//       description,
//       adresse,
//       prix,
//       superficie,
//       nombreChambres,
//       Object.hashAll(images),
//       proprietaireId,
//       proprietaireNom, // AJOUTEZ CETTE LIGNE
//       disponible,
//       datePublication,
//     );
//   }
// }

// extension LogementCopyWith on Logement {
//   Logement copyWith({
//     String? id,
//     String? titre,
//     String? description,
//     String? adresse,
//     double? prix,
//     int? superficie,
//     int? nombreChambres,
//     List<String>? images, // photos -> images
//     String? proprietaireId,
//     String? proprietaireNom, // AJOUTEZ CETTE LIGNE
//     bool? disponible,
//     DateTime? datePublication,
//   }) {
//     return Logement(
//       id: id ?? this.id,
//       titre: titre ?? this.titre,
//       description: description ?? this.description,
//       adresse: adresse ?? this.adresse,
//       prix: prix ?? this.prix,
//       superficie: superficie ?? this.superficie,
//       nombreChambres: nombreChambres ?? this.nombreChambres,
//       images: images ?? this.images,
//       proprietaireId: proprietaireId ?? this.proprietaireId,
//       proprietaireNom: proprietaireNom ?? this.proprietaireNom, // AJOUTEZ CETTE LIGNE
//       disponible: disponible ?? this.disponible,
//       datePublication: datePublication ?? this.datePublication,
//     );
//   }
// }




// //================================

