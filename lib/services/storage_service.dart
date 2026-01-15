import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload une image depuis un fichier
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    required String folder,
    String? customFileName,
  }) async {
    try {
      // Créer un nom de fichier unique
      String fileName = customFileName ??
          '${folder}_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Référence dans Firebase Storage
      Reference storageRef = _storage.ref().child('$folder/$userId/$fileName');
      
      // Metadata pour mieux organiser
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Upload du fichier
      UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Suivre la progression (optionnel)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Progression upload: ${progress.toStringAsFixed(2)}%');
      });
      
      // Attendre la fin de l'upload
      TaskSnapshot snapshot = await uploadTask;
      
      // Récupérer l'URL de téléchargement
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      throw e;
    }
  }

  // Upload une image depuis la galerie
  Future<String?> pickAndUploadImage({
    required String userId,
    required String folder,
    bool fromCamera = false,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, // Qualité réduite pour économiser du stockage
        maxWidth: 1080, // Limite la taille
      );
      
      if (image == null) return null;
      
      File imageFile = File(image.path);
      return await uploadImage(
        imageFile: imageFile,
        userId: userId,
        folder: folder,
      );
    } catch (e) {
      print('Erreur sélection/upload image: $e');
      return null;
    }
  }

  // Upload multiple d'images
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String userId,
    required String folder,
  }) async {
    List<String> downloadUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        String url = await uploadImage(
          imageFile: imageFiles[i],
          userId: userId,
          folder: folder,
          customFileName: '${folder}_${userId}_${i}_${DateTime.now().millisecondsSinceEpoch}',
        );
        downloadUrls.add(url);
      } catch (e) {
        print('Erreur upload image $i: $e');
      }
    }
    
    return downloadUrls;
  }

  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Erreur suppression image: $e');
      throw e;
    }
  }

  // Obtenir la taille d'un fichier
  Future<int> getFileSize(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      print('Erreur récupération taille: $e');
      return 0;
    }
  }

  // Lister les fichiers d'un utilisateur
  Future<List<String>> listUserFiles(String userId, String folder) async {
    try {
      ListResult result = await _storage.ref().child('$folder/$userId').listAll();
      
      List<String> urls = [];
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Erreur listing fichiers: $e');
      return [];
    }
  }
}





//================================

// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

// class StorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ImagePicker _picker = ImagePicker();

//   Future<File?> pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return null;
//     return File(image.path);
//   }

//   Future<String> uploadImage(File imageFile) async {
//     try {
//       User? user = _auth.currentUser;
//       if (user == null) {
//         throw Exception("Utilisateur non connecté");
//       }

//       String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       String dynamicPath = 'users/${user.uid}/photos/$fileName';

//       Reference storageRef = _storage.ref().child(dynamicPath);
//       UploadTask uploadTask = storageRef.putFile(imageFile);
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadURL = await snapshot.ref.getDownloadURL();

//       return downloadURL;
//     } catch (e) {
//       print("Erreur lors de l'upload: $e");
//       rethrow;
//     }
//   }

//   Future<String?> pickAndUploadImage() async {
//     File? imageFile = await pickImage();
//     if (imageFile != null) {
//       String imageUrl = await uploadImage(imageFile);
//       return imageUrl;
//     }
//     return null;
//   }
// }




