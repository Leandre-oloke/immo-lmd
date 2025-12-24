
import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'utils/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpatBenin',
      theme: AppTheme.lightTheme,
      home: HomePage(),
    );
  }
}
