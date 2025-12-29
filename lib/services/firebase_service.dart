// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:typed_data';

// class FirebaseService {
//   static final FirebaseAuth auth = FirebaseAuth.instance;
//   static final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   static final FirebaseStorage storage = FirebaseStorage.instance;
  
//   // Vérifier si l'utilisateur est connecté
//   static bool isUserLoggedIn() {
//     return auth.currentUser != null;
//   }
  
//   // Récupérer l'UID de l'utilisateur
//   static String? getCurrentUserId() {
//     return auth.currentUser?.uid;
//   }
  
//   // Upload d'image
//   static Future<String> uploadImage(String path, Uint8List image) async {
//     try {
//       final ref = storage.ref().child(path);
//       final uploadTask = ref.putData(image);
//       final snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       throw Exception('Erreur upload: $e');
//     }
//   }
// }



import 'dart:typed_data'; // Import ajouté pour Uint8List
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  
  // Vérifier si l'utilisateur est connecté
  static bool isUserLoggedIn() {
    return auth.currentUser != null;
  }
  
  // Récupérer l'UID de l'utilisateur
  static String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }
  
  // Récupérer l'email de l'utilisateur
  static String? getCurrentUserEmail() {
    return auth.currentUser?.email;
  }
  
  // Récupérer le nom de l'utilisateur
  static String? getCurrentUserDisplayName() {
    return auth.currentUser?.displayName;
  }
  
  // Upload d'image
  static Future<String> uploadImage(String path, Uint8List image) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload: $e');
    }
  }
  
  // Upload multiple d'images
  static Future<List<String>> uploadMultipleImages(
    List<Uint8List> images, 
    String folderName
  ) async {
    try {
      final List<String> urls = [];
      
      for (int i = 0; i < images.length; i++) {
        final path = '$folderName/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await uploadImage(path, images[i]);
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Erreur upload multiple: $e');
    }
  }
  
  // Supprimer une image
  static Future<void> deleteImage(String url) async {
    try {
      final ref = storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur suppression image: $e');
    }
  }
  
  // Récupérer un document Firestore
  static Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await firestore.collection(collection).doc(docId).get();
    } catch (e) {
      throw Exception('Erreur récupération document: $e');
    }
  }
  
  // Mettre à jour un document Firestore
  static Future<void> updateDocument(
    String collection, 
    String docId, 
    Map<String, dynamic> data
  ) async {
    try {
      await firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Erreur mise à jour document: $e');
    }
  }
  
  // Créer un document Firestore
  static Future<void> createDocument(
    String collection, 
    String docId, 
    Map<String, dynamic> data
  ) async {
    try {
      await firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw Exception('Erreur création document: $e');
    }
  }
  
  // Supprimer un document Firestore
  static Future<void> deleteDocument(String collection, String docId) async {
    try {
      await firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Erreur suppression document: $e');
    }
  }
  
  // Écouter les changements d'un document
  static Stream<DocumentSnapshot> listenToDocument(
    String collection, 
    String docId
  ) {
    return firestore.collection(collection).doc(docId).snapshots();
  }
  
  // Écouter les changements d'une collection
  static Stream<QuerySnapshot> listenToCollection(
    String collection, {
    Query? query,
  }) {
    final collectionRef = firestore.collection(collection);
    final finalQuery = query ?? collectionRef;
    return finalQuery.snapshots();
  }
  
  // Vérifier si un document existe
  static Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Erreur vérification document: $e');
    }
  }
  
  // Envoyer un email de vérification
  static Future<void> sendEmailVerification() async {
    try {
      final user = auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Erreur envoi email vérification: $e');
    }
  }
  
  // Réinitialiser le mot de passe
  static Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erreur réinitialisation mot de passe: $e');
    }
  }
  
  // Mettre à jour le profil utilisateur
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.updateProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
      }
    } catch (e) {
      throw Exception('Erreur mise à jour profil: $e');
    }
  }
  
  // Récupérer l'URL d'une image depuis Storage
  static Future<String> getImageUrl(String path) async {
    try {
      final ref = storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur récupération URL image: $e');
    }
  }
  
  // Vérifier la taille d'un fichier avant upload
  static bool validateFileSize(Uint8List file, int maxSizeInBytes) {
    return file.lengthInBytes <= maxSizeInBytes;
  }
  
  // Convertir un fichier en Uint8List (méthode d'exemple)
  static Uint8List convertToUint8List(List<int> bytes) {
    return Uint8List.fromList(bytes);
  }
  
  // Générer un ID unique pour les documents
  static String generateUniqueId() {
    return firestore.collection('dummy').doc().id;
  }
  
  // Batch write pour opérations multiples
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = firestore.batch();
      
      for (var operation in operations) {
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String;
        final data = operation['data'] as Map<String, dynamic>;
        final type = operation['type'] as String; // 'set', 'update', 'delete'
        
        final docRef = firestore.collection(collection).doc(docId);
        
        switch (type) {
          case 'set':
            batch.set(docRef, data);
            break;
          case 'update':
            batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur batch write: $e');
    }
  }
  
  // Exécuter une transaction Firestore
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await firestore.runTransaction(updateFunction);
    } catch (e) {
      throw Exception('Erreur transaction: $e');
    }
  }
}









