import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // <-- ¡ELIMINADO!

class MisCotizacionesScreen extends StatefulWidget {
  const MisCotizacionesScreen({super.key});

  @override
  State<MisCotizacionesScreen> createState() => _MisCotizacionesScreenState();
}

class _MisCotizacionesScreenState extends State<MisCotizacionesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  String? _uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _uid = _currentUser!.uid;
    }
    setState(() {
      _isLoading = false;
    });
  }

  // --- Helpers de Estado y Color ---
  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'aceptada':
      case 'trabajo_aceptado':
        return Colors.green[600]!;
      case 'rechazada':
      case 'rechazada_cliente':
        return Colors.red[600]!;
      case 'pendiente':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatStatus(String estado) {
    if (estado.isEmpty) return 'Desconocido';
    if (estado == 'trabajo_aceptado') return 'Trabajo Aceptado';
    if (estado == 'rechazada_cliente') return 'Rechazado por ti';
    if (estado == 'aceptada') return '¡Aprobada por Admin!';
    return estado[0].toUpperCase() + estado.substring(1);
  }

  Widget _buildServiceIcon(String? servicio, Color color) {
    IconData iconData;
    switch (servicio) {
      case 'Pintura Exterior':
        iconData = Icons.house_siding_rounded;
        break;
      case 'Pintura Interior':
        iconData = Icons.format_paint_rounded;
        break;
      case 'Aplicacion Textura Techo':
        iconData = Icons.texture_rounded;
        break;
      default:
        iconData = Icons.build_rounded;
    }
    return Icon(iconData, color: color, size: 28);
  }

  // --- ¡WIDGET DE TARJETA "ESPLÉNDIDO"! ---
  Widget _buildCotizacionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String estado = data['estado_estimado'] ?? 'desconocido';
    final String servicio = data['servicio'] ?? 'Servicio no especificado';
    
    // Formatear el precio
    final num? precioNum = data['precioEstimado'];
    final String precio = precioNum != null
        ? '\$${precioNum.toStringAsFixed(2)}'
        : '--';

    // --- ¡LÓGICA DE FECHA CORREGIDA! ---
    // Esto ahora maneja tanto los Timestamps (nuevos) como los Strings (viejos).
    String fechaFormateada = 'Fecha desconocida';
    if (data['fechaCreacion'] != null) {
      DateTime? fecha;

      // Primero, intentar leerlo como Timestamp (si arreglamos ubicacion.dart)
      if (data['fechaCreacion'] is Timestamp) {
        fecha = (data['fechaCreacion'] as Timestamp).toDate();
      } 
      // Si falla, intentar leerlo como String (el formato que SÍ tenemos)
      else if (data['fechaCreacion'] is String) {
        fecha = DateTime.tryParse(data['fechaCreacion'] as String);
      }
      
      // Si logramos obtener una fecha, la formateamos
      if (fecha != null) {
        // Formato simple: YYYY-MM-DD
        fechaFormateada = fecha.toLocal().toString().split(' ')[0];
      }
    }
    // --- FIN DE LA CORRECCIÓN ---
    
    final Color colorEstado = _getStatusColor(estado);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detalles_mi_cotizacion',
            arguments: {
              'cotizacionId': doc.id,
              'cotizacionData': data,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Fila Superior: Icono, Título y Estado ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceIcon(servicio, colorEstado),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          servicio,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fechaFormateada, // <-- Usa la fecha corregida
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _formatStatus(estado),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: colorEstado,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // --- Fila Inferior: Precio y Flecha ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimado: $precio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ¡WIDGET DE HEADER "BÁRBARO"! ---
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800, // Más grueso
              color: color,
            ),
          ),
          const Expanded(child: Divider(thickness: 1, indent: 10, endIndent: 5)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Un fondo más limpio
      appBar: AppBar(
        title: const Text(
          'Mis Cotizaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _uid == null 
              ? const Center(child: Text('Error: Usuario no identificado.'))
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('estimados')
                      .where('userId', isEqualTo: _uid)
                      .orderBy('fechaCreacion', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      // --- ESTADO VACÍO MEJORADO ---
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 24),
                              const Text(
                                'Aún no tienes cotizaciones',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Inicia un nuevo estimado desde la pantalla de "Inicio" para verlo aquí.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // --- Lógica de Agrupación ---
                    final docs = snapshot.data!.docs;
                    final List<DocumentSnapshot> accionRequerida = [];
                    final List<DocumentSnapshot> trabajosAceptados = [];
                    final List<DocumentSnapshot> pendientes = [];
                    final List<DocumentSnapshot> historial = [];

                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final estado = data['estado_estimado'] ?? 'desconocido';

                      switch (estado) {
                        case 'aceptada':
                          accionRequerida.add(doc);
                          break;
                        case 'trabajo_aceptado':
                          trabajosAceptados.add(doc);
                          break;
                        case 'pendiente':
                          pendientes.add(doc);
                          break;
                        case 'rechazada':
                        case 'rechazada_cliente':
                          historial.add(doc);
                          break;
                      }
                    }

                    // --- Construcción de la vista (Con nuevos Headers) ---
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        
                        // --- GRUPO 1: ACCIÓN REQUERIDA ---
                        if (accionRequerida.isNotEmpty) ...[
                          _buildSectionHeader('Acción Requerida', Icons.warning_amber_rounded, Colors.orange[800]!),
                          ...accionRequerida.map((doc) => _buildCotizacionCard(doc)),
                        ],

                        // --- GRUPO 2: TRABAJOS ACEPTADOS ---
                        if (trabajosAceptados.isNotEmpty) ...[
                          _buildSectionHeader('Trabajos Aceptados', Icons.check_circle_outline_rounded, Colors.green[700]!),
                          ...trabajosAceptados.map((doc) => _buildCotizacionCard(doc)),
                        ],

                        // --- GRUPO 3: PENDIENTES ---
                        if (pendientes.isNotEmpty) ...[
                          _buildSectionHeader('Pendientes (En Revisión)', Icons.hourglass_top_rounded, Colors.blue[700]!),
                          ...pendientes.map((doc) => _buildCotizacionCard(doc)),
                        ],

                        // --- GRUPO 4: HISTORIAL ---
                        if (historial.isNotEmpty) ...[
                          _buildSectionHeader('Historial (Rechazadas)', Icons.history_rounded, Colors.grey[600]!),
                          ...historial.map((doc) => _buildCotizacionCard(doc)),
                        ],

                      ],
                    );
                  },
                ),
    );
  }
}