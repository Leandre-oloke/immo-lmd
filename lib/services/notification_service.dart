import 'package:flutter/material.dart';

/// Service de notifications simplifié (sans Firebase Messaging)
/// Pour notifications locales uniquement
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  final List<NotificationItem> _notifications = [];

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ NotificationService déjà initialisé');
      return;
    }

    print('🔔 Initialisation du service de notifications...');
    
    // Charger les notifications depuis Firestore (TODO)
    _loadNotifications();
    
    _isInitialized = true;
    print('✅ Service de notifications initialisé');
  }

  /// Charger les notifications
  void _loadNotifications() {
    // TODO: Charger depuis Firestore
    // Pour l'instant, on utilise des données de test
    _notifications.addAll([
      NotificationItem(
        id: '1',
        title: 'Bienvenue !',
        body: 'Bienvenue dans l\'application de location',
        timestamp: DateTime.now(),
        type: 'info',
        isRead: false,
      ),
    ]);
  }

  /// Obtenir toutes les notifications
  List<NotificationItem> getNotifications() {
    return List.unmodifiable(_notifications);
  }

  /// Obtenir le nombre de notifications non lues
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Ajouter une notification
  void addNotification({
    required String title,
    required String body,
    required String type,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );
    
    _notifications.insert(0, notification);
    print('✅ Notification ajoutée: $title');
    
    // TODO: Sauvegarder dans Firestore
  }

  /// Marquer une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      print('✅ Notification marquée comme lue: $notificationId');
      // TODO: Mettre à jour dans Firestore
    }
  }

  /// Marquer toutes comme lues
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    print('✅ Toutes les notifications marquées comme lues');
    // TODO: Mettre à jour dans Firestore
  }

  /// Supprimer une notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    print('✅ Notification supprimée: $notificationId');
    // TODO: Supprimer de Firestore
  }

  /// Supprimer toutes les notifications
  void clearAll() {
    _notifications.clear();
    print('✅ Toutes les notifications supprimées');
    // TODO: Supprimer de Firestore
  }

  /// Notification de test
  void showTestNotification() {
    addNotification(
      title: 'Test Notification',
      body: 'Ceci est une notification de test à ${DateTime.now().hour}:${DateTime.now().minute}',
      type: 'test',
    );
  }

  /// Créer une notification pour un nouveau logement
  void notifyNewLogement(String logementTitle) {
    addNotification(
      title: 'Nouveau logement',
      body: 'Un nouveau logement "$logementTitle" a été ajouté',
      type: 'new_logement',
    );
  }

  /// Créer une notification pour un favori
  void notifyFavoriteAvailable(String logementTitle) {
    addNotification(
      title: 'Favori disponible',
      body: '"$logementTitle" est maintenant disponible',
      type: 'favorite',
    );
  }
}

/// Modèle de notification
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      timestamp: DateTime.parse(map['timestamp']),
      type: map['type'],
      isRead: map['isRead'] ?? false,
    );
  }
}