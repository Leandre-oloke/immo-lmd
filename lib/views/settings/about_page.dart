import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_work,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ImmoLMD',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Plateforme de location immobilière',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Chip(
                  label: Text('Version 1.0.0 • Stable'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notre Mission',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ImmoLMD révolutionne la location immobilière en connectant directement propriétaires et locataires dans un environnement sécurisé et transparent. '
                  'Notre plateforme simplifie la gestion de biens immobiliers tout en offrant une expérience utilisateur exceptionnelle.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                
                // Statistiques
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatistic('500+', 'Logements'),
                    _buildStatistic('1K+', 'Utilisateurs'),
                    _buildStatistic('99%', 'Satisfaction'),
                    _buildStatistic('24/7', 'Support'),
                  ],
                ),
              ],
            ),
          ),
          
          // Fonctionnalités
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nos Fonctionnalités',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.verified,
                      title: 'Vérification',
                      subtitle: 'Profils vérifiés',
                    ),
                    _buildFeatureCard(
                      icon: Icons.security,
                      title: 'Sécurité',
                      subtitle: 'Paiements sécurisés',
                    ),
                    _buildFeatureCard(
                      icon: Icons.photo_camera,
                      title: 'Visites 360°',
                      subtitle: 'Visites virtuelles',
                    ),
                    // _buildFeatureCard(
                    //   icon: Icons.contract,
                    //   title: 'Contrats',
                    //   subtitle: 'Génération automatique',
                    // ),
                    _buildFeatureCard(
                      icon: Icons.chat,
                      title: 'Messagerie',
                      subtitle: 'Communication directe',
                    ),
                    _buildFeatureCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'Statistiques détaillées',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Équipe
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notre Équipe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTeamMember(
                        name: 'Léandre OLOKE',
                        role: 'CEO & Fondateur',
                        imageUrl: 'https://i.pravatar.cc/150?img=1',
                      ),
                      _buildTeamMember(
                        name: 'Maième DIENE',
                        role: 'Co-Fondatrice',
                        imageUrl: 'https://i.pravatar.cc/150?img=2',
                      ),
                      _buildTeamMember(
                        name: 'Cheick Oumar Doumbia',
                        role: 'Co-Fondateur',
                        imageUrl: 'https://i.pravatar.cc/150?img=3',
                      ),
                      _buildTeamMember(
                        name: 'Jean Petit',
                        role: 'Développeur Mobile',
                        imageUrl: 'https://i.pravatar.cc/150?img=4',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Réseaux sociaux
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suivez-nous',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: Icons.facebook,
                      color: Colors.blue.shade800,
                      onTap: () => _openUrl('https://facebook.com/immolmd'),
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.photo_camera,
                      color: Colors.pink,
                      onTap: () => _openUrl('https://instagram.com/immolmd'),
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.link,
                      color: Colors.blue,
                      onTap: () => _openUrl('https://linkedin.com/company/immolmd'),
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: Icons.play_arrow,
                      color: Colors.red,
                      onTap: () => _openUrl('https://youtube.com/immolmd'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Informations légales
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations Légales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegalItem(
                  title: 'Politique de confidentialité',
                  onTap: () {},
                ),
                _buildLegalItem(
                  title: 'Conditions d\'utilisation',
                  onTap: () {},
                ),
                _buildLegalItem(
                  title: 'Mentions légales',
                  onTap: () {},
                ),
                // _buildLegalItem(
                //   title: 'CGU/CGV',
                //   onTap: () {},
                // ),
                 _buildLegalItem(
                  title: 'Cookies',
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Pied de page
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.green.shade900,
            child: Column(
              children: [
                const Text(
                  'ImmoLMD © 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tous droits réservés.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Text(
                  '123 Rue de la Location, 75001 Dakar, Dakar\ncontact@immolmd.com • +221 823 45 67 89',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    _openUrl('https://immolmd.com');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Visiter notre site web'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String imageUrl,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildLegalItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}