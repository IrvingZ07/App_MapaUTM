import 'package:flutter/material.dart';
import 'presentations/home_screen.dart'; // Importaremos nuestra pantalla principal

void main() {
  runApp(const UtmOrientaApp());
}

class UtmOrientaApp extends StatelessWidget {
  const UtmOrientaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTM Orienta',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta roja de "DEBUG"
      theme: ThemeData(
        // Colores base con un toque moderno
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)), // Azul oscuro institucional
        useMaterial3: true,
        fontFamily: 'Roboto', // Puedes cambiarla después si agregas fuentes
      ),
      home: const HomeScreen(),
    );
  }
}