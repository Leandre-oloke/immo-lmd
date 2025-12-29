// import 'package:flutter/material.dart';
// import '../components/app_drawer.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Dashboard Admin")),
//       drawer: const AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               "Statistiques des logements",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text("Nombre de logements: 120"),
//             Text("Nombre d'utilisateurs: 80"),
//             Text("Nombre de messages: 250"),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard Admin")),
      body: Center(child: Text("Statistiques et gestion admin")),
    );
  }
}
