import 'package:flutter/material.dart';
import 'cotizaciones_pendientes.dart';
import 'cotizaciones_aceptadas.dart'; 
// --- ¡IMPORTACIONES NUEVAS! ---
import 'cotizaciones_trabajos_aceptados.dart';
import 'cotizaciones_rechazadas.dart';
// --- ¡IMPORTACIÓN AÑADIDA PARA EL LOGOUT! ---
import 'package:firebase_auth/firebase_auth.dart';

// Widget reutilizable para las tarjetas del administrador
class AdminActionCard
// ... (Tu widget AdminActionCard se queda exactamente igual) ...
extends StatelessWidget {
  final String title;
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
  // --- ¡MODIFICACIÓN 1! ---
  // Ahora la función RECIBE el BuildContext
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      // --- ¡MODIFICACIÓN! ---
      // Se quita el automaticallyImplyLeading para que no salga la flecha de "atrás"
      automaticallyImplyLeading: false,
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
      // --- ¡BOTÓN DE LOGOUT AÑADIDO! ---
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Cerrar Sesión',
          // --- ¡MODIFICACIÓN 2! ---
          // Ahora SÍ tenemos acceso al 'context'
          onPressed: () async {
            // Lógica de Logout
            await FirebaseAuth.instance.signOut(); // <-- LÍNEA AÑADIDA
            // Esta navegación te lleva a la pantalla de Login
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ¡MODIFICACIÓN 3! ---
      // Le pasamos el 'context' a la función
      appBar: _buildAppBar(context),
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

              // 1. Cotizaciones pendientes
              AdminActionCard(
                title: 'Cotizaciones pendientes',
                subtitle: 'Revisa y edita los nuevos estimados.',
                icon: Icons.schedule_send,
                color: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesPendientesScreen(),
                    ),
                  );
                },
              ),

              // 2. Cotizaciones confirmadas (por admin)
              AdminActionCard(
                title: 'Cotizaciones enviadas',
                subtitle: 'Enviadas al cliente, esperando su respuesta.',
                icon: Icons.check_circle_outline, // Icono actualizado
                color: Colors.blue.shade700, // Color actualizado
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesAceptadasScreen(), 
                    ),
                  );
                },
              ),

              // --- ¡NUEVO! 3. Trabajos Aceptados (por cliente) ---
              AdminActionCard(
                title: 'Trabajos Aceptados',
                subtitle: 'Confirmados por el cliente. Listos para agendar.',
                icon: Icons.construction_rounded, // Icono nuevo
                color: Colors.green.shade700, // Color actualizado
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesTrabajosAceptadosScreen(), // <-- Nueva pantalla
                    ),
                  );
                },
              ),

              // --- ¡NUEVO! 4. Historial Rechazado ---
              AdminActionCard(
                title: 'Historial Rechazado',
                subtitle: 'Estimados denegados por admin o cliente.',
                icon: Icons.cancel_outlined, // Icono nuevo
                color: Colors.red.shade700, // Color nuevo
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CotizacionesRechazadasScreen(), // <-- Nueva pantalla
                    ),
                  );
                },
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