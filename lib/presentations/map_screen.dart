import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// Importaciones de Pantallas y Minijuegos
import 'detalle_lugar_screen.dart';
import '../propuesta/logica-computacion/shooter_jefe.dart';
import '../propuesta/biblioteca-trivia/trivia_screen.dart';
import '../propuesta/cafeteria-game/cafeteria_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controladores y Estado del GPS
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;

  // Centro aproximado de la UTM en Huajuapan
  final LatLng centerUTM = const LatLng(17.826634, -97.804408);

  // LISTA DE POIS con LatLng reales
  final List<Map<String, dynamic>> pois = [
    {
      'name': 'Cómputo',
      'location': const LatLng(17.828093, -97.804796),
      'icon': Icons.computer,
    },
    {
      'name': 'Biblioteca',
      'location': const LatLng(17.827934, -97.802957),
      'icon': Icons.menu_book,
    },
    {
      'name': 'Cafetería',
      'location': const LatLng(17.826398, -97.803069),
      'icon': Icons.coffee,
    },
    {
      'name': 'Obelisco',
      'location': const LatLng(17.827367, -97.804333),
      'icon': Icons.account_balance,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initGPSServices();
  }

  // Inicializar GPS y pedir permisos
  Future<void> _initGPSServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Escuchar la ubicación en tiempo real
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 2,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });
          }
        });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Campus UTM",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B2E2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: centerUTM,
          initialZoom: 17.5, // Zoom ideal para ver calles y edificios
          maxZoom: 19.0, // Límite de acercamiento de OpenStreetMap
          minZoom: 14.0, // Límite de alejamiento para no perderse en Oaxaca
        ),
        children: [
          // 1. CAPA DEL MAPA BASE (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'mx.utm.orienta', // Identificador recomendado
          ),

          // 2. CAPA DE MARCADORES (POIs y Usuario)
          MarkerLayer(
            markers: [
              // Dibujar los POIs
              ...pois.map(
                (poi) => Marker(
                  point: poi['location'],
                  width: 80,
                  height: 80,
                  child: _buildMapPin(poi['name'], poi['icon']),
                ),
              ),

              // Dibujar la ubicación actual del estudiante
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  child: _buildUserLocationMarker(),
                ),
            ],
          ),
        ],
      ),
      // BOTÓN FLOTANTE PARA CENTRAR EN EL USUARIO
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B2E2E),
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 18.0);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Buscando señal GPS...")),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin(String nombre, IconData icon) {
    return GestureDetector(
      onTap: () {
        _mostrarOpcionesPOI(context, nombre);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black38)],
            ),
            child: Icon(icon, color: const Color(0xFF8B2E2E), size: 24),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesPOI(BuildContext context, String nombreLugar) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF9F8F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombreLugar,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón Conocer Más
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B2E2E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text("Conocer más"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleLugarScreen(nombre: nombreLugar),
                        ),
                      );
                    },
                  ),
                  // Botón Jugar
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B2E2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.videogame_asset),
                    label: const Text("Jugar"),
                    onPressed: () {
                      Navigator.pop(context);
                      if (nombreLugar == 'Cómputo') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JefeCarreraShooter(),
                          ),
                        );
                      } else if (nombreLugar == 'Biblioteca') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TriviaBiblioteca(),
                          ),
                        );
                      } else if (nombreLugar == 'Cafetería') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CafeteriaGame(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Minijuego de $nombreLugar en desarrollo...",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
