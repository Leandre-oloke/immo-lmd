import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.getNotifications();
    final unreadCount = _notificationService.getUnreadCount();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Tout marquer comme lu'),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Text('Tester une notification'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Tout supprimer'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'test':
                  _sendTestNotification();
                  break;
                case 'clear':
                  _clearAll();
                  break;
              }
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous serez notifié des nouveaux logements\net des mises à jour importantes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _sendTestNotification,
            icon: const Icon(Icons.notification_add),
            label: const Text('Tester une notification'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _notificationService.deleteNotification(notification.id);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification supprimée')),
        );
      },
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          color: notification.isRead ? null : Colors.blue.shade50,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_logement':
        return Icons.home;
      case 'favorite':
        return Icons.favorite;
      case 'message':
        return Icons.message;
      case 'test':
        return Icons.bug_report;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_logement':
        return Colors.blue;
      case 'favorite':
        return Colors.red;
      case 'message':
        return Colors.green;
      case 'test':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    _notificationService.markAsRead(notification.id);
    setState(() {});

    // TODO: Navigation selon le type
    switch (notification.type) {
      case 'new_logement':
        // Navigator.pushNamed(context, '/logements');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers les logements...')),
        );
        break;
      case 'favorite':
        // Navigator.pushNamed(context, '/favorites');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers les favoris...')),
        );
        break;
      default:
        break;
    }
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les notifications sont marquées comme lues')),
    );
  }

  void _sendTestNotification() {
    _notificationService.showTestNotification();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification de test ajoutée')),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les notifications'),
        content: const Text('Êtes-vous sûr de vouloir supprimer toutes les notifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _notificationService.clearAll();
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Toutes les notifications supprimées')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';

// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({super.key});

//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   // Liste des notifications (à remplacer par vos données réelles)
//   final List<NotificationItem> notifications = [
//     NotificationItem(
//       id: '1',
//       title: 'Nouveau logement ajouté',
//       message: 'Un nouveau logement a été publié par Jean Dupont',
//       type: NotificationType.info,
//       time: DateTime.now().subtract(const Duration(minutes: 5)),
//       isRead: false,
//     ),
//     NotificationItem(
//       id: '2',
//       title: 'Utilisateur suspendu',
//       message: 'Le compte de Marie Martin a été suspendu pour non-respect des règles',
//       type: NotificationType.warning,
//       time: DateTime.now().subtract(const Duration(hours: 2)),
//       isRead: false,
//     ),
//     NotificationItem(
//       id: '3',
//       title: 'Nouveau message',
//       message: 'Vous avez reçu un nouveau message de support',
//       type: NotificationType.message,
//       time: DateTime.now().subtract(const Duration(hours: 5)),
//       isRead: false,
//     ),
//     NotificationItem(
//       id: '4',
//       title: 'Logement validé',
//       message: 'Le logement "Appartement centre-ville" a été approuvé',
//       type: NotificationType.success,
//       time: DateTime.now().subtract(const Duration(days: 1)),
//       isRead: true,
//     ),
//     NotificationItem(
//       id: '5',
//       title: 'Rapport hebdomadaire',
//       message: 'Votre rapport d\'activité hebdomadaire est disponible',
//       type: NotificationType.info,
//       time: DateTime.now().subtract(const Duration(days: 2)),
//       isRead: true,
//     ),
//   ];

//   void _markAsRead(String id) {
//     setState(() {
//       final index = notifications.indexWhere((n) => n.id == id);
//       if (index != -1) {
//         notifications[index].isRead = true;
//       }
//     });
//   }

//   void _markAllAsRead() {
//     setState(() {
//       for (var notification in notifications) {
//         notification.isRead = true;
//       }
//     });
//   }

//   void _deleteNotification(String id) {
//     setState(() {
//       notifications.removeWhere((n) => n.id == id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final unreadCount = notifications.where((n) => !n.isRead).length;

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue.shade700,
//                 Colors.blue.shade500,
//                 Colors.cyan.shade400,
//               ],
//             ),
//           ),
//         ),
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           if (unreadCount > 0)
//             TextButton.icon(
//               onPressed: _markAllAsRead,
//               icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
//               label: const Text(
//                 'Tout marquer lu',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? _buildEmptyState()
//           : Column(
//               children: [
//                 if (unreadCount > 0)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     color: Colors.blue.shade50,
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.shade600,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             '$unreadCount',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           '$unreadCount notification${unreadCount > 1 ? 's' : ''} non lue${unreadCount > 1 ? 's' : ''}',
//                           style: TextStyle(
//                             color: Colors.blue.shade900,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) {
//                       final notification = notifications[index];
//                       return _buildNotificationCard(notification);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_none,
//             size: 100,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Aucune notification',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Vous êtes à jour !',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationCard(NotificationItem notification) {
//     return Dismissible(
//       key: Key(notification.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         color: Colors.red,
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) => _deleteNotification(notification.id),
//       child: InkWell(
//         onTap: () {
//           if (!notification.isRead) {
//             _markAsRead(notification.id);
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: notification.isRead ? Colors.white : Colors.blue.shade50,
//             border: Border(
//               bottom: BorderSide(color: Colors.grey.shade200),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: _getNotificationColor(notification.type).withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _getNotificationIcon(notification.type),
//                     color: _getNotificationColor(notification.type),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               notification.title,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: notification.isRead
//                                     ? FontWeight.w500
//                                     : FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           if (!notification.isRead)
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.shade600,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         notification.message,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _formatTime(notification.time),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getNotificationIcon(NotificationType type) {
//     switch (type) {
//       case NotificationType.info:
//         return Icons.info_outline;
//       case NotificationType.warning:
//         return Icons.warning_amber_outlined;
//       case NotificationType.success:
//         return Icons.check_circle_outline;
//       case NotificationType.message:
//         return Icons.message_outlined;
//     }
//   }

//   Color _getNotificationColor(NotificationType type) {
//     switch (type) {
//       case NotificationType.info:
//         return Colors.blue;
//       case NotificationType.warning:
//         return Colors.orange;
//       case NotificationType.success:
//         return Colors.green;
//       case NotificationType.message:
//         return Colors.purple;
//     }
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final difference = now.difference(time);

//     if (difference.inMinutes < 60) {
//       return 'Il y a ${difference.inMinutes} min';
//     } else if (difference.inHours < 24) {
//       return 'Il y a ${difference.inHours} h';
//     } else if (difference.inDays < 7) {
//       return 'Il y a ${difference.inDays} j';
//     } else {
//       return '${time.day}/${time.month}/${time.year}';
//     }
//   }
// }

// // Modèles de données
// enum NotificationType { info, warning, success, message }

// class NotificationItem {
//   final String id;
//   final String title;
//   final String message;
//   final NotificationType type;
//   final DateTime time;
//   bool isRead;

//   NotificationItem({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.type,
//     required this.time,
//     this.isRead = false,
//   });
// }