import 'package:flutter/material.dart';
import 'package:proyeto_estimados/pantallas/servicios.dart';
import 'package:proyeto_estimados/pantallas/cotizacion.dart';
// --- ¡IMPORTACIONES AÑADIDAS! ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  // --- LÓGICA AÑADIDA PARA OBTENER EL NOMBRE ---
  String _userName = '...'; // Valor inicial mientras carga

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario actual desde Firebase
  Future<void> _loadUserData() async {
    try {
      // 1. Obtener el usuario actual de Auth
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 2. Obtener el documento del usuario de Firestore
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();
        
        if (mounted && userDoc.exists) {
          // 3. Actualizar el estado con el nombre
          setState(() {
            _userName = userDoc.data()?['nombre'] ?? 'Cliente';
          });
        }
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
      if (mounted) {
        setState(() {
          _userName = 'Cliente'; // Valor por defecto en caso de error
        });
      }
    }
  }

  /// Cierra la sesión del usuario y lo regresa al Login
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navegar a Login y eliminar todas las rutas anteriores
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error al cerrar sesión: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // --- FIN DE LÓGICA AÑADIDA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo muy claro
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        // Quitar el botón de regreso automático (si es que aparece)
        automaticallyImplyLeading: false, 
        centerTitle: true,
        actions: [
          // --- ¡BOTÓN DE CERRAR SESIÓN AÑADIDO! ---
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Mensaje de Bienvenida Dinámico ---
              const Text(
                'Bienvenido,',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // El nombre aparece en una línea separada para evitar saltos de texto
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
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

              // --- REDISEÑO: DE GRIDVIEW A COLUMN ---
              Column(
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
                        MaterialPageRoute(
                          builder: (context) => const ServiceSelectionScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16), // Espacio entre tarjetas

                  // Opción 2: Mi Cotización
                  _HomeOptionCard(
                    title: 'Mis Cotizaciones', // Título actualizado
                    subtitle: 'Ver estado y confirmar trabajos', // Subtítulo actualizado
                    icon: Icons.request_quote_rounded,
                    color: Colors.teal[700]!,
                    onTap: () {
                      // 🚀 NAVEGACIÓN A PANTALLA COTIZACIÓN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CotizacionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // --- FIN DE REDISEÑO ---
              
              const SizedBox(height: 40),
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
// Componente Rediseñado: _HomeOptionCard
// Más limpio, sin estado y adaptado a un layout vertical.
// ---
class _HomeOptionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell( // Añade efecto "splash" al tocar
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row( // Layout horizontal: Icono a la izquierda, texto a la derecha
            children: [
              // Icono
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              
              const SizedBox(width: 20),

              // Columna de Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Icono de flecha al final
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}