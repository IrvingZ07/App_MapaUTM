import 'package:flutter/material.dart';

class DetalleLugarScreen extends StatefulWidget {
  final String nombre;
  const DetalleLugarScreen({super.key, required this.nombre});

  @override
  State<DetalleLugarScreen> createState() => _DetalleLugarScreenState();
}

class _DetalleLugarScreenState extends State<DetalleLugarScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  // BASE DE DATOS LOCAL CON LA INFORMACIÓN ESPECÍFICA
  final Map<String, Map<String, dynamic>> infoLugares = {
    'Cómputo': {
      'descripcion':
          'El núcleo tecnológico de la UTM. Aquí se forjan los ingenieros y se desarrollan los proyectos de software y hardware.',
      'imagenes': [
        'assets/images/pois/computo_1.jpg',
        'assets/images/pois/computo_2.jpg',
      ],
      'faqs': [
        {
          'pregunta': '¿Qué es el UsaLab?',
          'respuesta':
              'Es el laboratorio especializado en experiencia de usuario y pruebas de software donde puedes probar tus apps.',
        },
        {
          'pregunta': '¿Dónde encuentro a los profes?',
          'respuesta':
              'Sus cubículos están agrupados por especialidad. Aquí encuentras a los expertos en IA, Redes y Desarrollo Móvil.',
        },
      ],
    },
    'Biblioteca': {
      'descripcion':
          'El lugar ideal para estudiar, investigar y concentrarse. Cuenta con un acervo inmenso de libros especializados en ingeniería.',
      'imagenes': [
        'assets/images/pois/biblioteca_1.jpg',
        'assets/images/pois/biblioteca_2.jpg',
      ],
      'faqs': [
        {
          'pregunta': '¿Cómo pido un libro?',
          'respuesta':
              'Solo necesitas presentar tu credencial de estudiante vigente en el mostrador principal.',
        },
        {
          'pregunta': '¿Hay espacios para equipo?',
          'respuesta':
              'Sí, puedes solicitar un cubículo de estudio cerrado en recepción para discutir tus proyectos sin interrumpir.',
        },
      ],
    },
    'Cafetería': {
      'descripcion':
          'El punto de reunión para recargar energía, desayunar o comer entre clases.',
      'imagenes': [
        'assets/images/pois/cafeteria_1.jpg',
        'assets/images/pois/cafeteria_2.jpg',
      ],
      'faqs': [
        {
          'pregunta': '¿Qué incluye el menú?',
          'respuesta':
              'Ofrecemos menús del día (comida corrida) que incluyen sopa, guisado y agua. También puedes pedir chilaquiles, tortas y café.',
        },
        {
          'pregunta': '¿Cuáles son los horarios?',
          'respuesta':
              'Los desayunos empiezan a las 8:00 AM y la comida corrida se sirve a partir de la 1:00 PM.',
        },
      ],
    },
    'Obelisco': {
      'descripcion':
          'El símbolo arquitectónico de la universidad y el punto de referencia principal del campus.',
      'imagenes': ['assets/images/pois/obelisco_1.jpg'],
      'faqs': [
        {
          'pregunta': '¿Qué representa?',
          'respuesta':
              'Es un monumento en honor al Dr. Modesto Seara Vázquez y a la fundación de la universidad.',
        },
        {
          'pregunta': '¿Puedo tomarme fotos ahí?',
          'respuesta':
              '¡Claro! Es el punto clásico donde todos los estudiantes se toman su foto de generación al graduarse.',
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    // Busca la información del lugar, si no la encuentra pone datos por defecto
    final info =
        infoLugares[widget.nombre] ??
        {
          'descripcion':
              'El edificio de ${widget.nombre} es un espacio vital dentro del campus de la UTM.',
          'imagenes': ['assets/images/mapa/mapa_utm.png'], // Imagen de respaldo
          'faqs': [
            {
              'pregunta': '¿Cuáles son los horarios?',
              'respuesta': 'Generalmente de 8:00 AM a 7:00 PM.',
            },
          ],
        };

    final List<String> imagenes = info['imagenes'];
    final List<Map<String, String>> faqs = info['faqs'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F0),
      appBar: AppBar(
        title: Text(
          widget.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8B2E2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de Imágenes
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _paginaActual = index;
                      });
                    },
                    itemCount: imagenes.length,
                    itemBuilder: (context, index) {
                      // Cambiado a Image.asset para usar tus fotos locales
                      return Image.asset(
                        imagenes[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // Manejo de error por si no has puesto las fotos aún
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                'Falta agregar la imagen\nen la carpeta assets',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Indicadores del Carrusel
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imagenes.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _paginaActual == index
                                ? Colors.white
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Información del Lugar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Acerca de este lugar",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    info['descripcion'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Preguntas Frecuentes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Genera las preguntas dinámicamente
                  ...faqs.map(
                    (faq) => _buildFAQ(faq['pregunta']!, faq['respuesta']!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(String pregunta, String respuesta) {
    return ExpansionTile(
      title: Text(
        pregunta,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B2E2E),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(respuesta, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
