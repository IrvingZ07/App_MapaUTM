import 'package:flutter/material.dart';

class TriviaBiblioteca extends StatefulWidget {
  const TriviaBiblioteca({super.key});

  @override
  State<TriviaBiblioteca> createState() => _TriviaBibliotecaState();
}

class _TriviaBibliotecaState extends State<TriviaBiblioteca> {
  int preguntaActual = 0;
  int puntaje = 0;

  final List<Map<String, dynamic>> preguntas = [
    {
      'pregunta': '¿Cuál es la unidad fundamental de la resistencia eléctrica?',
      'opciones': ['Watt', 'Ohm', 'Volt', 'Ampere'],
      'respuesta': 1,
    },
    {
      'pregunta': 'En programación, ¿qué estructura sigue el principio LIFO?',
      'opciones': ['Cola (Queue)', 'Lista', 'Pila (Stack)', 'Árbol'],
      'respuesta': 2,
    },
    {
      'pregunta': '¿Quién es considerado el padre de la computación?',
      'opciones': ['Bill Gates', 'Alan Turing', 'Steve Jobs', 'Ada Lovelace'],
      'respuesta': 1,
    },
  ];

  void _responder(int index) {
    if (index == preguntas[preguntaActual]['respuesta']) {
      puntaje++;
    }

    if (preguntaActual < preguntas.length - 1) {
      setState(() {
        preguntaActual++;
      });
    } else {
      _mostrarResultado();
    }
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Trivia Terminada"),
        content: Text("Obtuviste $puntaje de ${preguntas.length} puntos."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Volver"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var quiz = preguntas[preguntaActual];
    return Scaffold(
      appBar: AppBar(title: const Text("Trivia de Ingeniería")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pregunta ${preguntaActual + 1}/${preguntas.length}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              quiz['pregunta'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _responder(index),
                    child: Text(quiz['opciones'][index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
