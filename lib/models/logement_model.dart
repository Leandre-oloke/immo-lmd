import 'package:flutter/foundation.dart';

class Logement {
  String id;
  String titre;
  String description;
  String adresse;
  double prix;
  int superficie;
  int nombreChambres;
  List<String> photos;
  String proprietaireId;
  String proprietaireNom; // AJOUTEZ CETTE LIGNE
  bool disponible;
  DateTime datePublication;
  
  Logement({
    required this.id,
    required this.titre,
    required this.description,
    required this.adresse,
    required this.prix,
    required this.superficie,
    required this.nombreChambres,
    this.photos = const [],
    required this.proprietaireId,
    required this.proprietaireNom, // AJOUTEZ CETTE LIGNE
    this.disponible = true,
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
      photos: List<String>.from(data['photos'] ?? []),
      proprietaireId: data['proprietaireId'] ?? '',
      proprietaireNom: data['proprietaireNom'] ?? '', // AJOUTEZ CETTE LIGNE
      disponible: data['disponible'] ?? true,
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
      'photos': photos,
      'proprietaireId': proprietaireId,
      'proprietaireNom': proprietaireNom, // AJOUTEZ CETTE LIGNE
      'disponible': disponible,
      'datePublication': datePublication.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Logement(id: $id, titre: $titre, propriétaire: $proprietaireNom, prix: $prix€)';
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
        listEquals(other.photos, photos) &&
        other.proprietaireId == proprietaireId &&
        other.proprietaireNom == proprietaireNom && // AJOUTEZ CETTE LIGNE
        other.disponible == disponible &&
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
      Object.hashAll(photos),
      proprietaireId,
      proprietaireNom, // AJOUTEZ CETTE LIGNE
      disponible,
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
    List<String>? photos,
    String? proprietaireId,
    String? proprietaireNom, // AJOUTEZ CETTE LIGNE
    bool? disponible,
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
      photos: photos ?? this.photos,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      proprietaireNom: proprietaireNom ?? this.proprietaireNom, // AJOUTEZ CETTE LIGNE
      disponible: disponible ?? this.disponible,
      datePublication: datePublication ?? this.datePublication,
    );
  }
}





// import 'package:flutter/foundation.dart'; // Import ajouté ici

// class Logement {
//   String id;
//   String titre;
//   String description;
//   String adresse;
//   double prix;
//   int superficie;
//   int nombreChambres;
//   List<String> photos;
//   String proprietaireId;
//   bool disponible;
//   DateTime datePublication;
  
//   Logement({
//     required this.id,
//     required this.titre,
//     required this.description,
//     required this.adresse,
//     required this.prix,
//     required this.superficie,
//     required this.nombreChambres,
//     this.photos = const [],
//     required this.proprietaireId,
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
//       photos: List<String>.from(data['photos'] ?? []),
//       proprietaireId: data['proprietaireId'] ?? '',
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
//       'photos': photos,
//       'proprietaireId': proprietaireId,
//       'disponible': disponible,
//       'datePublication': datePublication.toIso8601String(),
//     };
//   }

//   // Méthode toString pour le débogage
//   @override
//   String toString() {
//     return 'Logement(id: $id, titre: $titre, prix: $prix€, disponible: $disponible)';
//   }

//   // Méthode pour comparer deux logements
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
//         listEquals(other.photos, photos) && // Utilisation de listEquals
//         other.proprietaireId == proprietaireId &&
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
//       // Pour la liste photos, on utilise un hash basé sur le contenu
//       Object.hashAll(photos),
//       proprietaireId,
//       disponible,
//       datePublication,
//     );
//   }
// }

// // Extension pour créer des copies modifiées
// extension LogementCopyWith on Logement {
//   Logement copyWith({
//     String? id,
//     String? titre,
//     String? description,
//     String? adresse,
//     double? prix,
//     int? superficie,
//     int? nombreChambres,
//     List<String>? photos,
//     String? proprietaireId,
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
//       photos: photos ?? this.photos,
//       proprietaireId: proprietaireId ?? this.proprietaireId,
//       disponible: disponible ?? this.disponible,
//       datePublication: datePublication ?? this.datePublication,
//     );
//   }
// }

