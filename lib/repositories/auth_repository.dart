import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // INSCRIPTION AVEC RÔLE - VERSION MISE À JOUR (5 paramètres)
  Future<User?> register(String email, String password, String nom, String telephone, String role) async {
    print("📝 [REPO] Début register() pour: $email, Rôle: $role");
    
    try {
      print("🔥 [REPO] Création compte Firebase Auth");
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        print("❌ [REPO] Erreur: user null après création");
        throw Exception('Utilisateur non créé');
      }
      
      print("✅ [REPO] Compte Auth créé, UID: ${user.uid}");
      
      // Créer le document utilisateur dans Firestore AVEC LE RÔLE
      final utilisateurData = {
        'id': user.uid,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'role': role, // ← RÔLE PASSÉ EN PARAMÈTRE
        'dateCreation': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      print("📄 [REPO] Données utilisateur: $utilisateurData");
      print("💾 [REPO] Sauvegarde dans Firestore: users/${user.uid}");
      
      // Créer le document dans Firestore
      await _firestore.collection('users').doc(user.uid).set(utilisateurData);
      
      print("✅ [REPO] Document Firestore créé avec succès, Rôle: $role");
      
      return user;
      
    } catch (e, stackTrace) {
      print("❌ [REPO] ERREUR register(): $e");
      print("📝 [REPO] Stack trace: $stackTrace");
      
      // Gestion spécifique des erreurs Firebase
      if (e is FirebaseAuthException) {
        print("🔥 [REPO] Erreur Firebase Auth: ${e.code}");
        
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('Cet email est déjà utilisé');
          case 'invalid-email':
            throw Exception('Email invalide');
          case 'operation-not-allowed':
            throw Exception('Opération non autorisée');
          case 'weak-password':
            throw Exception('Mot de passe trop faible');
          default:
            throw Exception('Erreur d\'inscription: ${e.message}');
        }
      }
      
      throw Exception('Erreur inscription: $e');
    }
  }
  
  // CONNEXION (inchangée)
  Future<User?> login(String email, String password) async {
    print("🔑 [REPO] Début login() pour: $email");
    
    try {
      print("🔥 [REPO] Tentative de connexion Firebase Auth");
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("✅ [REPO] Connexion réussie, UID: ${credential.user?.uid}");
      return credential.user;
      
    } catch (e, stackTrace) {
      print("❌ [REPO] ERREUR login(): $e");
      print("📝 [REPO] Stack trace: $stackTrace");
      
      if (e is FirebaseAuthException) {
        print("🔥 [REPO] Erreur Firebase Auth: ${e.code}");
        
        switch (e.code) {
          case 'user-not-found':
            throw Exception('Aucun utilisateur trouvé avec cet email');
          case 'wrong-password':
            throw Exception('Mot de passe incorrect');
          case 'invalid-email':
            throw Exception('Email invalide');
          case 'user-disabled':
            throw Exception('Compte désactivé');
          default:
            throw Exception('Erreur connexion: ${e.message}');
        }
      }
      
      throw Exception('Erreur connexion: $e');
    }
  }
  
  // DÉCONNEXION (inchangée)
  Future<void> logout() async {
    print("🚪 [REPO] Début logout()");
    await _auth.signOut();
    print("✅ [REPO] Déconnexion réussie");
  }
  
  // RÉCUPÉRER L'UTILISATEUR ACTUEL (inchangée)
  Future<Utilisateur?> getCurrentUser() async {
    print("👤 [REPO] Début getCurrentUser()");
    
    try {
      User? firebaseUser = _auth.currentUser;
      print("🔥 [REPO] Firebase User: ${firebaseUser?.uid ?? 'null'}");
      
      if (firebaseUser == null) {
        print("👻 [REPO] Aucun utilisateur Firebase connecté");
        return null;
      }
      
      print("📄 [REPO] Recherche document: users/${firebaseUser.uid}");
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 5));
      
      print("📊 [REPO] Document exists: ${doc.exists}");
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // S'assurer que l'ID est présent
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        
        print("✅ [REPO] Données utilisateur: $data");
        
        // Vérifier la structure des données
        if (!data.containsKey('role')) {
          data['role'] = 'user'; // Valeur par défaut
          print("⚠️ [REPO] Champ 'role' manquant, valeur par défaut ajoutée");
        }
        
        // Parser la date
        if (data.containsKey('dateCreation') && data['dateCreation'] is String) {
          try {
            DateTime.parse(data['dateCreation']);
          } catch (e) {
            print("⚠️ [REPO] Erreur parsing date, remplacement par maintenant");
            data['dateCreation'] = DateTime.now().toIso8601String();
          }
        } else {
          data['dateCreation'] = DateTime.now().toIso8601String();
        }
        
        return Utilisateur.fromMap(data);
      } else {
        print("⚠️ [REPO] Document Firestore non trouvé pour ${firebaseUser.uid}");
        
        // Créer un document minimaliste si manquant
        print("🔄 [REPO] Création document minimaliste...");
        
        final minimalData = {
          'id': firebaseUser.uid,
          'nom': firebaseUser.displayName ?? 'Utilisateur',
          'email': firebaseUser.email ?? '',
          'telephone': '',
          'role': 'user',
          'dateCreation': DateTime.now().toIso8601String(),
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(firebaseUser.uid).set(minimalData);
        print("✅ [REPO] Document minimaliste créé");
        
        return Utilisateur.fromMap(minimalData);
      }
      
    } catch (e, stackTrace) {
      print("❌ [REPO] ERREUR getCurrentUser(): $e");
      print("📝 [REPO] Stack trace: $stackTrace");
      return null;
    }
  }
  
  // Mettre à jour le profil utilisateur
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur mise à jour profil: $e');
    }
  }
  
  // Vérifier si un email existe déjà
  Future<bool> checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print("⚠️ [REPO] Erreur checkEmailExists: $e");
      return false;
    }
  }
  
  // Méthode pour mettre à jour le rôle d'un utilisateur (optionnel)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      print("🔄 [REPO] Mise à jour rôle pour $userId -> $newRole");
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("✅ [REPO] Rôle mis à jour avec succès");
    } catch (e) {
      print("❌ [REPO] Erreur updateUserRole: $e");
      throw Exception('Erreur mise à jour rôle: $e');
    }
  }
}




// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/utilisateur_model.dart';

// class AuthRepository {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   // INSCRIPTION - VERSION CORRIGÉE
//   Future<User?> register(String email, String password, String nom, String telephone) async {
//     print("📝 [REPO] Début register() pour: $email");
    
//     try {
//       print("🔥 [REPO] Création compte Firebase Auth");
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       final user = credential.user;
//       if (user == null) {
//         print("❌ [REPO] Erreur: user null après création");
//         throw Exception('Utilisateur non créé');
//       }
      
//       print("✅ [REPO] Compte Auth créé, UID: ${user.uid}");
      
//       // Créer le document utilisateur dans Firestore
//       final utilisateurData = {
//         'id': user.uid, // Utiliser l'UID de Firebase Auth
//         'nom': nom,
//         'email': email,
//         'telephone': telephone,
//         'role': 'user', // Rôle par défaut
//         'dateCreation': DateTime.now().toIso8601String(),
//         'createdAt': FieldValue.serverTimestamp(), // Timestamp Firestore
//         'updatedAt': FieldValue.serverTimestamp(),
//       };
      
//       print("📄 [REPO] Données utilisateur: $utilisateurData");
//       print("💾 [REPO] Sauvegarde dans Firestore: users/${user.uid}");
      
//       // Créer le document avec set() au lieu de add()
//       await _firestore.collection('users').doc(user.uid).set(utilisateurData);
      
//       print("✅ [REPO] Document Firestore créé avec succès");
      
//       return user;
      
//     } catch (e, stackTrace) {
//       print("❌ [REPO] ERREUR register(): $e");
//       print("📝 [REPO] Stack trace: $stackTrace");
      
//       // Gestion spécifique des erreurs Firebase
//       if (e is FirebaseAuthException) {
//         print("🔥 [REPO] Erreur Firebase Auth: ${e.code}");
        
//         switch (e.code) {
//           case 'email-already-in-use':
//             throw Exception('Cet email est déjà utilisé');
//           case 'invalid-email':
//             throw Exception('Email invalide');
//           case 'operation-not-allowed':
//             throw Exception('Opération non autorisée');
//           case 'weak-password':
//             throw Exception('Mot de passe trop faible');
//           default:
//             throw Exception('Erreur d\'inscription: ${e.message}');
//         }
//       }
      
//       throw Exception('Erreur inscription: $e');
//     }
//   }
  
//   // CONNEXION
//   Future<User?> login(String email, String password) async {
//     print("🔑 [REPO] Début login() pour: $email");
    
//     try {
//       print("🔥 [REPO] Tentative de connexion Firebase Auth");
//       UserCredential credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       print("✅ [REPO] Connexion réussie, UID: ${credential.user?.uid}");
//       return credential.user;
      
