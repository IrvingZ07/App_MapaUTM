import 'package:flutter/material.dart';
import 'map_screen.dart'; // <--- AGREGADO: Importación para que reconozca la pantalla del mapa

// --- MODELO DE DATOS ---
class Materia {
  final String nombre;
  final int totalClases;
  final int maxFaltas = 3;
  Set<DateTime> fechasFaltadas = {};

  Materia({required this.nombre, this.totalClases = 20});

  double get porcentajeAsistencia {
    int asistencias = totalClases - fechasFaltadas.length;
    return (asistencias / totalClases).clamp(0.0, 1.0);
  }

  int get faltasRestantes => maxFaltas - fechasFaltadas.length;
}

// --- PANTALLA PRINCIPAL ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Paleta de colores
  final Color bgColor = const Color(0xFFF9F8F0);
  final Color primaryWine = const Color(0xFF8B2E2E);
  final Color darkText = const Color(0xFF1A1A1A);

  DateTime? selectedDate;
  List<DateTime> diasDelParcial = [];

  List<Materia> misMaterias = [
    Materia(nombre: 'Sistemas Distribuidos'),
    Materia(nombre: 'Desarrollo Móvil'),
    Materia(nombre: 'Inteligencia Artificial'),
  ];

  @override
  void initState() {
    super.initState();
    _generarDiasDelParcial();
  }

  void _generarDiasDelParcial() {
    DateTime fechaInicio = DateTime(DateTime.now().year, 3, 24);
    DateTime fechaFin = DateTime(DateTime.now().year, 4, 24);

    for (int i = 0; i <= fechaFin.difference(fechaInicio).inDays; i++) {
      DateTime dia = fechaInicio.add(Duration(days: i));
      if (dia.weekday != DateTime.saturday && dia.weekday != DateTime.sunday) {
        diasDelParcial.add(dia);
      }
    }
  }

  String _obtenerMesCorto(int mes) {
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return meses[mes - 1];
  }

  void _mostrarMenuFaltas(DateTime fecha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled:
          true, // Permite que se adapte mejor si hay muchas materias
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar falta el ${fecha.day} de ${_obtenerMesCorto(fecha.month)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toca una materia para marcar o desmarcar la falta.',
                      style: TextStyle(color: darkText.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    ...misMaterias.map((materia) {
                      bool tieneFalta = materia.fechasFaltadas.contains(fecha);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          materia.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                        trailing: Switch(
                          activeColor: primaryWine,
                          value: tieneFalta,
                          onChanged: (val) {
                            setState(() {
                              setModalState(() {
                                if (val) {
                                  materia.fechasFaltadas.add(fecha);
                                } else {
                                  materia.fechasFaltadas.remove(fecha);
                                }
                              });
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CABECERA DE PERFIL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '8vo Semestre',
                          style: TextStyle(
                            color: primaryWine.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Irving Zurita',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: primaryWine.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: primaryWine,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ACCESO PRINCIPAL AL MAPA (Hero Card) - MODIFICADO AQUÍ
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [primaryWine, const Color(0xFF6A1E1E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryWine.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -30,
                          bottom: -30,
                          child: Icon(
                            Icons.map_outlined,
                            size: 160,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'GPS + Minijuegos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Explora tu\nCampus UTM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: primaryWine,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // SECCIÓN: CONTROL DE ASISTENCIAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Control de Asistencias',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: darkText.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca un día para registrar o quitar inasistencias.',
                  style: TextStyle(
                    fontSize: 13,
                    color: darkText.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),

                // CALENDARIO HORIZONTAL
                SizedBox(
                  height: 85,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: diasDelParcial.length,
                    itemBuilder: (context, index) {
                      DateTime fecha = diasDelParcial[index];
                      bool diaConFalta = misMaterias.any(
                        (m) => m.fechasFaltadas.contains(fecha),
                      );

                      return GestureDetector(
                        onTap: () => _mostrarMenuFaltas(fecha),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(
                            right: 12,
                            bottom: 5,
                          ), // Espacio para la sombra
                          width: 65,
                          decoration: BoxDecoration(
                            color: diaConFalta ? primaryWine : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              if (diaConFalta)
                                BoxShadow(
                                  color: primaryWine.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              else
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                            border: diaConFalta
                                ? null
                                : Border.all(
                                    color: Colors.grey.withOpacity(0.15),
                                  ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _obtenerMesCorto(fecha.month),
                                style: TextStyle(
                                  color: diaConFalta
                                      ? Colors.white70
                                      : darkText.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${fecha.day}',
                                style: TextStyle(
                                  color: diaConFalta ? Colors.white : darkText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // TARJETAS DE MATERIAS DINÁMICAS (En filas verticales)
                Column(
                  children: misMaterias
                      .map((materia) => _buildResponsiveSubjectCard(materia))
                      .toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET REUTILIZABLE: Tarjeta de Materia Responsiva
  Widget _buildResponsiveSubjectCard(Materia materia) {
    int faltasRestantes = materia.faltasRestantes;
    double porcentaje = materia.porcentajeAsistencia;

    Color progressColor;
    String statusText;

    if (faltasRestantes > 1) {
      progressColor = const Color(0xFF4A8B2E); // Verde
      statusText = 'Quedan $faltasRestantes faltas permitidas';
    } else if (faltasRestantes == 1) {
      progressColor = const Color(0xFFD68A27); // Naranja
      statusText = '¡Cuidado! Solo queda 1 falta';
    } else if (faltasRestantes == 0) {
      progressColor = primaryWine; // Rojo vino
      statusText = 'Límite de faltas alcanzado';
    } else {
      progressColor = Colors.redAccent; // Rojo alerta
      statusText = 'Has reprobado por faltas';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Información de la materia usando Expanded para evitar desbordamientos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materia.nombre,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Animación del porcentaje de asistencia
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: porcentaje),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: darkText,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
