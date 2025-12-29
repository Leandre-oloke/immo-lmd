import 'package:flutter/material.dart';
import '../components/app_drawer.dart';
import '../components/app_end_drawer.dart';

// Page de profil utilisateur
// StatelessWidget car ne nécessite pas de gestion d'état

class PageProfil extends StatelessWidget {
  const PageProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      drawer: const AppDrawer(),
      endDrawer: const AppEndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Nom: Léandre OLOKE",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              "Email: exemple@mail.com",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              "Rôle: Locataire",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
