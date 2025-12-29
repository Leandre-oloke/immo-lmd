import 'package:flutter/material.dart';
import '../repositories/logement_repository.dart';
import '../models/logement_model.dart';

/// ViewModel pour gérer les fonctionnalités spécifiques aux propriétaires
class OwnerViewModel extends ChangeNotifier {
  final LogementRepository _repository = LogementRepository();
  
  // États
  List<Logement> _myLogements = [];
  List<Logement> _availableLogements = [];
  List<Logement> _occupiedLogements = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _ownerStats = {};
  
  // Getters
  List<Logement> get myLogements => _myLogements;
  List<Logement> get availableLogements => _availableLogements;
  List<Logement> get occupiedLogements => _occupiedLogements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get ownerStats => _ownerStats;
  
  /// Charge tous les logements d'un propriétaire
  Future<void> loadOwnerLogements(String ownerId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Charger tous les logements du propriétaire
      _repository.getLogementsByOwner(ownerId).listen((logements) {
        _myLogements = logements;
        
        // Filtrer par disponibilité
        _availableLogements = logements.where((logement) => logement.disponible).toList();
        _occupiedLogements = logements.where((logement) => !logement.disponible).toList();
        
        // Calculer les statistiques
        _calculateOwnerStats();
        
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
  
  /// Calcule les statistiques du propriétaire
  void _calculateOwnerStats() {
    final total = _myLogements.length;
    final available = _availableLogements.length;
    final occupied = _occupiedLogements.length;
    
    // Calculer le revenu mensuel estimé
    double estimatedRevenue = 0;
    for (var logement in _occupiedLogements) {
      estimatedRevenue += logement.prix;
    }
    
    // Calculer le taux d'occupation
    double occupancyRate = total > 0 ? (occupied / total * 100) : 0;
    
    // Trouver le logement le plus cher
    double highestPrice = 0;
    if (_myLogements.isNotEmpty) {
      highestPrice = _myLogements
          .map((logement) => logement.prix)
          .reduce((a, b) => a > b ? a : b);
    }
    
    // Trouver le logement le moins cher
    double lowestPrice = 0;
    if (_myLogements.isNotEmpty) {
      lowestPrice = _myLogements
          .map((logement) => logement.prix)
          .reduce((a, b) => a < b ? a : b);
    }
    
    // Calculer le prix moyen
    double averagePrice = 0;
    if (_myLogements.isNotEmpty) {
      final totalPrice = _myLogements.fold(0.0, (sum, logement) => sum + logement.prix);
      averagePrice = totalPrice / total;
    }
    
    _ownerStats = {
      'totalLogements': total,
      'availableLogements': available,
      'occupiedLogements': occupied,
      'estimatedRevenue': estimatedRevenue,
      'occupancyRate': occupancyRate.round(),
      'highestPrice': highestPrice,
      'lowestPrice': lowestPrice,
      'averagePrice': averagePrice.toStringAsFixed(2),
      'lastUpdated': DateTime.now(),
    };
    
    notifyListeners();
  }
  
  /// Ajoute un nouveau logement
  Future<bool> addLogement(Logement logement) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _repository.addLogement(logement);
      
      // Ajouter à la liste locale
      _myLogements.add(logement);
      if (logement.disponible) {
        _availableLogements.add(logement);
      } else {
        _occupiedLogements.add(logement);
      }
      
      // Recalculer les statistiques
      _calculateOwnerStats();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur ajout logement: $e';
      _setLoading(false);
      return false;
    }
  }
  
  /// Supprime un logement
  Future<bool> deleteLogement(String logementId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _repository.deleteLogement(logementId);
      
      // Retirer des listes locales
      _myLogements.removeWhere((logement) => logement.id == logementId);
      _availableLogements.removeWhere((logement) => logement.id == logementId);
      _occupiedLogements.removeWhere((logement) => logement.id == logementId);
      
      // Recalculer les statistiques
      _calculateOwnerStats();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression logement: $e';
      _setLoading(false);
      return false;
    }
  }
  
  /// Change le statut de disponibilité d'un logement
  Future<bool> toggleLogementAvailability(String logementId, bool isAvailable) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Trouver le logement
      final index = _myLogements.indexWhere((logement) => logement.id == logementId);
      if (index == -1) {
        _errorMessage = 'Logement non trouvé';
        _setLoading(false);
        return false;
      }
      
      final logement = _myLogements[index];
      final updatedLogement = logement.copyWith(disponible: isAvailable);
      
      // Mettre à jour dans Firestore
      await _repository.updateLogement(updatedLogement);
      
      // Mettre à jour les listes locales
      _myLogements[index] = updatedLogement;
      
      if (isAvailable) {
        // Déplacer de occupé à disponible
        _occupiedLogements.removeWhere((logement) => logement.id == logementId);
        _availableLogements.add(updatedLogement);
      } else {
        // Déplacer de disponible à occupé
        _availableLogements.removeWhere((logement) => logement.id == logementId);
        _occupiedLogements.add(updatedLogement);
      }
      
      // Recalculer les statistiques
      _calculateOwnerStats();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur changement statut: $e';
      _setLoading(false);
      return false;
    }
  }
  
  /// Filtre les logements par prix
  List<Logement> filterByPriceRange(double minPrice, double maxPrice) {
    return _myLogements.where((logement) {
      return logement.prix >= minPrice && logement.prix <= maxPrice;
    }).toList();
  }
  
  /// Filtre les logements par superficie
  List<Logement> filterBySuperficieRange(int minSuperficie, int maxSuperficie) {
    return _myLogements.where((logement) {
      return logement.superficie >= minSuperficie && logement.superficie <= maxSuperficie;
    }).toList();
  }
  
  /// Filtre les logements par nombre de chambres
  List<Logement> filterByChambres(int minChambres, int maxChambres) {
    return _myLogements.where((logement) {
      return logement.nombreChambres >= minChambres && logement.nombreChambres <= maxChambres;
    }).toList();
  }
  
  /// Recherche dans les logements
  List<Logement> searchLogements(String query) {
    if (query.isEmpty) return _myLogements;
    
    return _myLogements.where((logement) {
      return logement.titre.toLowerCase().contains(query.toLowerCase()) ||
             logement.description.toLowerCase().contains(query.toLowerCase()) ||
             logement.adresse.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  /// Trie les logements par critère
  List<Logement> sortLogements(String criteria, {bool ascending = true}) {
    List<Logement> sortedList = List.from(_myLogements);
    
    switch (criteria) {
      case 'prix':
        sortedList.sort((a, b) => ascending 
            ? a.prix.compareTo(b.prix)
            : b.prix.compareTo(a.prix));
        break;
      case 'superficie':
        sortedList.sort((a, b) => ascending
            ? a.superficie.compareTo(b.superficie)
            : b.superficie.compareTo(a.superficie));
        break;
      case 'date':
        sortedList.sort((a, b) => ascending
            ? a.datePublication.compareTo(b.datePublication)
            : b.datePublication.compareTo(a.datePublication));
        break;
      case 'chambres':
        sortedList.sort((a, b) => ascending
            ? a.nombreChambres.compareTo(b.nombreChambres)
            : b.nombreChambres.compareTo(a.nombreChambres));
        break;
      default:
        sortedList.sort((a, b) => ascending
            ? a.titre.compareTo(b.titre)
            : b.titre.compareTo(a.titre));
    }
    
    return sortedList;
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