import 'package:flutter/material.dart';
import '../repositories/admin_repository.dart';
import '../models/utilisateur_model.dart';
import '../models/logement_model.dart';

/// ViewModel pour gérer les fonctionnalités administrateur
class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  // États pour les statistiques
  int _totalUsers = 0;
  int _totalLogements = 0;
  int _totalOwners = 0;
  int _totalAdmins = 0;
  int _activeLogements = 0;
  int _inactiveLogements = 0;
  
  // États pour les listes
  List<Utilisateur> _allUsers = [];
  List<Logement> _allLogements = [];
  List<Utilisateur> _recentUsers = [];
  List<Logement> _recentLogements = [];
  
  // États d'interface
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _statistics = {};

  // Getters
  int get totalUsers => _totalUsers;
  int get totalLogements => _totalLogements;
  int get totalOwners => _totalOwners;
  int get totalAdmins => _totalAdmins;
  int get activeLogements => _activeLogements;
  int get inactiveLogements => _inactiveLogements;
  
  List<Utilisateur> get allUsers => _allUsers;
  List<Logement> get allLogements => _allLogements;
  List<Utilisateur> get recentUsers => _recentUsers;
  List<Logement> get recentLogements => _recentLogements;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get statistics => _statistics;

  /// Charge toutes les statistiques administratives
  Future<void> loadStatistics() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Charger les statistiques de base
      _totalUsers = await _repository.getTotalUsers();
      _totalLogements = await _repository.getTotalLogements();
      
      // Charger les statistiques détaillées
      final stats = await _repository.getDetailedStatistics();
      _totalOwners = stats['totalOwners'] ?? 0;
      _totalAdmins = stats['totalAdmins'] ?? 0;
      _activeLogements = stats['activeLogements'] ?? 0;
      _inactiveLogements = stats['inactiveLogements'] ?? 0;
      
      // Calculer les pourcentages
      final ownerPercentage = _totalUsers > 0 
          ? (_totalOwners / _totalUsers * 100).round() 
          : 0;
      
      final activePercentage = _totalLogements > 0
          ? (_activeLogements / _totalLogements * 100).round()
          : 0;
      
      // Préparer l'objet de statistiques
      _statistics = {
        'totalUsers': _totalUsers,
        'totalLogements': _totalLogements,
        'totalOwners': _totalOwners,
        'totalAdmins': _totalAdmins,
        'activeLogements': _activeLogements,
        'inactiveLogements': _inactiveLogements,
        'ownerPercentage': ownerPercentage,
        'activePercentage': activePercentage,
        'avgLogementsPerOwner': _totalOwners > 0 
            ? (_totalLogements / _totalOwners).toStringAsFixed(1)
            : '0',
        'lastUpdated': DateTime.now(),
      };
      
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statistiques: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Charge tous les utilisateurs
  Future<void> loadAllUsers() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _allUsers = await _repository.getAllUsers();
      
      // Filtrer les utilisateurs récents (7 derniers jours)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      _recentUsers = _allUsers.where((user) {
        return user.dateCreation.isAfter(sevenDaysAgo);
      }).toList();
      
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des utilisateurs: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Charge tous les logements
  Future<void> loadAllLogements() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      _allLogements = await _repository.getAllLogements();
      
      // Filtrer les logements récents (7 derniers jours)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      _recentLogements = _allLogements.where((logement) {
        return logement.datePublication.isAfter(sevenDaysAgo);
      }).toList();
      
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des logements: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Met à jour le rôle d'un utilisateur
  Future<bool> updateUserRole(String userId, String newRole) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _repository.updateUserRole(userId, newRole);
      
      if (success) {
        // Mettre à jour la liste locale
        final index = _allUsers.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _allUsers[index] = _allUsers[index].copyWith(role: newRole);
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du rôle: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprime un utilisateur
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _repository.deleteUser(userId);
      
      if (success) {
        // Retirer de la liste locale
        _allUsers.removeWhere((user) => user.id == userId);
        _recentUsers.removeWhere((user) => user.id == userId);
        _totalUsers--;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprime un logement
  Future<bool> deleteLogement(String logementId) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _repository.deleteLogement(logementId);
      
      if (success) {
        // Retirer de la liste locale
        _allLogements.removeWhere((logement) => logement.id == logementId);
        _recentLogements.removeWhere((logement) => logement.id == logementId);
        _totalLogements--;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du logement: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Active/désactive un logement
  Future<bool> toggleLogementStatus(String logementId, bool isActive) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _repository.updateLogementStatus(logementId, isActive);
      
      if (success) {
        // Mettre à jour la liste locale
        final index = _allLogements.indexWhere((logement) => logement.id == logementId);
        if (index != -1) {
          _allLogements[index] = _allLogements[index].copyWith(disponible: isActive);
          
          // Mettre à jour les compteurs
          if (isActive) {
            _activeLogements++;
            _inactiveLogements--;
          } else {
            _activeLogements--;
            _inactiveLogements++;
          }
          
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors du changement de statut: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Récupère les activités récentes
  Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      return await _repository.getRecentActivities();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des activités: $e';
      return {};
    }
  }

  /// Recherche des utilisateurs
  List<Utilisateur> searchUsers(String query) {
    if (query.isEmpty) return _allUsers;
    
    return _allUsers.where((user) {
      return user.nom.toLowerCase().contains(query.toLowerCase()) ||
             user.email.toLowerCase().contains(query.toLowerCase()) ||
             user.role.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Recherche des logements
  List<Logement> searchLogements(String query) {
    if (query.isEmpty) return _allLogements;
    
    return _allLogements.where((logement) {
      return logement.titre.toLowerCase().contains(query.toLowerCase()) ||
             logement.adresse.toLowerCase().contains(query.toLowerCase()) ||
             logement.description.toLowerCase().contains(query.toLowerCase()) ||
             logement.proprietaireId.contains(query);
    }).toList();
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

  /// Récupère les données de graphique pour les utilisateurs
  Map<String, int> getUserChartData() {
    final Map<String, int> data = {};
    
    for (var user in _allUsers) {
      final role = user.role;
      data[role] = (data[role] ?? 0) + 1;
    }
    
    return data;
  }

  /// Récupère les données de graphique pour les logements
  Map<String, int> getLogementChartData() {
    final Map<String, int> data = {};
    
    // Grouper par prix (par tranches de 100€)
    for (var logement in _allLogements) {
      final priceRange = '${(logement.prix ~/ 100) * 100}-${(logement.prix ~/ 100) * 100 + 99}€';
      data[priceRange] = (data[priceRange] ?? 0) + 1;
    }
    
    return data;
  }
}





// import 'package:flutter/material.dart';
// import '../repositories/admin_repository.dart';
// import '../models/utilisateur_model.dart';

// /// ViewModel pour gérer les statistiques de l'admin
// class AdminViewModel extends ChangeNotifier {
//   final AdminRepository _repository = AdminRepository();

//   int totalUsers = 0;
//   int totalLogements = 0;
//   int totalMessages = 0;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   /// Charge les statistiques depuis le repository
//   Future<void> loadStatistics() async {
//     _setLoading(true);

//     totalUsers = await _repository.getTotalUsers();
//     totalLogements = await _repository.getTotalLogements();
//     //totalMessages = await _repository.getTotalMessages(); //

//     _setLoading(false);
//   }

//   /// Méthode interne pour gérer l'état de chargement
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
