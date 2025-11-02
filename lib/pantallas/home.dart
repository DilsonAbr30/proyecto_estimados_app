import 'package:flutter/material.dart';
import 'package:proyeto_estimados/pantallas/servicios.dart'; 
import 'package:proyeto_estimados/pantallas/cotizacion.dart'; 

// Las rutas ya no son necesarias si usamos MaterialPageRoute directamente
// const String serviceRoute = '/service-selection'; 
// const String quoteRoute = '/client-quote';

class HomeClienteScreen extends StatelessWidget {
  const HomeClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mismo color de fondo y AppBar que las pantallas anteriores
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo muy claro
      appBar: AppBar(
        title: const Text(
          'Inicio', // Título simple de bienvenida
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // Puedes agregar aquí un botón de perfil o logout si lo necesitas
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración de Perfil')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensaje de Bienvenida Profesional
              const Text(
                'Bienvenido, Juan Pérez', // Aquí usarías el nombre real del usuario
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona una opción para continuar:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // --- GRID DE OPCIONES (Tarjetas Interactivas) ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85, // Ajuste para evitar el overflow de píxeles
                children: [
                  // Opción 1: Solicitar Servicio
                  _HomeOptionCard(
                    title: 'Solicitar Servicio',
                    subtitle: 'Inicia una nueva cotización',
                    icon: Icons.design_services_rounded,
                    color: Colors.blue[700]!,
                    onTap: () {
                      // 🚀 NAVEGACIÓN A PANTALLA SERVICIOS
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServiceSelectionScreen()),
                      );
                    },
                  ),

                  // Opción 2: Mi Cotización
                  _HomeOptionCard(
                    title: 'Mi Cotización',
                    subtitle: 'Ver estado y confirmar trabajo',
                    icon: Icons.request_quote_rounded,
                    color: Colors.teal[700]!,
                    onTap: () {
                      // 🚀 NAVEGACIÓN A PANTALLA COTIZACIÓN
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CotizacionScreen()),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Sección Adicional
              Center(
                child: Text(
                  'Estamos aquí para ayudarte. Si tienes dudas, contáctanos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

// ---
// Componente de Tarjeta de Opción (Elegante y Reusable)
// ---

class _HomeOptionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HomeOptionCard> createState() => _HomeOptionCardState();
}

class _HomeOptionCardState extends State<_HomeOptionCard> {
  // Estado para el efecto de Hover/Tap (retroalimentación visual)
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering ? widget.color.withOpacity(0.6) : Colors.grey[200]!,
              width: _isHovering ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovering ? widget.color.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                spreadRadius: _isHovering ? 3 : 1,
                blurRadius: _isHovering ? 15 : 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icono principal
              Icon(
                widget.icon,
                size: 48,
                color: widget.color,
              ),
              
              const Spacer(), // Ocupa el espacio sobrante

              // Título
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Subtítulo/Descripción
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
