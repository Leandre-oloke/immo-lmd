import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Sélectionner des images depuis la galerie
  Future<List<XFile>> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images ?? []; // Ajout du ?? [] pour sécurité
    } catch (e) {
      print("❌ Erreur sélection images: $e");
      return [];
    }
  }

  // CORRIGÉ : Uploader une image vers Firebase Storage
  Future<String> uploadImage(File image, String logementId, int index) async {
    print('🔄 Début upload image $index pour logement $logementId');
    
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      final ref = _storage.ref().child('logements/$logementId/$fileName');
      
      print('   📁 Chemin Storage: ${ref.fullPath}');
      print('   📊 Taille fichier: ${await image.length()} bytes');
      
      // CORRECTION CRITIQUE : Attendre la complétion de la tâche
      final uploadTask = ref.putFile(image);
      
      // Écouter la progression (optionnel, pour le débogage)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
        print('   📈 Progression image $index: ${progress.toStringAsFixed(1)}%');
      }, onError: (e) {
        print('   ❌ Erreur progression image $index: $e');
      });
      
      // ATTENDRE que l'upload soit complètement terminé
      final TaskSnapshot snapshot = await uploadTask;
      
      // MAINTENANT on peut récupérer l'URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image $index uploadée avec succès: $downloadUrl');
      return downloadUrl;
      
    } catch (e, stackTrace) {
      print("❌ Erreur upload image $index: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // CORRIGÉ : Uploader plusieurs images
  Future<List<String>> uploadMultipleImages(
    List<XFile> images, 
    String logementId
  ) async {
    print('=== DÉBUT UPLOAD MULTIPLE ===');
    print('📸 Nombre d\'images: ${images.length}');
    print('🏠 ID Logement: $logementId');
    
    final List<String> urls = [];
    
    for (int i = 0; i < images.length; i++) {
      try {
        print('\n--- Traitement image $i/${images.length} ---');
        print('   Chemin local: ${images[i].path}');
        
        // Vérifier si le fichier existe
        final file = File(images[i].path);
        if (!await file.exists()) {
          print('   ⚠️ Fichier n\'existe pas, skip...');
          continue;
        }
        
        final url = await uploadImage(file, logementId, i);
        urls.add(url);
        
      } catch (e) {
        print("⚠️ Image $i non uploadée: $e");
      }
    }
    
    print('=== FIN UPLOAD MULTIPLE ===');
    print('✅ URLs obtenues: ${urls.length}/${images.length}');
    
    return urls;
  }

  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('🗑️ Image supprimée: $imageUrl');
    } catch (e) {
      print("❌ Erreur suppression image: $e");
    }
  }
}


// // lib/services/image_service.dart
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class ImageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   // Sélectionner des images depuis la galerie
//   Future<List<XFile>> pickImages() async {
//     try {
//       final List<XFile> images = await _picker.pickMultiImage(
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//       return images;
//     } catch (e) {
//       print("❌ Erreur sélection images: $e");
//       return [];
//     }
//   }

//   // Uploader une image vers Firebase Storage
//   Future<String> uploadImage(File image, String logementId, int index) async {
//     try {
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
//       final ref = _storage.ref().child('logements/$logementId/$fileName');
      
//       final uploadTask = await ref.putFile(image);
//       final downloadUrl = await uploadTask.ref.getDownloadURL();
      
//       return downloadUrl;
//     } catch (e) {
//       print("❌ Erreur upload image: $e");
//       rethrow;
//     }
//   }

//   // Uploader plusieurs images
//   Future<List<String>> uploadMultipleImages(
//     List<XFile> images, 
//     String logementId
//   ) async {
//     final List<String> urls = [];
    
//     for (int i = 0; i < images.length; i++) {
//       try {
//         final file = File(images[i].path);
//         final url = await uploadImage(file, logementId, i);
//         urls.add(url);
//       } catch (e) {
//         print("⚠️ Image $i non uploadée: $e");
//       }
//     }
    
//     return urls;
//   }

//   // Supprimer une image
//   Future<void> deleteImage(String imageUrl) async {
//     try {
//       final ref = _storage.refFromURL(imageUrl);
//       await ref.delete();
//     } catch (e) {
//       print("❌ Erreur suppression image: $e");
//     }
//   }
// }