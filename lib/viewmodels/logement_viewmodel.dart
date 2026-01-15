// lib/viewmodels/logement_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/logement_repository.dart';
import '../repositories/favoris_repository.dart';
import '../models/logement_model.dart';
import '../services/storage_service.dart';
import '../services/image_service.dart';

class LogementViewModel with ChangeNotifier {
  final LogementRepository _repository = LogementRepository();
  final FavorisRepository _favorisRepository = FavorisRepository();
  final StorageService _storageService = StorageService();
  final ImageService _imageService = ImageService();
  
  // Listes de logements
  List<Logement> _logements = [];
  List<Logement> _myLogements = [];
  List<Logement> _favoris = [];
  
  // Cache des IDs favoris pour vérification rapide
  Set<String> _favorisIds = {};
  
  // États de chargement
  bool _isLoading = false;
  bool _isLoadingFavoris = false;
  bool _isUploadingImages = false;
  String? _errorMessage;
  
  // Gestion des images sélectionnées
  List<File> _selectedImages = [];
  double _uploadProgress = 0.0;
  
  // Getters
  List<Logement> get logements => _logements;
  List<Logement> get myLogements => _myLogements;
  List<Logement> get favoris => _favoris;
  bool get isLoading => _isLoading;
  bool get isLoadingFavoris => _isLoadingFavoris;
  bool get isUploadingImages => _isUploadingImages;
  String? get errorMessage => _errorMessage;
  List<File> get selectedImages => _selectedImages;
  double get uploadProgress => _uploadProgress;
  
  // ========== MÉTHODES FAVORIS ==========
  
  /// Vérifier si un logement est en favori
  bool isFavorite(String logementId) {
    return _favorisIds.contains(logementId);
  }
  
  /// Toggle favori (ajoute ou retire)
  Future<void> toggleFavori(String logementId) async {
    try {
      final isFavori = _favorisIds.contains(logementId);
      
      // Mise à jour optimiste de l'interface
      if (isFavori) {
        _favorisIds.remove(logementId);
        _favoris.removeWhere((l) => l.id == logementId);
      } else {
        _favorisIds.add(logementId);
      }
      
      // Met à jour l'état isFavori dans toutes les listes
      _updateLogementFavoriStatus(logementId, !isFavori);
      
      notifyListeners();
      
      // Mise à jour Firebase
      await _favorisRepository.toggleFavori(logementId, isFavori);
      
      print('✅ Favori ${isFavori ? 'retiré' : 'ajouté'}: $logementId');
      
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
      _errorMessage = 'Erreur: $e';
      
      // Annuler le changement optimiste en cas d'erreur
      await loadFavoris();
      notifyListeners();
      rethrow;
    }
  }
  
  /// Ajouter un favori
  Future<void> addFavorite(String logementId) async {
    if (_favorisIds.contains(logementId)) {
      print('⚠️ Logement déjà en favori');
      return;
    }
    
    try {
      // Mise à jour optimiste
      _favorisIds.add(logementId);
      _updateLogementFavoriStatus(logementId, true);
      
      // Ajouter à la liste des favoris si le logement existe
      final logement = _findLogementById(logementId);
      if (logement != null && !_favoris.any((l) => l.id == logementId)) {
        _favoris.add(logement.copyWith(isFavori: true));
      }
      
      notifyListeners();
      
      // Mise à jour Firebase
      await _favorisRepository.ajouterFavori(logementId);
      
      print('✅ Favori ajouté: $logementId');
      
    } catch (e) {
      print('❌ Erreur ajout favori: $e');
      _errorMessage = 'Erreur ajout favori: $e';
      
      // Rollback en cas d'erreur
      _favorisIds.remove(logementId);
      _favoris.removeWhere((l) => l.id == logementId);
      _updateLogementFavoriStatus(logementId, false);
      
      notifyListeners();
      rethrow;
    }
  }
  
  /// Retirer un favori
  Future<void> removeFavorite(String logementId) async {
    if (!_favorisIds.contains(logementId)) {
      print('⚠️ Logement pas en favori');
      return;
    }
    
    try {
      // Mise à jour optimiste
      _favorisIds.remove(logementId);
      _favoris.removeWhere((l) => l.id == logementId);
      _updateLogementFavoriStatus(logementId, false);
      
      notifyListeners();
      
      // Mise à jour Firebase
      await _favorisRepository.retirerFavori(logementId);
      
      print('✅ Favori retiré: $logementId');
      
    } catch (e) {
      print('❌ Erreur suppression favori: $e');
      _errorMessage = 'Erreur suppression favori: $e';
      
      // Rollback en cas d'erreur
      _favorisIds.add(logementId);
      _updateLogementFavoriStatus(logementId, true);
      
      notifyListeners();
      rethrow;
    }
  }
  
