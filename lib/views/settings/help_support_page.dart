import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Comment ajouter un logement?',
      answer: 'Cliquez sur le bouton "+" en bas à droite de l\'écran et remplissez le formulaire. Vous pouvez ajouter jusqu\'à 10 photos par logement.',
    ),
    FAQItem(
      question: 'Comment contacter un propriétaire?',
      answer: 'Sur la page d\'un logement, cliquez sur le bouton "Contacter". Vous pouvez envoyer un message directement au propriétaire.',
    ),
    FAQItem(
      question: 'Comment modifier mes informations personnelles?',
      answer: 'Allez dans Paramètres > Profil pour modifier vos informations. Certains changements peuvent nécessiter une vérification.',
    ),
    FAQItem(
      question: 'Comment supprimer mon compte?',
      answer: 'Contactez notre support pour supprimer votre compte. Notez que cette action est irréversible.',
    ),
    FAQItem(
      question: 'Problèmes de paiement?',
      answer: 'Vérifiez vos informations de carte bancaire. Si le problème persiste, contactez notre support financier.',
    ),
  ];

  // CORRECTION: Utiliser int au lieu de bool pour l'index
  int _expandedIndex = -1;  // -1 signifie aucun élément développé

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 60,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comment pouvons-nous vous aider?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trouvez des réponses à vos questions ou contactez notre équipe',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Recherche rapide
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher dans l\'aide...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          
          // Catégories d'aide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catégories d\'aide',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildHelpCategory(
                      icon: Icons.home,
                      label: 'Logements',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildHelpCategory(
                      icon: Icons.payment,
                      label: 'Paiements',
                      color: Colors.green,
                      onTap: () {},
                    ),
                    _buildHelpCategory(
                      icon: Icons.account_circle,
                      label: 'Compte',
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    _buildHelpCategory(
                      icon: Icons.security,
                      label: 'Sécurité',
                      color: Colors.purple,
                      onTap: () {},
                    ),
                    _buildHelpCategory(
                      icon: Icons.phone,
                      label: 'Contact',
                      color: Colors.red,
                      onTap: () {},
                    ),
                    _buildHelpCategory(
                      icon: Icons.description,
                      label: 'Documents',
                      color: Colors.teal,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // FAQ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAQ - Questions fréquentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._faqs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(
                        faq.question,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(faq.answer),
                        ),
                      ],
                      // CORRECTION: Comparaison avec l'index
                      initiallyExpanded: _expandedIndex == index,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : -1;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Contact rapide
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Besoin d\'aide supplémentaire?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Notre équipe support est disponible 7j/7',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _sendEmail();
                        },
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _makePhoneCall();
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Appeler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _openChat();
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat en direct'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
          
          // Informations contact
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations de contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactInfo(
                  icon: Icons.email,
                  title: 'Email support',
                  value: 'support@immolmd.com',
                  onTap: () => _sendEmail(),
                ),
                _buildContactInfo(
                  icon: Icons.phone,
                  title: 'Téléphone',
                  value: '+221 823 45 67 89',
                  onTap: () => _makePhoneCall(),
                ),
                _buildContactInfo(
                  icon: Icons.access_time,
                  title: 'Horaires',
                  value: 'Lundi - Vendredi: 9h-18h\nSamedi: 10h-16h',
                  onTap: null,
                ),
                _buildContactInfo(
                  icon: Icons.location_on,
                  title: 'Adresse',
                  value: '123 Rue de la Location\n75001 Dakar, Sénégal',
                  onTap: () => _openMaps(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCategory({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _sendEmail() async {
    const email = 'mailto:support@immolmd.com?subject=Support%20ImmoLMD&body=Bonjour,%0A%0A';
    if (await canLaunchUrl(Uri.parse(email))) {
      await launchUrl(Uri.parse(email));
    } else {
      // Fallback si l'URL ne peut pas être lancée
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application email'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _makePhoneCall() async {
    const phone = 'tel:+221823456789';
    if (await canLaunchUrl(Uri.parse(phone))) {
      await launchUrl(Uri.parse(phone));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de composer le numéro'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouverture du chat en direct...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implémenter l'intégration avec un service de chat
  }

  Future<void> _openMaps() async {
    const address = 'https://maps.google.com/?q=123+Rue+de+la+Location,Paris,France';
    if (await canLaunchUrl(Uri.parse(address))) {
      await launchUrl(Uri.parse(address));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application cartes'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

class FAQItem {
  final String question;
  final String answer;
  
  FAQItem({required this.question, required this.answer});
}