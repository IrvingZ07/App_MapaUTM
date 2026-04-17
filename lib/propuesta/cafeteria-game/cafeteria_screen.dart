import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class CafeteriaGame extends StatefulWidget {
  const CafeteriaGame({super.key});

  @override
  State<CafeteriaGame> createState() => _CafeteriaGameState();
}

class _CafeteriaGameState extends State<CafeteriaGame> {
  double playerX = 0; // -1.0 a 1.0
  double foodY = -1.0;
  double foodX = 0;
  int vidas = 3;
  int puntos = 0;
  String comidaActual = "☕";
  Timer? gameLoop;
  StreamSubscription? accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startSensors();
    _startGame();
  }

  void _startSensors() {
    accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (mounted) {
        setState(() {
          // Reducimos la sensibilidad significativamente
          // Un valor de 0.025 suele ser el "punto dulce" para juegos de atrapar cosas
          double sensibilidadReducida = 0.025;

          playerX -= event.x * sensibilidadReducida;

          // Limites laterales
          if (playerX < -1) playerX = -1;
          if (playerX > 1) playerX = 1;
        });
      }
    });
  }

  void _startGame() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          foodY += 0.05;

          // Si la comida llega al suelo
          if (foodY > 1.0) {
            // Colisión con el jugador (rango de atrapado)
            if ((foodX - playerX).abs() < 0.3) {
              puntos++;
              _resetFood();
            } else {
              vidas--;
              if (vidas <= 0) {
                _gameOver();
              } else {
                _resetFood();
              }
            }
          }
        });
      }
    });
  }

  void _resetFood() {
    foodY = -1.0;
    foodX = Random().nextDouble() * 2 - 1; // Entre -1 y 1
    comidaActual = ["☕", "🥐", "🥪", "🍎"][Random().nextInt(4)];
  }

  void _gameOver() {
    gameLoop?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Juego Terminado"),
        content: Text("Atrapaste $puntos comidas."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog
              Navigator.pop(context); // Regresa al mapa
            },
            child: const Text("Volver al mapa"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text(
          "Reto: Cafetería",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B2E2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Comida cayendo
          Align(
            alignment: Alignment(foodX, foodY),
            child: Text(comidaActual, style: const TextStyle(fontSize: 40)),
          ),
          // Jugador (Estudiante con charola)
          Align(
            alignment: Alignment(playerX, 0.9),
            child: const Text("🍱", style: TextStyle(fontSize: 60)),
          ),
          // HUD: Vidas y Puntos
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Vidas: ${'❤️' * vidas}\nPuntos: $puntos",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2E2E),
                ),
              ),
            ),
          ),
          // Instrucción temporal
          const Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Text(
              "¡Inclina tu celular para atrapar la comida!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
