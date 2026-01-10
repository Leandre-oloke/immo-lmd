class Utilisateur {
  String id;
  String nom;
  String email;
  String telephone;
  String role; // 'admin', 'owner', 'user'
  DateTime dateCreation;
  
  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.dateCreation,
  });
  
  factory Utilisateur.fromMap(Map<String, dynamic> data) {
    return Utilisateur(
      id: data['id'] ?? '',
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      role: data['role'] ?? 'user',
      dateCreation: data['dateCreation'] != null 
          ? DateTime.parse(data['dateCreation'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  // Méthode toString pour le débogage
  @override
  String toString() {
    return 'Utilisateur(id: $id, nom: $nom, email: $email, role: $role)';
  }

  // Méthode pour comparer deux utilisateurs
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Utilisateur &&
        other.id == id &&
        other.nom == nom &&
        other.email == email &&
        other.telephone == telephone &&
        other.role == role &&
        other.dateCreation == dateCreation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           nom.hashCode ^
           email.hashCode ^
           telephone.hashCode ^
           role.hashCode ^
           dateCreation.hashCode;
  }
}

// Extension pour créer des copies modifiées
extension UtilisateurCopyWith on Utilisateur {
  Utilisateur copyWith({
    String? id,
    String? nom,
    String? email,
    String? telephone,
    String? role,
    DateTime? dateCreation,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}

