class PointOfInterest {
  final String id;
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String imagePath; // Para la galería

  PointOfInterest({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.imagePath,
  });
}