  /// Charger les favoris depuis Firestore
  Future<void> loadFavoris() async {
    _isLoadingFavoris = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _favoris = await _favorisRepository.getFavoris();
      _favorisIds = _favoris.map((l) => l.id).toSet();
      
      // Synchroniser avec les autres listes
      _syncFavorisStatus();
      
      print('✅ ${_favoris.length} favoris chargés');
    } catch (e) {
      _errorMessage = 'Erreur chargement favoris: $e';
      print('❌ Erreur loadFavoris: $e');
    } finally {
      _isLoadingFavoris = false;
      notifyListeners();
    }
  }
  
  /// Vider tous les favoris
  Future<void> clearFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final favorisToDelete = List<String>.from(_favorisIds);
      
      // Supprimer chaque favori de Firestore
      for (final logementId in favorisToDelete) {
        await _favorisRepository.retirerFavori(logementId);
      }
      
      // Vider les caches locaux
      _favoris.clear();
      _favorisIds.clear();
      
      // Mettre à jour le statut isFavori pour tous les logements
      for (var i = 0; i < _logements.length; i++) {
        if (_logements[i].isFavori) {
          _logements[i] = _logements[i].copyWith(isFavori: false);
        }
      }
      
      for (var i = 0; i < _myLogements.length; i++) {
        if (_myLogements[i].isFavori) {
          _myLogements[i] = _myLogements[i].copyWith(isFavori: false);
        }
      }
      
      print('✅ Tous les favoris ont été supprimés');
      
    } catch (e) {
      _errorMessage = 'Erreur suppression favoris: $e';
      print('❌ Erreur clearFavorites: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Synchroniser le statut favori entre toutes les listes
  void _syncFavorisStatus() {
    for (var i = 0; i < _logements.length; i++) {
      final isFavori = _favorisIds.contains(_logements[i].id);
      if (_logements[i].isFavori != isFavori) {
        _logements[i] = _logements[i].copyWith(isFavori: isFavori);
      }
    }
    
    for (var i = 0; i < _myLogements.length; i++) {
      final isFavori = _favorisIds.contains(_myLogements[i].id);
      if (_myLogements[i].isFavori != isFavori) {
        _myLogements[i] = _myLogements[i].copyWith(isFavori: isFavori);
      }
    }
  }
  
  /// Mettre à jour le statut favori d'un logement dans toutes les listes
  void _updateLogementFavoriStatus(String logementId, bool isFavori) {
    // Mise à jour dans _logements
    final index1 = _logements.indexWhere((l) => l.id == logementId);
    if (index1 != -1) {
      _logements[index1] = _logements[index1].copyWith(isFavori: isFavori);
    }
    
    // Mise à jour dans _myLogements
    final index2 = _myLogements.indexWhere((l) => l.id == logementId);
    if (index2 != -1) {
      _myLogements[index2] = _myLogements[index2].copyWith(isFavori: isFavori);
    }
  }
  
  // ========== CHARGEMENT LOGEMENTS ==========
  
  /// Charger tous les logements
  Future<void> loadAllLogements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Charger les favoris IDs d'abord
      _favorisIds = await _favorisRepository.getFavorisIds();
      
      // Convertir le Stream en Future
      final stream = _repository.getAllLogements();
      await for (final logements in stream) {
        _logements = logements;
        break; // Prendre seulement le premier résultat
      }
      
      // Synchroniser le statut favori
      _syncFavorisStatus();
      
      print('✅ ${_logements.length} logements chargés');
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erreur chargement: $error';
      print('❌ Erreur loadAllLogements: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Charger les logements d'un propriétaire
  Future<void> loadMyLogements(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Charger les favoris IDs d'abord
      _favorisIds = await _favorisRepository.getFavorisIds();
      
      // Convertir le Stream en Future
      final stream = _repository.getLogementsByOwner(ownerId);
      await for (final logements in stream) {
        _myLogements = logements;
        break;
      }
      
      // Synchroniser le statut favori
      _syncFavorisStatus();
      
      print('✅ ${_myLogements.length} logements du propriétaire chargés');
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erreur chargement: $error';
      print('❌ Erreur loadMyLogements: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Méthode alternative plus simple
  Future<void> loadAllLogementsSimple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Charger les favoris IDs
      _favorisIds = await _favorisRepository.getFavorisIds();
      
      // Attendre le premier résultat du Stream
      _logements = await _repository.getAllLogements().first;
      
      // Synchroniser
      _syncFavorisStatus();
      
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erreur chargement: $error';
      print('❌ Erreur: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========== GESTION IMAGES ==========
  
  Future<void> selectLogementImages() async {
    try {
      List<File> images = await _imageService.pickMultipleImages();
      if (images.isNotEmpty) {
        _selectedImages = images;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur sélection images: $e';
      notifyListeners();
    }
  }
  
  Future<void> addSingleImage() async {
    try {
      File? image = await _imageService.pickImage();
      if (image != null) {
        _selectedImages.add(image);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur ajout image: $e';
      notifyListeners();
    }
  }
  
  void removeSelectedImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }
  
  Future<List<String>> uploadLogementImages({
    required String userId,
    required String logementId,
  }) async {
    if (_selectedImages.isEmpty) return [];
    
    _isUploadingImages = true;
    _uploadProgress = 0.0;
    notifyListeners();
    
    try {
      List<String> imageUrls = await _storageService.uploadMultipleImages(
        imageFiles: _selectedImages,
        userId: userId,
        folder: 'logements/$logementId',
      );
      
      _uploadProgress = 100.0;
      _isUploadingImages = false;
      notifyListeners();
      
      return imageUrls;
    } catch (e) {
      _errorMessage = 'Erreur upload images: $e';
      _isUploadingImages = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // ========== CRUD LOGEMENTS ==========
  
  Future<bool> addLogementWithImages(Logement logement, String userId) async {
    _isLoading = true;
    _isUploadingImages = true;
    notifyListeners();
    
    try {
      await _repository.addLogement(logement);
      
      if (_selectedImages.isNotEmpty) {
        List<String> imageUrls = await uploadLogementImages(
          userId: userId,
          logementId: logement.id,
        );
        
        Logement updatedLogement = logement.copyWith(images: imageUrls);
        await _repository.updateLogement(updatedLogement);
        logement = updatedLogement;
      }
      
      _logements.add(logement);
      if (logement.proprietaireId == userId) {
        _myLogements.add(logement);
      }
      
      _selectedImages.clear();
      _errorMessage = null;
      return true;
      
    } catch (e) {
      _errorMessage = 'Erreur ajout logement: $e';
      return false;
    } finally {
      _isLoading = false;
      _isUploadingImages = false;
      notifyListeners();
    }
  }
  
  Future<bool> addLogement(Logement logement) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.addLogement(logement);
      _logements.add(logement);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erreur ajout: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateLogement(Logement logement) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.updateLogement(logement);
      _updateLocalLogement(logement);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteLogement(String logementId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      Logement? logement = _findLogementById(logementId);
      
      // Supprimer les images du storage
      if (logement != null && logement.images.isNotEmpty) {
        for (String url in logement.images) {
          try {
            await _storageService.deleteImage(url);
          } catch (e) {
            debugPrint('Erreur suppression image: $e');
          }
        }
      }
      
      // Supprimer des favoris si présent
      if (_favorisIds.contains(logementId)) {
        await _favorisRepository.retirerFavori(logementId);
        _favorisIds.remove(logementId);
      }
      _favoris.removeWhere((l) => l.id == logementId);
      
      // Supprimer de Firestore
      await _repository.deleteLogement(logementId);
      
      // Supprimer des listes locales
      _logements.removeWhere((l) => l.id == logementId);
      _myLogements.removeWhere((l) => l.id == logementId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========== MÉTHODES UTILITAIRES ==========
  
  Logement? _findLogementById(String logementId) {
    try {
      return _logements.firstWhere((l) => l.id == logementId);
    } catch (e) {
      try {
        return _myLogements.firstWhere((l) => l.id == logementId);
      } catch (e) {
        try {
          return _favoris.firstWhere((l) => l.id == logementId);
        } catch (e) {
          return null;
        }
      }
    }
  }
  
  void _updateLocalLogement(Logement updatedLogement) {
    int index = _logements.indexWhere((l) => l.id == updatedLogement.id);
    if (index != -1) {
      _logements[index] = updatedLogement;
    }
    
    index = _myLogements.indexWhere((l) => l.id == updatedLogement.id);
    if (index != -1) {
      _myLogements[index] = updatedLogement;
    }
    
    index = _favoris.indexWhere((l) => l.id == updatedLogement.id);
    if (index != -1) {
      _favoris[index] = updatedLogement;
    }
  }
  
  void clearSelectedImages() {
    _selectedImages.clear();
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Filtrer les logements
  List<Logement> filterLogements({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    bool? availableOnly,
    bool? favoritesOnly,
  }) {
    List<Logement> filtered = _logements;
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((logement) {
        return logement.titre.toLowerCase().contains(searchQuery.toLowerCase()) ||
               logement.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
               logement.adresse.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    if (minPrice != null) {
      filtered = filtered.where((logement) => logement.prix >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      filtered = filtered.where((logement) => logement.prix <= maxPrice).toList();
    }
    
    if (minRooms != null) {
      filtered = filtered.where((logement) => logement.nombreChambres >= minRooms).toList();
    }
    
    if (maxRooms != null) {
      filtered = filtered.where((logement) => logement.nombreChambres <= maxRooms).toList();
    }
    
    if (availableOnly == true) {
      filtered = filtered.where((logement) => logement.disponible).toList();
    }
    
    if (favoritesOnly == true) {
      filtered = filtered.where((logement) => _favorisIds.contains(logement.id)).toList();
    }
    
    return filtered;
  }
  
  /// Obtenir les logements favoris
  List<Logement> getFavoriteLogements() {
    return _logements.where((logement) => _favorisIds.contains(logement.id)).toList();
  }
  
  /// Méthode pour recharger (rafraîchir)
  Future<void> refresh() async {
    await loadAllLogements();
    await loadFavoris();
  }
}



//============================================================

// // lib/viewmodels/logement_viewmodel.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../repositories/logement_repository.dart';
// import '../repositories/favoris_repository.dart';
// import '../models/logement_model.dart';
// import '../services/storage_service.dart';
// import '../services/image_service.dart';

// class LogementViewModel with ChangeNotifier {
//   final LogementRepository _repository = LogementRepository();
//   final FavorisRepository _favorisRepository = FavorisRepository();
//   final StorageService _storageService = StorageService();
//   final ImageService _imageService = ImageService();
  
//   List<Logement> _logements = [];
//   List<Logement> _myLogements = [];
//   List<Logement> _favoris = [];
//   bool _isLoading = false;
//   bool _isLoadingFavoris = false;
//   bool _isUploadingImages = false;
//   String? _errorMessage;
  
//   // Gestion des images sélectionnées
//   List<File> _selectedImages = [];
//   double _uploadProgress = 0.0;
  
//   List<Logement> get logements => _logements;
//   List<Logement> get myLogements => _myLogements;
//   List<Logement> get favoris => _favoris;
//   bool get isLoading => _isLoading;
//   bool get isLoadingFavoris => _isLoadingFavoris;
//   bool get isUploadingImages => _isUploadingImages;
//   String? get errorMessage => _errorMessage;
//   List<File> get selectedImages => _selectedImages;
//   double get uploadProgress => _uploadProgress;
  
//   // ========== MÉTHODES FAVORIS AMÉLIORÉES ==========
  
//   // Vérifier si un logement est en favori
//   bool isFavorite(String logementId) {
//     return _favoris.any((l) => l.id == logementId);
//   }
  
//   // Toggle favori (ajoute ou retire)
//   Future<void> toggleFavori(String logementId) async {
//     try {
//       final logement = _findLogementById(logementId);
//       if (logement == null) return;
      
//       final isCurrentlyFavorite = isFavorite(logementId);
      
//       if (isCurrentlyFavorite) {
//         await removeFavorite(logementId);
//       } else {
//         await addFavorite(logementId);
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur favori: $e';
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // Ajouter un favori (avec appel au repository)
//   Future<void> addFavorite(String logementId) async {
//     try {
//       await _favorisRepository.ajouterFavori(logementId);
      
//       // Mettre à jour le statut local
//       final logement = _findLogementById(logementId);
//       if (logement != null) {
//         final updatedLogement = logement.copyWith(isFavori: true);
//         _updateLocalLogement(updatedLogement);
        
//         if (!_favoris.any((l) => l.id == logementId)) {
//           _favoris.add(updatedLogement);
//         }
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Erreur ajout favori: $e';
//       rethrow;
//     }
//   }
  
//   // Retirer un favori (avec appel au repository)
//   Future<void> removeFavorite(String logementId) async {
//     try {
//       await _favorisRepository.retirerFavori(logementId);
      
//       // Mettre à jour le statut local
//       final logement = _findLogementById(logementId);
//       if (logement != null) {
//         final updatedLogement = logement.copyWith(isFavori: false);
//         _updateLocalLogement(updatedLogement);
//         _favoris.removeWhere((l) => l.id == logementId);
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Erreur suppression favori: $e';
//       rethrow;
//     }
//   }
  
//   // Charger les favoris depuis Firestore
//   Future<void> loadFavoris() async {
//     _isLoadingFavoris = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       _favoris = await _favorisRepository.getFavoris();
//     } catch (e) {
//       _errorMessage = 'Erreur chargement favoris: $e';
//       print('❌ Erreur loadFavoris: $e');
//     } finally {
//       _isLoadingFavoris = false;
//       notifyListeners();
//     }
//   }
  
//   // Vérifier le statut favori pour tous les logements
//   Future<void> _checkFavorisStatus() async {
//     try {
//       for (var i = 0; i < _logements.length; i++) {
//         final logement = _logements[i];
//         final isFavori = await _favorisRepository.estFavori(logement.id);
//         if (isFavori != logement.isFavori) {
//           _logements[i] = logement.copyWith(isFavori: isFavori);
//         }
//       }
      
//       // Même chose pour myLogements
//       for (var i = 0; i < _myLogements.length; i++) {
//         final logement = _myLogements[i];
//         final isFavori = await _favorisRepository.estFavori(logement.id);
//         if (isFavori != logement.isFavori) {
//           _myLogements[i] = logement.copyWith(isFavori: isFavori);
//         }
//       }
      
//       notifyListeners();
//     } catch (e) {
//       print('⚠️ Erreur vérification favoris: $e');
//     }
//   }

// // Ajoute dans la classe LogementViewModel :

// // Méthode pour vider tous les favoris
// Future<void> clearFavorites() async {
//   try {
//     _isLoading = true;
//     notifyListeners();
    
//     // Supprimer chaque favori de Firestore
//     for (final logement in _favoris) {
//       await _favorisRepository.retirerFavori(logement.id);
//     }
    
//     // Vider la liste locale
//     _favoris.clear();
    
//     // Mettre à jour le statut isFavori pour tous les logements
//     for (var i = 0; i < _logements.length; i++) {
//       if (_logements[i].isFavori) {
//         _logements[i] = _logements[i].copyWith(isFavori: false);
//       }
//     }
    
//     for (var i = 0; i < _myLogements.length; i++) {
//       if (_myLogements[i].isFavori) {
//         _myLogements[i] = _myLogements[i].copyWith(isFavori: false);
//       }
//     }
    
//     print('✅ Tous les favoris ont été supprimés');
    
//   } catch (e) {
//     _errorMessage = 'Erreur suppression favoris: $e';
//     print('❌ Erreur clearFavorites: $e');
//     rethrow;
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }



// // Méthode pour charger les logements favoris uniquement
// Future<void> loadFavoriteLogements() async {
//   _isLoading = true;
//   _errorMessage = null;
//   notifyListeners();
  
//   try {
//     // Charger d'abord tous les logements
//     await loadAllLogements();
    
//     // Filtrer pour garder seulement les favoris
//     _favoris = _logements.where((logement) => logement.isFavori).toList();
    
//   } catch (e) {
//     _errorMessage = 'Erreur chargement favoris: $e';
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }


  
//   // ========== CHARGEMENT LOGEMENTS ==========
  
//   // Convertir Stream en Future pour getAllLogements
//   Future<void> loadAllLogements() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       // Convertir le Stream en Future
//       final stream = _repository.getAllLogements();
//       await for (final logements in stream) {
//         _logements = logements;
//         break; // Prend seulement le premier résultat
//       }
      
//       // Vérifier les favoris pour chaque logement
//       await _checkFavorisStatus();
      
//       _errorMessage = null;
//     } catch (error) {
//       _errorMessage = 'Erreur chargement: $error';
//       print('❌ Erreur loadAllLogements: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Convertir Stream en Future pour getLogementsByOwner
//   Future<void> loadMyLogements(String ownerId) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       // Convertir le Stream en Future
//       final stream = _repository.getLogementsByOwner(ownerId);
//       await for (final logements in stream) {
//         _myLogements = logements;
//         break; // Prend seulement le premier résultat
//       }
      
//       // Vérifier les favoris pour chaque logement
//       await _checkFavorisStatus();
      
//       _errorMessage = null;
//     } catch (error) {
//       _errorMessage = 'Erreur chargement: $error';
//       print('❌ Erreur loadMyLogements: $error');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Méthode alternative plus simple (si tu veux modifier le repository)
//   Future<void> loadAllLogementsSimple() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       // Attendre le premier résultat du Stream
//       _logements = await _repository.getAllLogements().first;
      
//       await _checkFavorisStatus();
      
//       _errorMessage = null;
//     } catch (error) {
//       _errorMessage = 'Erreur chargement: $error';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // ========== GESTION IMAGES ==========
//   Future<void> selectLogementImages() async {
//     try {
//       List<File> images = await _imageService.pickMultipleImages();
//       if (images.isNotEmpty) {
//         _selectedImages = images;
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur sélection images: $e';
//       notifyListeners();
//     }
//   }
  
//   Future<void> addSingleImage() async {
//     try {
//       File? image = await _imageService.pickImage();
//       if (image != null) {
//         _selectedImages.add(image);
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur ajout image: $e';
//       notifyListeners();
//     }
//   }
  
//   void removeSelectedImage(int index) {
//     if (index >= 0 && index < _selectedImages.length) {
//       _selectedImages.removeAt(index);
//       notifyListeners();
//     }
//   }
  
//   Future<List<String>> uploadLogementImages({
//     required String userId,
//     required String logementId,
//   }) async {
//     if (_selectedImages.isEmpty) return [];
    
//     _isUploadingImages = true;
//     _uploadProgress = 0.0;
//     notifyListeners();
    
//     try {
//       List<String> imageUrls = await _storageService.uploadMultipleImages(
//         imageFiles: _selectedImages,
//         userId: userId,
//         folder: 'logements/$logementId',
//       );
      
//       _uploadProgress = 100.0;
//       _isUploadingImages = false;
//       notifyListeners();
      
//       return imageUrls;
//     } catch (e) {
//       _errorMessage = 'Erreur upload images: $e';
//       _isUploadingImages = false;
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // ========== CRUD LOGEMENTS ==========
//   Future<bool> addLogementWithImages(Logement logement, String userId) async {
//     _isLoading = true;
//     _isUploadingImages = true;
//     notifyListeners();
    
//     try {
//       await _repository.addLogement(logement);
      
//       if (_selectedImages.isNotEmpty) {
//         List<String> imageUrls = await uploadLogementImages(
//           userId: userId,
//           logementId: logement.id,
//         );
        
//         Logement updatedLogement = logement.copyWith(images: imageUrls);
//         await _repository.updateLogement(updatedLogement);
//         logement = updatedLogement;
//       }
      
//       _logements.add(logement);
//       if (logement.proprietaireId == userId) {
//         _myLogements.add(logement);
//       }
      
//       _selectedImages.clear();
//       _errorMessage = null;
//       return true;
      
//     } catch (e) {
//       _errorMessage = 'Erreur ajout logement: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       _isUploadingImages = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> addLogement(Logement logement) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       await _repository.addLogement(logement);
//       _logements.add(logement);
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur ajout: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> updateLogement(Logement logement) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       await _repository.updateLogement(logement);
//       _updateLocalLogement(logement);
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur mise à jour: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> deleteLogement(String logementId) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       Logement? logement = _findLogementById(logementId);
      
//       if (logement != null && logement.images.isNotEmpty) {
//         for (String url in logement.images) {
//           try {
//             await _storageService.deleteImage(url);
//           } catch (e) {
//             debugPrint('Erreur suppression image: $e');
//           }
//         }
//       }
      
//       // Supprimer aussi des favoris si présent
//       _favoris.removeWhere((l) => l.id == logementId);
      
//       await _repository.deleteLogement(logementId);
      
//       _logements.removeWhere((l) => l.id == logementId);
//       _myLogements.removeWhere((l) => l.id == logementId);
      
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur suppression: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // ========== MÉTHODES UTILITAIRES ==========
//   Logement? _findLogementById(String logementId) {
//     try {
//       return _logements.firstWhere((l) => l.id == logementId);
//     } catch (e) {
//       try {
//         return _myLogements.firstWhere((l) => l.id == logementId);
//       } catch (e) {
//         return null;
//       }
//     }
//   }
  
//   void _updateLocalLogement(Logement updatedLogement) {
//     int index = _logements.indexWhere((l) => l.id == updatedLogement.id);
//     if (index != -1) {
//       _logements[index] = updatedLogement;
//     }
    
//     index = _myLogements.indexWhere((l) => l.id == updatedLogement.id);
//     if (index != -1) {
//       _myLogements[index] = updatedLogement;
//     }
    
//     // Mettre à jour aussi dans les favoris si présent
//     index = _favoris.indexWhere((l) => l.id == updatedLogement.id);
//     if (index != -1) {
//       _favoris[index] = updatedLogement;
//     }
//   }
  
//   void clearSelectedImages() {
//     _selectedImages.clear();
//     notifyListeners();
//   }
  
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
  
//   // Filtrer les logements
//   List<Logement> filterLogements({
//     String? searchQuery,
//     double? minPrice,
//     double? maxPrice,
//     int? minRooms,
//     int? maxRooms,
//     bool? availableOnly,
//     bool? favoritesOnly,
//   }) {
//     List<Logement> filtered = _logements;
    
//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       filtered = filtered.where((logement) {
//         return logement.titre.toLowerCase().contains(searchQuery.toLowerCase()) ||
//                logement.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
//                logement.adresse.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();
//     }
    
//     if (minPrice != null) {
//       filtered = filtered.where((logement) => logement.prix >= minPrice).toList();
//     }
    
//     if (maxPrice != null) {
//       filtered = filtered.where((logement) => logement.prix <= maxPrice).toList();
//     }
    
//     if (minRooms != null) {
//       filtered = filtered.where((logement) => logement.nombreChambres >= minRooms).toList();
//     }
    
//     if (maxRooms != null) {
//       filtered = filtered.where((logement) => logement.nombreChambres <= maxRooms).toList();
//     }
    
//     if (availableOnly == true) {
//       filtered = filtered.where((logement) => logement.disponible).toList();
//     }
    
//     if (favoritesOnly == true) {
//       filtered = filtered.where((logement) => logement.isFavori).toList();
//     }
    
//     return filtered;
//   }
  
//   // Obtenir les logements favoris
//   List<Logement> getFavoriteLogements() {
//     return _logements.where((logement) => logement.isFavori).toList();
//   }
  
//   // Méthode pour recharger (rafraîchir)
//   Future<void> refresh() async {
//     await loadAllLogements();
//     if (_favoris.isNotEmpty) {
//       await loadFavoris();
//     }
//   }
// }









//============================================================

// // lib/viewmodels/logement_viewmodel.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../repositories/logement_repository.dart';
// import '../models/logement_model.dart';
// import '../services/storage_service.dart';
// import '../services/image_service.dart';

// class LogementViewModel with ChangeNotifier {
//   final LogementRepository _repository = LogementRepository();
//   final StorageService _storageService = StorageService();
//   final ImageService _imageService = ImageService();
  
//   List<Logement> _logements = [];
//   List<Logement> _myLogements = [];
//   List<Logement> _favoris = [];
//   bool _isLoading = false;
//   bool _isUploadingImages = false;
//   String? _errorMessage;
  
//   // Gestion des images sélectionnées
//   List<File> _selectedImages = [];
//   double _uploadProgress = 0.0;
  
//   List<Logement> get logements => _logements;
//   List<Logement> get myLogements => _myLogements;
//   List<Logement> get favoris => _favoris;
//   bool get isLoading => _isLoading;
//   bool get isUploadingImages => _isUploadingImages;
//   String? get errorMessage => _errorMessage;
//   List<File> get selectedImages => _selectedImages;
//   double get uploadProgress => _uploadProgress;
  
//   // ========== MÉTHODES FAVORIS ==========
//   bool isFavorite(String logementId) {
//     return _favoris.any((l) => l.id == logementId);
//   }

//   void addFavorite(Logement logement) {
//     if (!isFavorite(logement.id)) {
//       _favoris.add(logement);
//       notifyListeners();
//     }
//   }

//   void removeFavorite(String logementId) {
//     _favoris.removeWhere((l) => l.id == logementId);
//     notifyListeners();
//   }

//   void clearFavorites() {
//     _favoris.clear();
//     notifyListeners();
//   }
  
//   // ========== CHARGEMENT LOGEMENTS ==========
//   void loadAllLogements() {
//     _isLoading = true;
//     notifyListeners();
    
//     _repository.getAllLogements().listen((logements) {
//       _logements = logements;
//       _isLoading = false;
//       _errorMessage = null;
//       notifyListeners();
//     }, onError: (error) {
//       _errorMessage = 'Erreur chargement: $error';
//       _isLoading = false;
//       notifyListeners();
//     });
//   }
  
//   void loadMyLogements(String ownerId) {
//     _isLoading = true;
//     notifyListeners();
    
//     _repository.getLogementsByOwner(ownerId).listen((logements) {
//       _myLogements = logements;
//       _isLoading = false;
//       _errorMessage = null;
//       notifyListeners();
//     }, onError: (error) {
//       _errorMessage = 'Erreur chargement: $error';
//       _isLoading = false;
//       notifyListeners();
//     });
//   }
  
//   // ========== GESTION IMAGES ==========
//   Future<void> selectLogementImages() async {
//     try {
//       List<File> images = await _imageService.pickMultipleImages();
//       if (images.isNotEmpty) {
//         _selectedImages = images;
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur sélection images: $e';
//       notifyListeners();
//     }
//   }
  
//   Future<void> addSingleImage() async {
//     try {
//       File? image = await _imageService.pickImage();
//       if (image != null) {
//         _selectedImages.add(image);
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur ajout image: $e';
//       notifyListeners();
//     }
//   }
  
//   void removeSelectedImage(int index) {
//     if (index >= 0 && index < _selectedImages.length) {
//       _selectedImages.removeAt(index);
//       notifyListeners();
//     }
//   }
  
//   Future<List<String>> uploadLogementImages({
//     required String userId,
//     required String logementId,
//   }) async {
//     if (_selectedImages.isEmpty) return [];
    
//     _isUploadingImages = true;
//     _uploadProgress = 0.0;
//     notifyListeners();
    
//     try {
//       List<String> imageUrls = await _storageService.uploadMultipleImages(
//         imageFiles: _selectedImages,
//         userId: userId,
//         folder: 'logements/$logementId',
//       );
      
//       _uploadProgress = 100.0;
//       _isUploadingImages = false;
//       notifyListeners();
      
//       return imageUrls;
//     } catch (e) {
//       _errorMessage = 'Erreur upload images: $e';
//       _isUploadingImages = false;
//       notifyListeners();
//       rethrow;
//     }
//   }
  
//   // ========== CRUD LOGEMENTS ==========
//   Future<bool> addLogementWithImages(Logement logement, String userId) async {
//     _isLoading = true;
//     _isUploadingImages = true;
//     notifyListeners();
    
//     try {
//       await _repository.addLogement(logement);
      
//       if (_selectedImages.isNotEmpty) {
//         List<String> imageUrls = await uploadLogementImages(
//           userId: userId,
//           logementId: logement.id,
//         );
        
//         Logement updatedLogement = logement.copyWith(images: imageUrls);
//         await _repository.updateLogement(updatedLogement);
//         logement = updatedLogement;
//       }
      
//       _logements.add(logement);
//       if (logement.proprietaireId == userId) {
//         _myLogements.add(logement);
//       }
      
//       _selectedImages.clear();
//       _errorMessage = null;
//       return true;
      
//     } catch (e) {
//       _errorMessage = 'Erreur ajout logement: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       _isUploadingImages = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> addLogement(Logement logement) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       await _repository.addLogement(logement);
//       _logements.add(logement);
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur ajout: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> updateLogement(Logement logement) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       await _repository.updateLogement(logement);
//       _updateLocalLogement(logement);
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur mise à jour: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   Future<bool> deleteLogement(String logementId) async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       Logement? logement = _findLogementById(logementId);
      
//       if (logement != null && logement.images.isNotEmpty) {
//         for (String url in logement.images) {
//           try {
//             await _storageService.deleteImage(url);
//           } catch (e) {
//             debugPrint('Erreur suppression image: $e');
//           }
//         }
//       }
      
//       await _repository.deleteLogement(logementId);
      
//       _logements.removeWhere((l) => l.id == logementId);
//       _myLogements.removeWhere((l) => l.id == logementId);
      
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur suppression: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // ========== MÉTHODES UTILITAIRES ==========
//   Logement? _findLogementById(String logementId) {
//     try {
//       return _logements.firstWhere((l) => l.id == logementId);
//     } catch (e) {
//       try {
//         return _myLogements.firstWhere((l) => l.id == logementId);
//       } catch (e) {
//         return null;
//       }
//     }
//   }
  
//   void _updateLocalLogement(Logement updatedLogement) {
//     int index = _logements.indexWhere((l) => l.id == updatedLogement.id);
//     if (index != -1) {
//       _logements[index] = updatedLogement;
//     }
    
//     index = _myLogements.indexWhere((l) => l.id == updatedLogement.id);
//     if (index != -1) {
//       _myLogements[index] = updatedLogement;
//     }
//   }
  
//   void clearSelectedImages() {
//     _selectedImages.clear();
//     notifyListeners();
//   }
  
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }



