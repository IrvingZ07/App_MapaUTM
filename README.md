# UTM Orienta - Guía Interactiva del Campus

## Descripción
UTM Orienta es una aplicación móvil desarrollada en Flutter diseñada para facilitar la navegación y el conocimiento del campus de la Universidad Tecnológica de la Mixteca. La plataforma integra geolocación en tiempo real, información académica y módulos de gamificación basados en sensores físicos del dispositivo para mejorar la experiencia del usuario.

## Características Principales

### Mapa Interactivo
* Visualización del campus basada en OpenStreetMap.
* Marcadores dinámicos para puntos de interés (POIs) como Cómputo, Biblioteca y Cafetería.
* Localización del usuario en tiempo real mediante GPS.

### Módulos de Información
* Detalles específicos de cada edificio incluyendo laboratorios especializados (UsaLab), cubículos de profesores y servicios disponibles.
* Sección de preguntas frecuentes integrada para resolver dudas comunes sobre trámites y horarios.
* Carrusel de imágenes locales para identificación visual de las instalaciones.

### Interactividad y Minijuegos
* Simulación de combate espacial en el área de Cómputo con controles basados en el acelerómetro.
* Sistema de recolección de objetos mediante inclinación del dispositivo para la sección de Cafetería.
* Evaluación de conocimientos generales de ingeniería mediante una interfaz de trivia en la Biblioteca.

## Requisitos del Sistema
* Flutter SDK (Versión estable).
* Android SDK con nivel de API mínimo 21.
* Sensores de hardware: Acelerómetro y GPS activos.

## Instalación y Configuración

1. Clonar el repositorio:
   git clone https://github.com/usuario/utm_orienta.git

2. Instalar las dependencias:
   flutter pub get

3. Configurar los assets de imagen:
   Asegurarse de que las fotografías del campus se encuentren en la ruta:
   assets/images/pois/

4. Ejecutar la aplicación:
   flutter run

## Dependencias Relevantes
* flutter_map: Para la renderización de cartografía.
* geolocator: Para la gestión de coordenadas GPS.
* sensors_plus: Para la captura de datos del acelerómetro en los minijuegos.
* latlong2: Para el manejo de cálculos geográficos.

## Estructura del Proyecto
* lib/presentations: Contiene las interfaces de usuario y el mapa principal.
* lib/propuesta: Aloja la lógica de los minijuegos y la trivia.
* assets: Almacenamiento de recursos gráficos y mapas base.

## Créditos
Desarrollado como proyecto académico para la Universidad Tecnológica de la Mixteca.