//     } catch (e, stackTrace) {
//       print("❌ [REPO] ERREUR login(): $e");
//       print("📝 [REPO] Stack trace: $stackTrace");
      
//       if (e is FirebaseAuthException) {
//         print("🔥 [REPO] Erreur Firebase Auth: ${e.code}");
        
//         switch (e.code) {
//           case 'user-not-found':
//             throw Exception('Aucun utilisateur trouvé avec cet email');
//           case 'wrong-password':
//             throw Exception('Mot de passe incorrect');
//           case 'invalid-email':
//             throw Exception('Email invalide');
//           case 'user-disabled':
//             throw Exception('Compte désactivé');
//           default:
//             throw Exception('Erreur connexion: ${e.message}');
//         }
//       }
      
//       throw Exception('Erreur connexion: $e');
//     }
//   }
  
//   // DÉCONNEXION
//   Future<void> logout() async {
//     print("🚪 [REPO] Début logout()");
//     await _auth.signOut();
//     print("✅ [REPO] Déconnexion réussie");
//   }
  
//   // RÉCUPÉRER L'UTILISATEUR ACTUEL - VERSION CORRIGÉE
//   Future<Utilisateur?> getCurrentUser() async {
//     print("👤 [REPO] Début getCurrentUser()");
    
//     try {
//       User? firebaseUser = _auth.currentUser;
//       print("🔥 [REPO] Firebase User: ${firebaseUser?.uid ?? 'null'}");
      
//       if (firebaseUser == null) {
//         print("👻 [REPO] Aucun utilisateur Firebase connecté");
//         return null;
//       }
      
//       print("📄 [REPO] Recherche document: users/${firebaseUser.uid}");
      
//       DocumentSnapshot doc = await _firestore
//           .collection('users')
//           .doc(firebaseUser.uid)
//           .get()
//           .timeout(const Duration(seconds: 5));
      
//       print("📊 [REPO] Document exists: ${doc.exists}");
      
//       if (doc.exists) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
//         // S'assurer que l'ID est présent
//         if (!data.containsKey('id')) {
//           data['id'] = doc.id;
//         }
        
//         print("✅ [REPO] Données utilisateur: $data");
        
//         // Vérifier la structure des données
//         if (!data.containsKey('role')) {
//           data['role'] = 'user'; // Valeur par défaut
//           print("⚠️ [REPO] Champ 'role' manquant, valeur par défaut ajoutée");
//         }
        
//         // Parser la date
//         if (data.containsKey('dateCreation') && data['dateCreation'] is String) {
//           try {
//             DateTime.parse(data['dateCreation']);
//           } catch (e) {
//             print("⚠️ [REPO] Erreur parsing date, remplacement par maintenant");
//             data['dateCreation'] = DateTime.now().toIso8601String();
//           }
//         } else {
//           data['dateCreation'] = DateTime.now().toIso8601String();
//         }
        
//         return Utilisateur.fromMap(data);
//       } else {
//         print("⚠️ [REPO] Document Firestore non trouvé pour ${firebaseUser.uid}");
        
//         // Créer un document minimaliste si manquant
//         print("🔄 [REPO] Création document minimaliste...");
        
//         final minimalData = {
//           'id': firebaseUser.uid,
//           'nom': firebaseUser.displayName ?? 'Utilisateur',
//           'email': firebaseUser.email ?? '',
//           'telephone': '',
//           'role': 'user',
//           'dateCreation': DateTime.now().toIso8601String(),
//           'createdAt': FieldValue.serverTimestamp(),
//         };
        
//         await _firestore.collection('users').doc(firebaseUser.uid).set(minimalData);
//         print("✅ [REPO] Document minimaliste créé");
        
//         return Utilisateur.fromMap(minimalData);
//       }
      
//     } catch (e, stackTrace) {
//       print("❌ [REPO] ERREUR getCurrentUser(): $e");
//       print("📝 [REPO] Stack trace: $stackTrace");
//       return null;
//     }
//   }
  
//   // Mettre à jour le profil utilisateur
//   Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         ...updates,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Erreur mise à jour profil: $e');
//     }
//   }
  
//   // Vérifier si un email existe déjà
//   Future<bool> checkEmailExists(String email) async {
//     try {
//       final query = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();
      
//       return query.docs.isNotEmpty;
//     } catch (e) {
//       print("⚠️ [REPO] Erreur checkEmailExists: $e");
//       return false;
//     }
//   }
// }





