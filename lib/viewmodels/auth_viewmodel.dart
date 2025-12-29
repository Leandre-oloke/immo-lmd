import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/utilisateur_model.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  Utilisateur? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  Utilisateur? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialiser l'utilisateur - VERSION CORRIGÉE
  Future<void> initializeUser() async {
    print("🔄 [DEBUG] Début de initializeUser()");
    
    _isLoading = true;
    // ⚠️ IMPORTANT: Ne PAS appeler notifyListeners() ici
    // La méthode est appelée depuis initState(), ce qui causerait l'erreur
    
    try {
      print("🔍 [DEBUG] Appel à _authRepository.getCurrentUser()");
      _currentUser = await _authRepository.getCurrentUser();
      
      if (_currentUser != null) {
        print("✅ [DEBUG] Utilisateur trouvé: ${_currentUser!.email}");
      } else {
        print("👤 [DEBUG] Aucun utilisateur connecté");
      }
      
      _errorMessage = null;
      print("🎉 [DEBUG] initializeUser() terminé avec succès");
      
    } catch (e, stackTrace) {
      _errorMessage = 'Erreur chargement utilisateur: $e';
      print("❌ [DEBUG] ERREUR dans initializeUser(): $e");
      print("📝 [DEBUG] Stack trace: $stackTrace");
    } finally {
      _isLoading = false;
      print("🏁 [DEBUG] Finalisation de initializeUser()");
      // ⚠️ Ne pas notifier ici non plus - la notification sera faite par la méthode wrapper
    }
  }
  
  // Méthode wrapper qui gère les notifications correctement
  Future<void> loadUserWithNotifications() async {
    print("🚀 [DEBUG] loadUserWithNotifications() appelée");
    _isLoading = true;
    notifyListeners(); // OK ici, pas pendant le build
    
    await initializeUser();
    
    _isLoading = false;
    notifyListeners(); // Notification finale
    print("✅ [DEBUG] loadUserWithNotifications() terminée");
  }
  
  // Inscription - VERSION CORRIGÉE
  Future<bool> register(String email, String password, String nom, String telephone) async {
    print("📝 [DEBUG] Début register()");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print("🔐 [DEBUG] Appel au repository register");
      await _authRepository.register(email, password, nom, telephone);
      
      print("🔄 [DEBUG] Rechargement de l'utilisateur après inscription");
      await initializeUser();
      
      print("✅ [DEBUG] Inscription réussie");
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Erreur inscription: $e';
      print("❌ [DEBUG] ERREUR register(): $e");
      print("📝 [DEBUG] Stack trace: $stackTrace");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      print("🏁 [DEBUG] Fin register()");
    }
  }
  
  // Connexion - VERSION CORRIGÉE
  Future<bool> login(String email, String password) async {
    print("🔑 [DEBUG] Début login()");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print("🔐 [DEBUG] Appel au repository login");
      await _authRepository.login(email, password);
      
      print("🔄 [DEBUG] Rechargement de l'utilisateur après connexion");
      await initializeUser();
      
      print("✅ [DEBUG] Connexion réussie");
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Erreur connexion: $e';
      print("❌ [DEBUG] ERREUR login(): $e");
      print("📝 [DEBUG] Stack trace: $stackTrace");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      print("🏁 [DEBUG] Fin login()");
    }
  }
  
  // Déconnexion
  Future<void> logout() async {
    print("🚪 [DEBUG] Début logout()");
    
    try {
      await _authRepository.logout();
      _currentUser = null;
      _errorMessage = null;
      print("✅ [DEBUG] Déconnexion réussie");
    } catch (e, stackTrace) {
      _errorMessage = 'Erreur déconnexion: $e';
      print("❌ [DEBUG] ERREUR logout(): $e");
      print("📝 [DEBUG] Stack trace: $stackTrace");
    } finally {
      notifyListeners();
      print("🏁 [DEBUG] Fin logout()");
    }
  }
  
  // Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Méthode pour mettre à jour l'utilisateur localement
  void updateLocalUser(Utilisateur updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
  
  // Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _currentUser != null;
  
  // Vérifier le rôle de l'utilisateur
  String? get userRole => _currentUser?.role;
  
  // Vérifier si l'utilisateur est admin
  bool get isAdmin => _currentUser?.role == 'admin';
  
  // Vérifier si l'utilisateur est propriétaire
  bool get isOwner => _currentUser?.role == 'owner';
  
  // Vérifier si l'utilisateur est utilisateur standard
  bool get isStandardUser => _currentUser?.role == 'user';
}






// import 'package:flutter/material.dart';
// import '../repositories/auth_repository.dart';
// import '../models/utilisateur_model.dart';

// class AuthViewModel with ChangeNotifier {
//   final AuthRepository _authRepository = AuthRepository();
  
//   Utilisateur? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;
  
//   Utilisateur? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
  
//   // Initialiser l'utilisateur
//   Future<void> initializeUser() async {
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       _currentUser = await _authRepository.getCurrentUser();
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Erreur lors du chargement: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Inscription
//   Future<bool> register(String email, String password, String nom, String telephone) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       await _authRepository.register(email, password, nom, telephone);
//       await initializeUser();
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur inscription: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Connexion
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
    
//     try {
//       await _authRepository.login(email, password);
//       await initializeUser();
//       return true;
//     } catch (e) {
//       _errorMessage = 'Erreur connexion: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   // Déconnexion
//   Future<void> logout() async {
//     await _authRepository.logout();
//     _currentUser = null;
//     notifyListeners();
//   }
  
//   // Effacer l'erreur
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }


