import 'package:flutter/material.dart';
import '../repositories/logement_repository.dart';
import '../models/logement_model.dart';

/// ViewModel pour gérer les fonctionnalités spécifiques aux utilisateurs (locataires)
class UsersViewModel extends ChangeNotifier {
  final LogementRepository _repository = LogementRepository();
  
  // États
  List<Logement> _allLogements = [];
  List<Logement> _filteredLogements = [];
  List<Logement> _favoriteLogements = [];
  List<Logement> _recentlyViewed = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _searchFilters = {};
  String _searchQuery = '';
  
  // Getters
  List<Logement> get allLogements => _allLogements;
  List<Logement> get filteredLogements => _filteredLogements;
  List<Logement> get favoriteLogements => _favoriteLogements;
  List<Logement> get recentlyViewed => _recentlyViewed;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get searchFilters => _searchFilters;
  String get searchQuery => _searchQuery;
  
  /// Charge tous les logements disponibles
  Future<void> loadAllLogements() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _repository.getAllLogements().listen((logements) {
        _allLogements = logements;
        _filteredLogements = List.from(logements); // Initialiser avec tous les logements
        _applyFilters();
        _setLoading(false);
      }, onError: (error) {
        _errorMessage = 'Erreur chargement logements: $error';
        _setLoading(false);
      });
      
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      _setLoading(false);
    }
  }
  
  /// Définit les filtres de recherche
  void setSearchFilters(Map<String, dynamic> filters) {
    _searchFilters = filters;
    _applyFilters();
    notifyListeners();
  }
  
  /// Définit la requête de recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  
  /// Applique tous les filtres et la recherche
  void _applyFilters() {
    List<Logement> result = List.from(_allLogements);
    
    // Filtrer par disponibilité (seulement les disponibles)
    result = result.where((logement) => logement.disponible).toList();
    
    // Appliquer les filtres
    if (_searchFilters.isNotEmpty) {
      // Filtre par prix
      if (_searchFilters.containsKey('minPrice') && _searchFilters.containsKey('maxPrice')) {
        final minPrice = _searchFilters['minPrice'] as double;
        final maxPrice = _searchFilters['maxPrice'] as double;
        result = result.where((logement) {
          return logement.prix >= minPrice && logement.prix <= maxPrice;
        }).toList();
      }
      
      // Filtre par superficie
      if (_searchFilters.containsKey('minSuperficie') && _searchFilters.containsKey('maxSuperficie')) {
        final minSuperficie = _searchFilters['minSuperficie'] as int;
        final maxSuperficie = _searchFilters['maxSuperficie'] as int;
        result = result.where((logement) {
          return logement.superficie >= minSuperficie && logement.superficie <= maxSuperficie;
        }).toList();
      }
      
      // Filtre par chambres
      if (_searchFilters.containsKey('minChambres') && _searchFilters.containsKey('maxChambres')) {
        final minChambres = _searchFilters['minChambres'] as int;
        final maxChambres = _searchFilters['maxChambres'] as int;
        result = result.where((logement) {
          return logement.nombreChambres >= minChambres && logement.nombreChambres <= maxChambres;
        }).toList();
      }
      
      // Filtre par type (si implémenté)
      if (_searchFilters.containsKey('type') && _searchFilters['type'] != 'Tous') {
        // À adapter si vous avez un champ type dans Logement
      }
    }
    
    // Appliquer la recherche textuelle
    if (_searchQuery.isNotEmpty) {
      result = result.where((logement) {
        return logement.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               logement.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               logement.adresse.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Appliquer le tri
    if (_searchFilters.containsKey('sortBy')) {
      final sortBy = _searchFilters['sortBy'] as String;
      final ascending = _searchFilters['sortAscending'] as bool? ?? true;
      
      switch (sortBy) {
        case 'prix':
          result.sort((a, b) => ascending 
              ? a.prix.compareTo(b.prix)
              : b.prix.compareTo(a.prix));
          break;
        case 'superficie':
          result.sort((a, b) => ascending
              ? a.superficie.compareTo(b.superficie)
              : b.superficie.compareTo(a.superficie));
          break;
        case 'date':
          result.sort((a, b) => ascending
              ? a.datePublication.compareTo(b.datePublication)
              : b.datePublication.compareTo(a.datePublication));
          break;
        case 'chambres':
          result.sort((a, b) => ascending
              ? a.nombreChambres.compareTo(b.nombreChambres)
              : b.nombreChambres.compareTo(a.nombreChambres));
          break;
      }
    }
    
    _filteredLogements = result;
  }
  
  /// Ajoute un logement aux favoris
  Future<void> addToFavorites(Logement logement) async {
    if (!_favoriteLogements.any((fav) => fav.id == logement.id)) {
      _favoriteLogements.add(logement);
      notifyListeners();
      
      // TODO: Sauvegarder dans Firestore ou SharedPreferences
    }
  }
  
  /// Retire un logement des favoris
  Future<void> removeFromFavorites(String logementId) async {
    _favoriteLogements.removeWhere((logement) => logement.id == logementId);
    notifyListeners();
    
    // TODO: Supprimer de Firestore ou SharedPreferences
  }
  
  /// Vérifie si un logement est dans les favoris
  bool isFavorite(String logementId) {
    return _favoriteLogements.any((logement) => logement.id == logementId);
  }
  
  /// Ajoute un logement à l'historique des vues récentes
  void addToRecentlyViewed(Logement logement) {
    // Retirer si déjà présent
    _recentlyViewed.removeWhere((viewed) => viewed.id == logement.id);
    
    // Ajouter au début
    _recentlyViewed.insert(0, logement);
    
    // Garder seulement les 10 derniers
    if (_recentlyViewed.length > 10) {
      _recentlyViewed = _recentlyViewed.sublist(0, 10);
    }
    
    notifyListeners();
    
    // TODO: Sauvegarder dans SharedPreferences
  }
  
  /// Efface l'historique des vues récentes
  void clearRecentlyViewed() {
    _recentlyViewed.clear();
    notifyListeners();
  }
  
  /// Récupère les logements recommandés (basés sur les favoris et l'historique)
  List<Logement> getRecommendedLogements() {
    if (_allLogements.isEmpty) return [];
    
    // Prioriser les logements similaires aux favoris
    final Set<Logement> recommendations = {};
    
    // Basé sur les favoris
    for (var favorite in _favoriteLogements) {
      final similarLogements = _allLogements.where((logement) {
        return logement.id != favorite.id &&
               logement.disponible &&
               (logement.prix >= favorite.prix * 0.8 && logement.prix <= favorite.prix * 1.2) &&
               (logement.superficie >= favorite.superficie * 0.8 && logement.superficie <= favorite.superficie * 1.2);
      }).take(3);
      
      recommendations.addAll(similarLogements);
    }
    
    // Basé sur l'historique récent
    for (var viewed in _recentlyViewed) {
      final similarLogements = _allLogements.where((logement) {
        return logement.id != viewed.id &&
               logement.disponible &&
               !recommendations.any((rec) => rec.id == logement.id) &&
               logement.nombreChambres == viewed.nombreChambres;
      }).take(2);
      
      recommendations.addAll(similarLogements);
    }
    
    // Si pas assez de recommandations, ajouter des logements populaires
    if (recommendations.length < 5) {
      final popularLogements = _allLogements
          .where((logement) => logement.disponible)
          .where((logement) => !recommendations.any((rec) => rec.id == logement.id))
          .take(5 - recommendations.length);
      
      recommendations.addAll(popularLogements);
    }
    
    return recommendations.toList();
  }
  
  /// Récupère les statistiques de recherche
  Map<String, dynamic> getSearchStats() {
    final totalAvailable = _allLogements.where((logement) => logement.disponible).length;
    final filteredCount = _filteredLogements.length;
    
    // Calculer la fourchette de prix des résultats
    double minPrice = 0;
    double maxPrice = 0;
    double avgPrice = 0;
    
    if (_filteredLogements.isNotEmpty) {
      final prices = _filteredLogements.map((logement) => logement.prix).toList();
      minPrice = prices.reduce((a, b) => a < b ? a : b);
      maxPrice = prices.reduce((a, b) => a > b ? a : b);
      avgPrice = prices.fold(0.0, (sum, price) => sum + price) / prices.length;
    }
    
    return {
      'totalAvailable': totalAvailable,
      'filteredCount': filteredCount,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'averagePrice': avgPrice.toStringAsFixed(2),
      'hasFilters': _searchFilters.isNotEmpty || _searchQuery.isNotEmpty,
    };
  }
  
  /// Réinitialise tous les filtres
  void resetFilters() {
    _searchFilters = {};
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }
  
  /// Efface les messages d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Méthode interne pour gérer l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}