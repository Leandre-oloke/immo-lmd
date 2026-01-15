// services/image_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Sélectionner une image
  Future<File?> pickImage({bool fromCamera = false, int quality = 85}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: quality,
        maxWidth: 1080,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Erreur sélection image: $e');
      return null;
    }
  }

  // Sélectionner plusieurs images
  Future<List<File>> pickMultipleImages() async {
    try {
      List<XFile?> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1080,
      );
      return images.whereType<XFile>().map((x) => File(x.path)).toList();
    } catch (e) {
      print('Erreur sélection multiples images: $e');
      return [];
    }
  }

  // Uploader une image (XFile)
  Future<String?> uploadSingleImage(
    XFile image, {
    required String userId,
    required String folder,
    String? customFileName,
  }) async {
    try {
      File imageFile = File(image.path);
      
      // Nom de fichier unique
      String fileName = customFileName ??
          '${folder}_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      
      // Référence Storage
      Reference storageRef = _storage.ref().child('$folder/$userId/$fileName');
      
      // Metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': userId},
      );
      
      // Upload
      UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      TaskSnapshot snapshot = await uploadTask;
      
      // Récupérer URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Erreur upload single image: $e');
      return null;
    }
  }

  // Uploader plusieurs images
  Future<List<String>> uploadMultipleImages(
    List<XFile> images, {
    required String userId,
    required String folder,
  }) async {
    List<String> urls = [];
    
    for (int i = 0; i < images.length; i++) {
      try {
        String? url = await uploadSingleImage(
          images[i],
          userId: userId,
          folder: folder,
          customFileName: '${folder}_${userId}_${i}_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        if (url != null) {
          urls.add(url);
        }
      } catch (e) {
        print('Erreur upload image $i: $e');
      }
    }
    
    return urls;
  }

  // Vérifier taille fichier
  Future<bool> isFileSizeValid(File file, {int maxSizeMB = 5}) {
    return file.length().then((size) {
      double sizeMB = size / (1024 * 1024);
      return sizeMB <= maxSizeMB;
    });
  }
}





  // // Compresser une image
  // Future<File?> compressImage(File file, {int quality = 85}) async {
  //   try {
  //     // Obtenir le répertoire temporaire
  //     final dir = await getTemporaryDirectory();
  //     final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
  //     // Compresser l'image
  //     XFile? result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       targetPath,
  //       quality: quality,
  //       minWidth: 600,
  //       minHeight: 600,
  //     );
      
  //     return result != null ? File(result.path) : null;
  //   } catch (e) {
  //     print('Erreur compression image: $e');
  //     return null;
  //   }
  // }

  // // Redimensionner une image
  // Future<Uint8List?> resizeImage(File file, {int width = 800, int height = 800}) async {
  //   try {
  //     Uint8List? result = await FlutterImageCompress.compressWithFile(
  //       file.absolute.path,
  //       minWidth: width,
  //       minHeight: height,
  //       quality: 80,
  //     );
      
  //     return result;
  //   } catch (e) {
  //     print('Erreur redimensionnement image: $e');
  //     return null;
  //   }
  // }

//   // Vérifier la taille d'un fichier
//   Future<bool> isFileSizeValid(File file, {int maxSizeMB = 5}) {
//     return file.length().then((size) {
//       double sizeMB = size / (1024 * 1024);
//       return sizeMB <= maxSizeMB;
//     });
//   }

//   // Convertir Uint8List en File
//   Future<File> uint8ListToFile(Uint8List bytes, String fileName) async {
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes);
//     return file;
//   }
// }


