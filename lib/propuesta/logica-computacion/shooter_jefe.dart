import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class JefeCarreraShooter extends StatefulWidget {
  const JefeCarreraShooter({super.key});

  @override
  State<JefeCarreraShooter> createState() => _JefeCarreraShooterState();
}

class _JefeCarreraShooterState extends State<JefeCarreraShooter> {
  // Posición del jugador (avión) - Rango de -1 a 1
  double playerX = 0;
  double playerY = 0.8;

  // Listas de objetos en pantalla
  List<Offset> playerBullets = [];
  List<Map<String, dynamic>> enemies = []; // {pos: Offset, health: int}
  List<Offset> enemyBullets = [];

  // Estado del juego
  int score = 0;
  int health = 100;
  bool isGameOver = false;

  Timer? gameLoop;
  StreamSubscription? sensorSubscription;

  @override
  void initState() {
    super.initState();
    _startSensors();
    _startGame();
  }

  void _startSensors() {
    sensorSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (!mounted || isGameOver) return;
      setState(() {
        // Bajamos el multiplicador a 0.02 para que sea más lento
        // Usamos -= para X y += para Y dependiendo de la orientación deseada
        double speedFactor = 0.02;

        playerX -= event.x * speedFactor;
        // El -6 o -7 compensa la inclinación natural de tus manos
        playerY += (event.y - 6.5) * speedFactor;

        // Mantenemos al avión dentro de la pantalla
        playerX = playerX.clamp(-1.0, 1.0);
        playerY = playerY.clamp(-1.0, 1.0);
      });
    });
  }

  void _startGame() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      // 1. Mover balas del jugador hacia arriba
      for (int i = 0; i < playerBullets.length; i++) {
        playerBullets[i] = Offset(
          playerBullets[i].dx,
          playerBullets[i].dy - 0.08,
        );
      }
      playerBullets.removeWhere((b) => b.dy < -1.1);

      // 2. Aparecer enemigos aleatoriamente
      if (Random().nextInt(40) == 1) {
        enemies.add({
          'pos': Offset(Random().nextDouble() * 2 - 1, -1.1),
          'health': 2,
        });
      }

      // 3. Mover enemigos y que disparen
      for (var enemy in enemies) {
        enemy['pos'] = Offset(enemy['pos'].dx, enemy['pos'].dy + 0.01);
        if (Random().nextInt(50) == 1) {
          enemyBullets.add(Offset(enemy['pos'].dx, enemy['pos'].dy + 0.1));
        }
      }

      // 4. Mover balas enemigas hacia abajo
      for (int i = 0; i < enemyBullets.length; i++) {
        enemyBullets[i] = Offset(enemyBullets[i].dx, enemyBullets[i].dy + 0.05);
      }

      // 5. Colisiones: Balas jugador -> Enemigos
      for (int i = playerBullets.length - 1; i >= 0; i--) {
        for (int j = enemies.length - 1; j >= 0; j--) {
          if ((playerBullets[i] - enemies[j]['pos']).distance < 0.15) {
            enemies[j]['health']--;
            playerBullets.removeAt(i);
            if (enemies[j]['health'] <= 0) {
              enemies.removeAt(j);
              score += 10;
            }
            break;
          }
        }
      }

      // 6. Colisiones: Balas enemigas -> Jugador
      for (int i = enemyBullets.length - 1; i >= 0; i--) {
        if ((enemyBullets[i] - Offset(playerX, playerY)).distance < 0.12) {
          health -= 10;
          enemyBullets.removeAt(i);
          if (health <= 0) _endGame();
        }
      }

      enemies.removeWhere((e) => e['pos'].dy > 1.1);
      enemyBullets.removeWhere((b) => b.dy > 1.1);
    });
  }

  void _shoot() {
    if (isGameOver) return;
    setState(() {
      playerBullets.add(Offset(playerX, playerY - 0.1));
    });
  }

  void _endGame() {
    isGameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Misión Fallida"),
        content: Text(
          "Las naves alienígenas tomaron el edificio de Cómputo.\nPuntaje: $score",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver al Mapa"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _shoot, // Dispara al tocar cualquier parte de la pantalla
        child: Stack(
          children: [
            // Fondo de estrellas simple
            const Center(
              child: Icon(Icons.star, color: Colors.white10, size: 400),
            ),

            // Enemigos
            ...enemies.map(
              (e) => Align(
                alignment: Alignment(e['pos'].dx, e['pos'].dy),
                child: const Text("🛸", style: TextStyle(fontSize: 40)),
              ),
            ),

            // Balas Enemigas
            ...enemyBullets.map(
              (b) => Align(
                alignment: Alignment(b.dx, b.dy),
                child: const Icon(Icons.circle, color: Colors.red, size: 10),
              ),
            ),

            // Balas Jugador
            ...playerBullets.map(
              (b) => Align(
                alignment: Alignment(b.dx, b.dy),
                child: Container(
                  width: 4,
                  height: 15,
                  color: Colors.yellowAccent,
                ),
              ),
            ),

            // Jugador (Avión)
            Align(
              alignment: Alignment(playerX, playerY),
              child: const Text("🛩️", style: TextStyle(fontSize: 50)),
            ),

            // HUD
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Puntos: $score",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: health / 100,
                        color: Colors.green,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
