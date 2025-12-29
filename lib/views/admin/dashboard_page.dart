

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
