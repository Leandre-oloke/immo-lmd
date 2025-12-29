import 'package:flutter/material.dart';
import '../repositories/logement_repository.dart';
import '../models/logement_model.dart';

class LogementViewModel with ChangeNotifier {
  final LogementRepository _repository = LogementRepository();
  
  List<Logement> _logements = [];
  List<Logement> _myLogements = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Logement> get logements => _logements;
  List<Logement> get myLogements => _myLogements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Charger tous les logements
  void loadAllLogements() {
    _isLoading = true;
    notifyListeners();
    
    _repository.getAllLogements().listen((logements) {
      _logements = logements;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Erreur chargement: $error';
      _isLoading = false;
      notifyListeners();
    });
  }
  
  // Charger mes logements (pour propriétaire)
  void loadMyLogements(String ownerId) {
    _isLoading = true;
    notifyListeners();
    
    _repository.getLogementsByOwner(ownerId).listen((logements) {
      _myLogements = logements;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Erreur chargement: $error';
      _isLoading = false;
      notifyListeners();
    });
  }
  
  // Ajouter un logement
  Future<bool> addLogement(Logement logement) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.addLogement(logement);
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
  
  // Supprimer un logement
  Future<bool> deleteLogement(String logementId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deleteLogement(logementId);
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
}







// import 'package:flutter/material.dart';
// import '../services/firebase_service.dart';
// import '../models/logement_model.dart';

// class LogementViewModel extends ChangeNotifier {
//   final FirebaseService _service = FirebaseService();
//   List<LogementModel> logements = [];
//   bool isLoading = false;

//   Future<void> loadLogements() async {
//     isLoading = true;
//     notifyListeners();
//     logements = await _service.getLogements();
//     isLoading = false;
//     notifyListeners();
//   }

//   Future<void> addLogement(LogementModel logement) async {
//     await _service.addLogement(logement);
//     await loadLogements();
//   }
// }
