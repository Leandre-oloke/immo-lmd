import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ContactService {
  // Faire un appel téléphonique
  static Future<void> appeler(String numero) async {
    final telUri = Uri.parse('tel:$numero');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application téléphone');
    }
  }
  
  // Envoyer un SMS
  static Future<void> envoyerSMS(String numero, String message) async {
    final smsUri = Uri.parse('sms:$numero?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application messages');
    }
  }
  
  // Envoyer un email
  static Future<void> envoyerEmail(String email, String sujet, String corps) async {
    final emailUri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(sujet)}&body=${Uri.encodeComponent(corps)}'
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw Exception('Impossible d\'ouvrir l\'application email');
    }
  }
  
  // Partager le logement
  static Future<void> partagerLogement({
    required String titre,
    required String description,
    required double prix,
    required String adresse,
    String? imageUrl,
  }) async {
    final texte = '''
🏡 $titre

💰 Prix: ${prix}€/mois
📍 Adresse: $adresse

📝 Description: $description

📍 Découvrez ce logement sur notre application !
''';
    
    await Share.share(
      texte,
      subject: 'Découvrez ce logement: $titre',
    );
  }
}