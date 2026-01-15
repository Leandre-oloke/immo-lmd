import 'package:app_mobile/views/logement/details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/logement_viewmodel.dart';
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
      context.read<LogementViewModel>().loadAllLogements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Logement> _filterLogements(List<Logement> logements) {
    List<Logement> filtered = List.from(logements);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((logement) {
        return logement.titre.toLowerCase().contains(query) ||
            logement.description.toLowerCase().contains(query) ||
            logement.adresse.toLowerCase().contains(query);
      }).toList();
    }

    switch (_selectedFilter) {
      case 'Disponibles':
        filtered = filtered.where((l) => l.disponible).toList();
        break;
      case 'Moins cher':
        filtered.sort((a, b) => a.prix.compareTo(b.prix));
        break;
      case 'Plus cher':
        filtered.sort((a, b) => b.prix.compareTo(a.prix));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final logementVM = context.watch<LogementViewModel>();
    final filteredLogements = _filterLogements(logementVM.logements);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 240, 246, 247),
        elevation: 0,
        title: const Text("Trouvez votre logement"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 159, 219, 247),
              Color.fromARGB(255, 13, 0, 83),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => logementVM.loadAllLogements(),
            child: _buildContent(logementVM, filteredLogements),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Scrollable.ensureVisible(context),
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildContent(LogementViewModel vm, List<Logement> logements) {
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Chargement des logements...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(vm.errorMessage!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadAllLogements,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (logements.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? "Aucun logement disponible"
              : "Aucun résultat pour \"${_searchController.text}\"",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildResultsCounter(logements.length),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: logements.map((logement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LogementCard(
                    logement: logement,
                    onTap: () => _showLogementDetails(logement),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
        ),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Rechercher un logement...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
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
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsCounter(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "$count logement${count > 1 ? 's' : ''} trouvé${count > 1 ? 's' : ''}",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showLogementDetails(Logement logement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DetailsBottomSheet(logement: logement),
    );
  }
}
