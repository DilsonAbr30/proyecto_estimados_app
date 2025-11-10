import 'package:flutter/material.dart';
import 'cotizaciones_pendientes.dart';
// --- ¡IMPOORTACIÓN AÑADIDA! ---
import 'cotizaciones_aceptadas.dart'; 

// Widget reutilizable para las tarjetas del administrador
class AdminActionCard extends StatelessWidget {
  final String title;
// ... (resto de tu widget AdminActionCard, no necesita cambios) ...
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AdminActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12, // Gran elevación para un aspecto moderno y avanzado
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // Icono con fondo semitransparente para profesionalidad
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Flecha de navegación
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  // Estilo del AppBar consistente con detalles.dart
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: const Text(
        'Panel de Administración',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], // Degradado
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        // Fondo ligero consistente con el resto de la aplicación
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la sección
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text(
                  'Dashboard de Gestión',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F46E5), // Color primario
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'Selecciona una opción para administrar los procesos.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),

              // 1. Cotizaciones pendientes (Navega a admin.dart)
              AdminActionCard(
                title: 'Cotizaciones pendientes',
                subtitle: 'Revisa y asigna nuevos servicios para cotización.',
                icon: Icons.schedule_send,
                color: Colors.orange.shade700,
                onTap: () {
                  // Navegación a la pantalla admin.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesPendientesScreen(),
                    ),
                  );
                },
              ),

              // 2. Cotizaciones confirmadas
              AdminActionCard(
                title: 'Cotizaciones confirmadas',
                subtitle:
                    'Monitorea el progreso de los servicios ya aceptados.',
                icon: Icons.verified,
                color: Colors.green.shade700,
                
                // --- ¡NAVEGACIÓN ACTUALIZADA! ---
                onTap: () {
                  // Acción para Cotizaciones Confirmadas
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesAceptadasScreen(), // <-- Nueva pantalla
                    ),
                  );
                },
                // --- FIN DE LA ACTUALIZACIÓN ---
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  'Tu panel de control avanzado.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}