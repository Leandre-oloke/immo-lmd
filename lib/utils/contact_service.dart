import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ContactService {
  /// Appeler un numéro de téléphone
  static Future<void> appeler(String numeroTelephone) async {
    // Nettoyer le numéro (retirer espaces, tirets, etc.)
    final numero = numeroTelephone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: numero);
    
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw Exception('Impossible d\'appeler ce numéro');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel: $e');
    }
  }

  /// Envoyer un SMS
  static Future<void> envoyerSMS(String numeroTelephone, [String? message]) async {
    final numero = numeroTelephone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Construire l'URI avec ou sans message
    final Uri smsUri = message != null
        ? Uri(
            scheme: 'sms',
            path: numero,
            queryParameters: {'body': message},
          )
        : Uri(scheme: 'sms', path: numero);
    
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Impossible d\'envoyer un SMS');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du SMS: $e');
    }
  }

  /// Ouvrir WhatsApp
  static Future<void> ouvrirWhatsApp(String numeroTelephone, [String? message]) async {
    // Nettoyer et formater le numéro (WhatsApp nécessite le format international)
    String numero = numeroTelephone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si le numéro ne commence pas par +, ajouter le code pays (exemple: Sénégal +221)
    if (!numero.startsWith('+')) {
      // ⚠️ Remplace '221' par le code pays approprié
      numero = '+221$numero';
    }
    
    // Encoder le message pour l'URL
    final messageEncode = message != null ? Uri.encodeComponent(message) : '';
    
    // WhatsApp URL (fonctionne sur Android et iOS)
    final String whatsappUrl = message != null
        ? 'https://wa.me/$numero?text=$messageEncode'
        : 'https://wa.me/$numero';
    
    final Uri whatsappUri = Uri.parse(whatsappUrl);
    
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication, // Ouvre dans l'app WhatsApp
        );
      } else {
        throw Exception('WhatsApp n\'est pas installé');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ouverture de WhatsApp: $e');
    }
  }

  /// Envoyer un email
  static Future<void> envoyerEmail(String email, {String? sujet, String? corps}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (sujet != null) 'subject': sujet,
        if (corps != null) 'body': corps,
      },
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Impossible d\'ouvrir l\'application email');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'email: $e');
    }
  }

  /// Ouvrir une URL dans le navigateur
  static Future<void> ouvrirURL(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Impossible d\'ouvrir l\'URL');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ouverture de l\'URL: $e');
    }
  }

  /// Partager du contenu (utilise le système de partage natif)
  static Future<void> partagerLogement({
    required String titre,
    required String description,
    required double prix,
    required String adresse,
    String? imageUrl,
  }) async {
    final String texte = '''
🏠 $titre

💰 Prix: $prix €/mois
📍 Adresse: $adresse

📝 Description:
$description

${imageUrl != null ? '🖼️ Photo: $imageUrl' : ''}
    ''';

    // Pour le partage, on utilise share_plus (optionnel)
    // Si tu veux implémenter le partage, installe share_plus
    print('📤 Partage: $texte');
    
    await Share.share(
    texte,
    subject: titre,
  );
    // Alternative simple: copier dans le presse-papier
    // Nécessite le package clipboard
  }

  /// Formater un numéro de téléphone
  static String formaterNumero(String numero) {
    // Exemple: +221 77 123 45 67
    final numClean = numero.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (numClean.length >= 9) {
      if (numClean.startsWith('+221')) {
        // Format Sénégal: +221 77 123 45 67
        final local = numClean.substring(4);
        return '+221 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5, 7)} ${local.substring(7)}';
      }
    }
    
    return numero; // Retourner tel quel si format inconnu
  }
}








// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';

// class ContactService {
//   // Faire un appel téléphonique
//   static Future<void> appeler(String numero) async {
//     final telUri = Uri.parse('tel:$numero');
//     if (await canLaunchUrl(telUri)) {
//       await launchUrl(telUri);
//     } else {
//       throw Exception('Impossible d\'ouvrir l\'application téléphone');
//     }
//   }
  
//   // Envoyer un SMS
//   static Future<void> envoyerSMS(String numero, String message) async {
//     final smsUri = Uri.parse('sms:$numero?body=${Uri.encodeComponent(message)}');
//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri);
//     } else {
//       throw Exception('Impossible d\'ouvrir l\'application messages');
//     }
//   }
  
//   // Envoyer un email
//   static Future<void> envoyerEmail(String email, String sujet, String corps) async {
//     final emailUri = Uri.parse(
//       'mailto:$email?subject=${Uri.encodeComponent(sujet)}&body=${Uri.encodeComponent(corps)}'
//     );
//     if (await canLaunchUrl(emailUri)) {
//       await launchUrl(emailUri);
//     } else {
//       throw Exception('Impossible d\'ouvrir l\'application email');
//     }
//   }
  
//   // Partager le logement
//   static Future<void> partagerLogement({
//     required String titre,
//     required String description,
//     required double prix,
//     required String adresse,
//     String? imageUrl,
//   }) async {
//     final texte = '''
// 🏡 $titre

// 💰 Prix: ${prix}€/mois
// 📍 Adresse: $adresse

// 📝 Description: $description

// 📍 Découvrez ce logement sur notre application !
// ''';
    
//     await Share.share(
//       texte,
//       subject: 'Découvrez ce logement: $titre',
//     );
//   }
// }