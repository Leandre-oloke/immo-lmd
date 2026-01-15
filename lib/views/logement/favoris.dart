import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/logement_model.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../components/logement_card.dart';
import 'details_bottom_sheet.dart'; // ✅ Correction de l'import
import 'details_bottom_sheet.dart';

class MesFavorisPage extends StatelessWidget {
  const MesFavorisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        actions: [
          // Bouton pour vider les favoris (optionnel)
          Consumer<LogementViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.favoris.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () {
                  _showClearConfirmationDialog(context, viewModel);
                },
                tooltip: 'Vider les favoris',
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<LogementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingFavoris) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Chargement de vos favoris..."),
              ],
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Erreur de chargement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    viewModel.loadFavoris();
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }

        if (viewModel.favoris.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Aucun favori",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Ajoutez des logements à vos favoris\npour les retrouver ici",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Naviguer vers la page des logements
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Parcourir les logements"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadFavoris();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.favoris.length,
            itemBuilder: (context, index) {
              final logement = viewModel.favoris[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LogementCard(
                  logement: logement,
                  onTap: () {
                    // ✅ CORRECTION : Utilise showLogementDetails au lieu de DetailBottomSheet
                    showLogementDetails(context, logement);
                  },
                  showOwnerInfo: true,
                  showActions: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Boîte de dialogue de confirmation pour vider les favoris
  Future<void> _showClearConfirmationDialog(
    BuildContext context,
    LogementViewModel viewModel,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vider les favoris'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer tous vos favoris ?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllFavorites(viewModel);
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour vider tous les favoris
  Future<void> _clearAllFavorites(LogementViewModel viewModel) async {
    try {
      // Supprimer chaque favori un par un
      for (final logement in viewModel.favoris.toList()) {
        await viewModel.removeFavorite(logement.id);
      }
      
      // Recharger les favoris pour s'assurer que la liste est vide
      await viewModel.loadFavoris();
      
      // Afficher un message de confirmation
      // Note: Tu dois passer le context depuis le widget parent
      // ScaffoldMessenger.of(context).showSnackBar(...)
      
    } catch (e) {
      print('❌ Erreur suppression favoris: $e');
    }
  }
}