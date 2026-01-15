import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/utilisateur_model.dart';
import '../../views/auth/change_password_page.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  Utilisateur? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  Utilisateur? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialiser l'utilisateur
  Future<void> initializeUser() async {
    print("🔄 [DEBUG] Début de initializeUser()");
    
    _isLoading = true;
    
    try {
      print("🔍 [DEBUG] Appel à _authRepository.getCurrentUser()");
      _currentUser = await _authRepository.getCurrentUser();
      
      if (_currentUser != null) {
        print("✅ [DEBUG] Utilisateur trouvé: ${_currentUser!.email}, Rôle: ${_currentUser!.role}");
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
    }
  }
  
  // Méthode wrapper qui gère les notifications correctement
  Future<void> loadUserWithNotifications() async {
    print("🚀 [DEBUG] loadUserWithNotifications() appelée");
    _isLoading = true;
    notifyListeners();
    
    await initializeUser();
    
    _isLoading = false;
    notifyListeners();
    print("✅ [DEBUG] loadUserWithNotifications() terminée");
  }
  
  // Inscription AVEC RÔLE (5 paramètres)
  Future<bool> register(String email, String password, String nom, String telephone, String role) async {
    print("📝 [DEBUG] Début register() avec rôle: $role");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print("🔐 [DEBUG] Appel au repository register avec rôle: $role");
      // Appel à la méthode repository mise à jour
      await _authRepository.register(email, password, nom, telephone, role);
      
      print("🔄 [DEBUG] Rechargement de l'utilisateur après inscription");
      await initializeUser();
      
      print("✅ [DEBUG] Inscription réussie avec rôle: $role");
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
  
  // Connexion
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


// Dans lib/viewmodels/auth_viewmodel.dart ==========================
// Méthode pour changer le mot de passe

Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    // Succès
  } catch (e) {
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}







