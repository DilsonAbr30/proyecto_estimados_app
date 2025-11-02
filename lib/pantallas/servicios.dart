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
  final TextEditingController _otherController = TextEditingController();
  final FocusNode _otherFocusNode = FocusNode();
  bool _isOtherExpanded = false;

  // --- EDICIÓN 1: Lista de servicios actualizada ---
  // Se eliminaron los otros servicios, dejando solo los 3 principales
  final List<Map<String, dynamic>> _services = [
    {'title': 'Pintura Interior', 'icon': Icons.format_paint, 'selected': false},
    {'title': 'Pintura Exterior', 'icon': Icons.house_siding, 'selected': false},
    {'title': 'Nueva textura en cielo falso', 'icon': Icons.texture, 'selected': false},
  ];
  // --- FIN DE EDICIÓN 1 ---

  @override
  void initState() {
    super.initState();
    _otherController.addListener(_onOtherTextChanged);
    _otherFocusNode.addListener(_onOtherFocusChanged);
  }

  void _onOtherTextChanged() {
    // Para que el botón de enviar se actualice si el texto cambia
    setState(() {});
  }
  
  void _onOtherFocusChanged() {
    setState(() {
      // Expande al enfocar y contrae al desenfocar
      _isOtherExpanded = _otherFocusNode.hasFocus;
    });
  }

  void _navigateToService(String serviceName) {
    // Deselecciona los otros servicios al navegar
    _deselectAllServices();

    // Navegación temporal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando temporalmente a: $serviceName'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

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
      // También desactiva el 'Otro' al seleccionar uno de la cuadrícula
      _otherFocusNode.unfocus();
      _otherController.clear();
    });
  }

  void _submitOtherService() {
    if (_otherController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Servicio enviado: ${_otherController.text}'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      // Opcional: Podrías seleccionar este servicio como el confirmado
      // Aunque por ahora solo lo enviamos.
      _otherController.clear();
      _otherFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _otherController.removeListener(_onOtherTextChanged);
    _otherFocusNode.removeListener(_onOtherFocusChanged);
    _otherController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedService = _services.firstWhere(
      (s) => s['selected'] == true,
      orElse: () => {'title': 'Ninguno'},
    );
    
    final serviceTitle = selectedService['title'] as String;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: SingleChildScrollView(
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return _ServiceGridItem(
                          title: service['title'],
                          icon: service['icon'],
                          isSelected: service['selected'],
                          onTap: () => _selectService(service['title']), // Selecciona el servicio
                          onIconTap: () => _navigateToService(service['title']), // Navega al tocar el ícono (como estaba antes)
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),

                    _buildOtherOption(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 👇 Botón fijo abajo
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: ElevatedButton(
          // --- EDICIÓN 2: Lógica de navegación actualizada ---
          onPressed: serviceTitle != 'Ninguno'
              ? () {
                  debugPrint("Servicio confirmado: $serviceTitle");
                  
                  // 🚀 LÓGICA DE NAVEGACIÓN ACTUALIZADA:
                  // Navega a la pantalla correcta según el servicio seleccionado.
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
                    // Fallback por si acaso (aunque no debería pasar con 3 servicios)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: No se encontró la pantalla para "$serviceTitle".')),
                    );
                  }
                }
              : null, // Deshabilitado si no hay nada seleccionado
          // --- FIN DE EDICIÓN 2 ---
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700], // Cambiado a un color más vibrante
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[200], thickness: 1.5, height: 1);
  }

  Widget _buildOtherOption() {
    bool isSubmitEnabled = _otherController.text.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Otro servicio?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedContainer( // 👈 Animación de expansión
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isOtherExpanded ? 56 : 48, // Un poco más alto al expandir
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isOtherExpanded ? Colors.blue[700]! : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Center( // Centrado para mejor look
                  child: TextField(
                    controller: _otherController,
                    focusNode: _otherFocusNode,
                    maxLines: 1,
                    cursorColor: Colors.blue[700],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Escribe otro servicio...',
                      isCollapsed: true,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      _deselectAllServices(); // Deselecciona los otros al empezar a escribir
                      setState(() {
                        _isOtherExpanded = true;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isSubmitEnabled ? _submitOtherService : null,
              child: AnimatedContainer( // 👈 Botón de submit animado
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSubmitEnabled ? Colors.black87 : Colors.grey[400],
                  shape: BoxShape.circle,
                  boxShadow: isSubmitEnabled ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---
// Componente de Ícono y Texto Mejorado
// ---
class _ServiceGridItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onIconTap;

  const _ServiceGridItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer( // 👈 Aplicamos AnimatedContainer para la transición de selección
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[200]!,
            width: isSelected ? 2 : 1, // Borde más grueso al seleccionar
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3), // Sombra de color al seleccionar
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícono más grande y centrado
            GestureDetector(
              onTap: onIconTap, // Mantiene la funcionalidad de navegación al tocar el ícono
              child: Icon(
                icon,
                size: 32, // Ícono más grande
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.blue[700] : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
