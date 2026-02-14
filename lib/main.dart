import 'package:flutter/material.dart';
import 'package:myocr/screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My OCR",
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}