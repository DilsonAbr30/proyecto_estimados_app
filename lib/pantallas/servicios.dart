import 'package:flutter/material.dart';
// 1. Importaciones de las pantallas de formularios
import 'package:proyeto_estimados/pantallas/PinturaInterior.dart';
import 'package:proyeto_estimados/pantallas/PinturaExteriorForm.dart';
import 'package:proyeto_estimados/pantallas/TexturaTecho.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  // Lista de servicios (ya estaba actualizada)
  final List<Map<String, dynamic>> _services = [
    {'title': 'Pintura Interior', 'icon': Icons.format_paint, 'selected': false},
    {'title': 'Pintura Exterior', 'icon': Icons.house_siding, 'selected': false},
    {'title': 'Nueva textura en cielo falso', 'icon': Icons.texture, 'selected': false},
  ];

  // --- SECCIÓN "OTRO SERVICIO" ELIMINADA ---

  @override
  void initState() {
    super.initState();
    // Listeners de "Otro servicio" eliminados
  }

  // Funciones de "Otro servicio" eliminadas (_onOtherTextChanged, _onOtherFocusChanged, _submitOtherService)

  @override
  void dispose() {
    // Controladores de "Otro servicio" eliminados
    super.dispose();
  }
  
  // La función _navigateToService (que usaba onIconTap) ya no es necesaria, 
  // la selección se hace en toda la tarjeta y se confirma con el botón de abajo.

  void _deselectAllServices() {
    for (var s in _services) {
      s['selected'] = false;
    }
  }

  void _selectService(String title) {
    setState(() {
      _deselectAllServices();
      final service = _services.firstWhere((s) => s['title'] == title);
      service['selected'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedService = _services.firstWhere(
      (s) => s['selected'] == true,
      orElse: () => {'title': 'Ninguno'},
    );

    final serviceTitle = selectedService['title'] as String;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Se mantiene por si acaso
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Servicios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        // --- REDISEÑO: Se quita SingleChildScrollView y se usa Column ---
        // Se pone el botón al final usando un 'Expanded' y un 'Column'
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Selecciona un servicio:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),

              // --- REDISEÑO: Se quita el GridView y se usa un Column ---
              // Esto apila los 3 servicios verticalmente
              Column(
                children: _services.map((service) {
                  return Padding(
                    // Espacio entre cada tarjeta
                    padding: const EdgeInsets.only(bottom: 12.0), 
                    child: _ServiceCardItem( // Usamos el nuevo Widget
                      title: service['title'],
                      icon: service['icon'],
                      isSelected: service['selected'],
                      onTap: () => _selectService(service['title']),
                    ),
                  );
                }).toList(),
              ),
              // --- FIN DE REDISEÑO ---

              // --- "Otro Servicio" y "Divider" ELIMINADOS ---
            ],
          ),
        ),
      ),

      // 👇 Botón fijo abajo
      bottomNavigationBar: Padding(
        // Se quita el viewInsets.bottom, ya que el body no es un scroll
        padding: const EdgeInsets.all(16.0), 
        child: ElevatedButton(
          // La lógica de navegación se mantiene igual
          onPressed: serviceTitle != 'Ninguno'
              ? () {
                  debugPrint("Servicio confirmado: $serviceTitle");

                  // 🚀 LÓGICA DE NAVEGACIÓN (Se mantiene)
                  Widget? destinationScreen;
                  switch (serviceTitle) {
                    case 'Pintura Interior':
                      destinationScreen = const PinturaInteriorScreen();
                      break;
                    case 'Pintura Exterior':
                      destinationScreen = const PinturaExteriorForm();
                      break;
                    case 'Nueva textura en cielo falso':
                      destinationScreen = const TexturaTechoForm();
                      break;
                  }

                  if (destinationScreen != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => destinationScreen!),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: No se encontró la pantalla para "$serviceTitle".')),
                    );
                  }
                }
              : null, // Deshabilitado si no hay nada seleccionado
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            serviceTitle != 'Ninguno'
                ? "Confirmar: $serviceTitle"
                : "Selecciona un servicio",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// ---
// Componente Rediseñado: de _ServiceGridItem a _ServiceCardItem
// ---
class _ServiceCardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  
  // Se eliminó 'onIconTap'
  const _ServiceCardItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade700;

    // Usamos Card y ListTile para un look más limpio y profesional
    return Card(
      elevation: isSelected ? 4 : 1, // Más sombra al seleccionar
      shadowColor: isSelected ? primaryColor.withOpacity(0.5) : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Borde que cambia de color al seleccionar
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.grey[300]!,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onTap: onTap,
        leading: Icon(
          icon,
          size: 32, // Icono más grande
          color: isSelected ? primaryColor : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? primaryColor : Colors.black87,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue[50], // Color de fondo al seleccionar
        shape: RoundedRectangleBorder( // Hacer que la forma del ListTile coincida con la Card
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}