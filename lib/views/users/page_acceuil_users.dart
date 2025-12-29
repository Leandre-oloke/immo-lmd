import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/logement_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/logement_model.dart';
import '../components/logement_card.dart';
import '../components/app_drawer.dart';

class PageAcceuilUsers extends StatefulWidget {
  const PageAcceuilUsers({super.key});

  @override
  State<PageAcceuilUsers> createState() => _PageAcceuilUsersState();
}

class _PageAcceuilUsersState extends State<PageAcceuilUsers> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';
  final List<String> _filterOptions = ['Tous', 'Disponibles', 'Moins cher', 'Plus cher'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLogements() {
    final logementViewModel = context.read<LogementViewModel>();
    logementViewModel.loadAllLogements();
  }

  List<Logement> _filterLogements(List<Logement> logements) {
    List<Logement> filtered = List.from(logements);
    
    // Filtre par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((logement) {
        return logement.titre.toLowerCase().contains(query) ||
               logement.description.toLowerCase().contains(query) ||
               logement.adresse.toLowerCase().contains(query);
      }).toList();
    }
    
    // Filtre par option sélectionnée
    switch (_selectedFilter) {
      case 'Disponibles':
        filtered = filtered.where((logement) => logement.disponible).toList();
        break;
      case 'Moins cher':
        filtered.sort((a, b) => a.prix.compareTo(b.prix));
        break;
      case 'Plus cher':
        filtered.sort((a, b) => b.prix.compareTo(a.prix));
        break;
      default:
        // 'Tous' - pas de tri supplémentaire
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final logementViewModel = context.watch<LogementViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    
    final filteredLogements = _filterLogements(logementViewModel.logements);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trouvez votre logement"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchBar(),
          
          // Filtres
          _buildFilterChips(),
          
          // Compteur de résultats
          _buildResultsCounter(filteredLogements.length),
          
          // Liste des logements
          _buildLogementsList(logementViewModel, filteredLogements),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Retour en haut de la liste
          Scrollable.ensureVisible(context);
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Rechercher un logement...",
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filterOptions.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
              labelStyle: TextStyle(
                color: _selectedFilter == filter ? Colors.blue : Colors.black,
                fontWeight: _selectedFilter == filter 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsCounter(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$count logement${count > 1 ? 's' : ''} trouvé${count > 1 ? 's' : ''}",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          if (_searchController.text.isNotEmpty || _selectedFilter != 'Tous')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedFilter = 'Tous';
                });
              },
              child: const Text("Réinitialiser"),
            ),
        ],
      ),
    );
  }

  Widget _buildLogementsList(
    LogementViewModel viewModel,
    List<Logement> filteredLogements,
  ) {
    if (viewModel.isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Chargement des logements..."),
            ],
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Erreur de chargement",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadLogements,
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredLogements.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchController.text.isEmpty ? Icons.home : Icons.search_off,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty
                    ? "Aucun logement disponible"
                    : "Aucun résultat pour '${_searchController.text}'",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isEmpty
                    ? "Revenez plus tard..."
                    : "Essayez avec d'autres mots-clés",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (_searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    child: const Text("Effacer la recherche"),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          _loadLogements();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLogements.length,
          itemBuilder: (context, index) {
            final logement = filteredLogements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LogementCard(
                logement: logement,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/logement-details',
                    arguments: logement,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Méthode pour afficher un dialogue de filtres avancés
  void _showAdvancedFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Filtres avancés"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text("Prix maximum (€)"),
                    Slider(
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      value: 1000,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    const Text("Nombre minimum de chambres"),
                    Slider(
                      min: 0,
                      max: 5,
                      divisions: 5,
                      value: 1,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Afficher seulement les disponibles"),
                      value: true,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Appliquer"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../viewmodels/logement_viewmodel.dart';
// import 'package:provider/provider.dart';
// import '../components/logement_card.dart';

// class PageAcceuilUsers extends StatefulWidget {
//   @override
//   _PageAcceuilUsersState createState() => _PageAcceuilUsersState();
// }

// class _PageAcceuilUsersState extends State<PageAcceuilUsers> {
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<LogementViewModel>(context, listen: false).loadLogements();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final logementVM = Provider.of<LogementViewModel>(context);

//     return Scaffold(
//       appBar: AppBar(title: Text("Rechercher Logements")),
//       body: logementVM.isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: logementVM.logements.length,
//               itemBuilder: (context, index) {
//                 final logement = logementVM.logements[index];
//                 return LogementCard(
//                   logement: logement,
//                   onTap: () {},
//                 );
//               },
//             ),
//     );
//   }
// }

