import 'package:flutter/material.dart';
import 'dart:math';

class LogicaScreen extends StatefulWidget {
  const LogicaScreen({super.key});

  @override
  State<LogicaScreen> createState() => _LogicaScreenState();
}

class _LogicaScreenState extends State<LogicaScreen> {
  final Color primaryWine = const Color(0xFF8B2E2E);
  final Color bgColor = const Color(0xFF1A1A1A); // Fondo oscuro "hacker"
  
  // Estado del juego de 8 bits
  List<bool> bits = List.generate(8, (index) => false);
  int numeroObjetivo = 0;
  int valorActual = 0;
  bool resuelto = false;

  @override
  void initState() {
    super.initState();
    _generarNuevoReto();
  }

  void _generarNuevoReto() {
    setState(() {
      // Genera un número aleatorio entre 1 y 255 (rango de 8 bits)
      numeroObjetivo = Random().nextInt(255) + 1;
      bits = List.generate(8, (index) => false);
      valorActual = 0;
      resuelto = false;
    });
  }

  void _toggleBit(int index) {
    if (resuelto) return;

    setState(() {
      bits[index] = !bits[index];
      _calcularValorActual();
      
      if (valorActual == numeroObjetivo) {
        resuelto = true;
        _mostrarExito();
      }
    });
  }

  void _calcularValorActual() {
    int suma = 0;
    // Los bits se leen de derecha a izquierda, pero nuestra lista es de izquierda a derecha.
    // Index 0 es el bit más significativo (128), index 7 es el menos significativo (1)
    for (int i = 0; i < 8; i++) {
      if (bits[i]) {
        suma += pow(2, 7 - i).toInt();
      }
    }
    valorActual = suma;
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 60),
            const SizedBox(height: 10),
            const Text('¡Acceso Concedido!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Lograste convertir el número a binario. El servidor del Edificio de Computación está en línea.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryWine,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context); // Cierra dialog
              Navigator.pop(context); // Regresa al mapa
            },
            child: const Text('Volver al Mapa'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generarNuevoReto();
            },
            child: Text('Jugar de nuevo', style: TextStyle(color: primaryWine)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Reto: Servidor UTM', style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dns_rounded, color: Colors.greenAccent, size: 80),
              const SizedBox(height: 20),
              const Text(
                'ACTIVA LOS INTERRUPTORES PARA IGUALAR LA CIFRA',
                style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Número a alcanzar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Text('OBJETIVO DECIMAL', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(
                      '$numeroObjetivo',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Fila de Bits (Interruptores)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(8, (index) {
                  // Valores de los bits: 128, 64, 32, 16, 8, 4, 2, 1
                  int bitValue = pow(2, 7 - index).toInt();
                  return Column(
                    children: [
                      Text('$bitValue', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _toggleBit(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 35,
                          height: 50,
                          decoration: BoxDecoration(
                            color: bits[index] ? Colors.greenAccent : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: bits[index]
                                ? [const BoxShadow(color: Colors.greenAccent, blurRadius: 10)]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              bits[index] ? '1' : '0',
                              style: TextStyle(
                                color: bits[index] ? Colors.black : Colors.white54,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Valor actual sumado
              Text(
                'PROGRESO: $valorActual',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valorActual > numeroObjetivo ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}