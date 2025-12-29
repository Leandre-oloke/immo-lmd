import 'package:flutter/material.dart';
import '../../models/logement_model.dart';

class LogementCard extends StatelessWidget {
  final Logement logement;
  final VoidCallback onTap;
  final bool showOwnerInfo;
  final bool showActions;

  const LogementCard({
    super.key,
    required this.logement,
    required this.onTap,
    this.showOwnerInfo = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du logement
            _buildImageSection(),
            
            // Informations principales
            _buildInfoSection(),
            
            // Actions supplémentaires (si activé)
            if (showActions) _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: logement.photos.isNotEmpty
              ? Image.network(
                  logement.photos.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.home,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.home,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        
        // Badge de disponibilité
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: logement.disponible 
                  ? Colors.green.withOpacity(0.9)
                  : Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              logement.disponible ? 'Disponible' : 'Occupé',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Badge prix
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${logement.prix} €/mois',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            logement.titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          if (logement.description.isNotEmpty)
            Column(
              children: [
                Text(
                  logement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          
          // Adresse
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  logement.adresse,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Caractéristiques
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeatureItem(
                icon: Icons.aspect_ratio,
                text: '${logement.superficie} m²',
              ),
              _buildFeatureItem(
                icon: Icons.bed,
                text: '${logement.nombreChambres} chambre${logement.nombreChambres > 1 ? 's' : ''}',
              ),
              _buildFeatureItem(
                icon: Icons.photo_library,
                text: '${logement.photos.length} photo${logement.photos.length > 1 ? 's' : ''}',
              ),
            ],
          ),
          
          // Informations propriétaire (si activé)
          if (showOwnerInfo) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Propriétaire',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Contact disponible',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // TODO: Ouvrir la messagerie avec le propriétaire
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton favori
          TextButton.icon(
            onPressed: () {
              // TODO: Ajouter aux favoris
            },
            icon: const Icon(
              Icons.favorite_border,
              size: 18,
            ),
            label: const Text('Favori'),
          ),
          
          // Bouton partager
          TextButton.icon(
            onPressed: () {
              // TODO: Partager le logement
            },
            icon: const Icon(
              Icons.share,
              size: 18,
            ),
            label: const Text('Partager'),
          ),
          
          // Bouton contact
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Contacter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// Variante compacte pour les listes denses
class LogementCardCompact extends StatelessWidget {
  final Logement logement;
  final VoidCallback onTap;

  const LogementCardCompact({
    super.key,
    required this.logement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: logement.photos.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  logement.photos.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home, color: Colors.grey),
              ),
        title: Text(
          logement.titre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              logement.adresse,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${logement.prix} €',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: logement.disponible
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    logement.disponible ? 'Disponible' : 'Occupé',
                    style: TextStyle(
                      fontSize: 10,
                      color: logement.disponible ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

