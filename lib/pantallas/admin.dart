import 'package:flutter/material.dart';
import 'homeAdmin.dart'; // Importamos la pantalla de destino (HomeAdminScreen)

class PanelAdministracion extends StatefulWidget {
  const PanelAdministracion({super.key});

  @override
  State<PanelAdministracion> createState() => _PanelAdministracionState();
}

class _PanelAdministracionState extends State<PanelAdministracion> {
  // Controladores y datos fijos
  late TextEditingController clienteController;
  late TextEditingController ubicacionController;
  late TextEditingController servicioController;
  late TextEditingController metrosController;
  late TextEditingController estadoController;
  late TextEditingController urgenciaController;
  late TextEditingController comentariosController;
  late TextEditingController mensajeController;

  // Datos de simulación para la galería de fotos
  final List<String> _dummyPhotoUrls = [
    'https://placehold.co/100x100/5E8B7E/fff?text=Fachada',
    'https://placehold.co/100x100/B85043/fff?text=Daño+1',
    'https://placehold.co/100x100/C19A6B/fff?text=Daño+2',
    'https://placehold.co/100x100/81B214/fff?text=Techo',
  ];

  @override
  void initState() {
    super.initState();
    clienteController = TextEditingController(text: "Juan Pérez (ID: 4567)");
    ubicacionController = TextEditingController(text: "Av. Principal #123, Col. Centro, CDMX");
    servicioController = TextEditingController(text: "Pintura Interior - 2 Habitaciones");
    
    // Nueva información de la cotización (Dummy Data)
    metrosController = TextEditingController(text: "85 m² (Aprox.)");
    estadoController = TextEditingController(text: "Paredes con humedad y grietas menores. Necesita lijado profundo.");
    urgenciaController = TextEditingController(text: "Alta (Necesita empezar la próxima semana)");
    comentariosController = TextEditingController(text: "El cliente prefiere pintura ecológica y trabajar solo por las tardes. Favor de contactar a su asistente.");
    
    mensajeController = TextEditingController(); // Editable para la respuesta del admin
  }

  @override
  void dispose() {
    clienteController.dispose();
    ubicacionController.dispose();
    servicioController.dispose();
    metrosController.dispose();
    estadoController.dispose();
    urgenciaController.dispose();
    comentariosController.dispose();
    mensajeController.dispose();
    super.dispose();
  }
  
  // FUNCIÓN DE NAVEGACIÓN REQUERIDA
  void _navigateToAdminHome(String action) {
    // Muestra una notificación rápida de la acción
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cotización ${action.toLowerCase()} y procesada.'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navega al HomeAdminScreen y elimina todas las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Widget para la estructura de la tarjeta de información
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(height: 24, color: Color(0xFFE0E0E0), thickness: 1),
          child,
        ],
      ),
    );
  }

  // Nuevo widget para mostrar un solo dato de solo lectura de forma elegante
  Widget _DataDisplayTile({
    required String label,
    required String value,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 2),
                child: Icon(icon, size: 20, color: Colors.grey[600]),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: isMultiline ? null : 3,
                  overflow: isMultiline ?TextOverflow.clip : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget específico para la urgencia con indicador visual
  Widget _UrgencyDisplayTile(String urgencyText) {
    Color urgencyColor;
    IconData urgencyIcon;
    String urgencyLevel;
    
    if (urgencyText.toLowerCase().contains('alta')) {
      urgencyColor = Colors.red[600]!;
      urgencyIcon = Icons.error;
      urgencyLevel = "¡ALTA!";
    } else if (urgencyText.toLowerCase().contains('media')) {
      urgencyColor = Colors.orange[600]!;
      urgencyIcon = Icons.warning;
      urgencyLevel = "MEDIA";
    } else {
      urgencyColor = Colors.green[600]!;
      urgencyIcon = Icons.check_circle;
      urgencyLevel = "BAJA";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: urgencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: urgencyColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(urgencyIcon, size: 24, color: urgencyColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Urgencia: $urgencyLevel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: urgencyColor,
                  ),
                ),
                Text(
                  urgencyText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para la galería de fotos
  Widget _PhotoGalleryDisplay(List<String> photoUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
              "Galería de Fotos (Evidencia)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 100, // Altura fija para el carrusel de imágenes
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: EdgeInsets.only(right: index < photoUrls.length - 1 ? 16 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(photoUrls[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  // Icono que simula una acción (e.g., zoom)
                  child: Icon(Icons.zoom_out_map, color: Colors.white70, size: 36),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Campo normal (editable) para el mensaje
  Widget _buildMessageField(String label, TextEditingController controller, {int maxLines = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          cursorColor: Colors.blue[700],
          decoration: InputDecoration(
              hintText: 'Escribe tu respuesta o cotización...',
              filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantenemos el color de fondo especificado, pero usamos tarjetas blancas para el contenido.
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text(
          'Detalle de Cotización', // Título actualizado para ser más específico
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Aplicamos el mismo degradado que en HomeAdminScreen
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], // Degradado
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la sección
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                    "Detalle de Solicitud de Cotización",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const Divider(color: Color(0xFFE0E0E0)),
              const SizedBox(height: 16),

              // --- 1. DETALLES DEL CLIENTE ---
              _buildInfoCard(
                title: "Detalles del Cliente",
                child: Column(
                  children: [
                    _DataDisplayTile(
                      label: "Cliente",
                      value: clienteController.text,
                      icon: Icons.person_rounded,
                    ),
                    _DataDisplayTile(
                      label: "Ubicación",
                      value: ubicacionController.text,
                      icon: Icons.location_on,
                      isMultiline: true,
                    ),
                  ],
                ),
              ),

              // --- 2. DETALLES DE LA COTIZACIÓN ---
              _buildInfoCard(
                title: "Detalles de la Cotización",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DataDisplayTile(
                      label: "Servicio Solicitado",
                      value: servicioController.text,
                      icon: Icons.format_paint,
                    ),
                    
                    // Metros Cuadrados y Estado en la misma fila
                    Row(
                      children: [
                        Expanded(
                          child: _DataDisplayTile(
                            label: "Metros Cuadrados",
                            value: metrosController.text,
                            icon: Icons.square_foot,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DataDisplayTile(
                            label: "Estado Actual de la Superficie",
                            value: "Ver sección Comentarios", // Referencia a campo largo
                            icon: Icons.texture,
                          ),
                        ),
                      ],
                    ),

                    _UrgencyDisplayTile(urgenciaController.text),
                    
                    _DataDisplayTile(
                      label: "Comentarios Adicionales",
                      value: comentariosController.text,
                      icon: Icons.comment_rounded,
                      isMultiline: true,
                    ),

                    _PhotoGalleryDisplay(_dummyPhotoUrls),
                  ],
                ),
              ),

              // --- 3. MENSAJE Y ACCIONES ---
              _buildMessageField("Mensaje para cliente (Cotización/Respuesta)", mensajeController, maxLines: 5),
              const SizedBox(height: 24),

              // Botones aceptar / rechazar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      // LLAMADA A LA FUNCIÓN DE NAVEGACIÓN
                      onPressed: () => _navigateToAdminHome("Aceptada"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Aceptar y Enviar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      // LLAMADA A LA FUNCIÓN DE NAVEGACIÓN
                      onPressed: () => _navigateToAdminHome("Rechazada"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
