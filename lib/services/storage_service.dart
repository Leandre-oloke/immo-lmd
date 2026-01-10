import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non connecté");
      }

      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String dynamicPath = 'users/${user.uid}/photos/$fileName';

      Reference storageRef = _storage.ref().child(dynamicPath);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("Erreur lors de l'upload: $e");
      rethrow;
    }
  }

  Future<String?> pickAndUploadImage() async {
    File? imageFile = await pickImage();
    if (imageFile != null) {
      String imageUrl = await uploadImage(imageFile);
      return imageUrl;
    }
    return null;
  }
}






// // lib/services/storage_service.dart
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class StorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   Future<List<String>> uploadLogementPhotos(
//     String logementId,
//     List<XFile> images,
//   ) async {
//     List<String> downloadUrls = [];

//     for (int i = 0; i < images.length; i++) {
//       try {
//         final file = File(images[i].path);
//         final ref = _storage.ref().child(
//           'logements/$logementId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
//         );
        
//         final uploadTask = await ref.putFile(file);
//         final downloadUrl = await uploadTask.ref.getDownloadURL();
//         downloadUrls.add(downloadUrl);
//       } catch (e) {
//         print("Erreur upload photo: $e");
//       }
//     }

//     return downloadUrls;
//   }

//   Future<void> deletePhoto(String url) async {
//     try {
//       final ref = _storage.refFromURL(url);
//       await ref.delete();
//     } catch (e) {
//       print("Erreur suppression photo: $e");
//     }
//   }
// }