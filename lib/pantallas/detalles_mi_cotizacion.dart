import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para redondear

class DetallesMiCotizacionScreen extends StatefulWidget {
  final String cotizacionId;
  final Map<String, dynamic> cotizacionData;

  const DetallesMiCotizacionScreen({
    super.key,
    required this.cotizacionId,
    required this.cotizacionData,
  });

  @override
  State<DetallesMiCotizacionScreen> createState() =>
      _DetallesMiCotizacionScreenState();
}

class _DetallesMiCotizacionScreenState
    extends State<DetallesMiCotizacionScreen> {
  
  // --- VARIABLES AÑADIDAS ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isUpdating = false; // Para deshabilitar botones mientras se guarda

  // --- ¡NUEVA FUNCIÓN! ---
  /// Actualiza el estado del trabajo en Firebase
  Future<void> _actualizarEstadoTrabajo(String nuevoEstado) async {
    if (_isUpdating) return; // Evitar doble tap
    setState(() => _isUpdating = true);

    try {
      await _firestore.collection('estimados').doc(widget.cotizacionId).update({
        'estado_estimado': nuevoEstado,
        'fechaDecisionCliente': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado == 'trabajo_aceptado'
                ? '¡Trabajo aceptado! Nos pondremos en contacto.'
                : 'Cotización rechazada.'), // Mensaje actualizado
            backgroundColor: nuevoEstado == 'trabajo_aceptado' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context); // Regresar a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  // --- ¡NUEVA FUNCIÓN! ---
  /// Borra la cotización de la base de datos
  Future<void> _borrarCotizacion() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      await _firestore.collection('estimados').doc(widget.cotizacionId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cotización borrada de tu lista.'),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context); // Regresar a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al borrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  // --- Funciones de construcción de UI ---

  Widget _buildDetallesServicio() {
    final servicio = widget.cotizacionData['servicio'] ?? 'No especificado';
    switch (servicio) {
      case 'Pintura Exterior':
        return _buildPinturaExteriorDetalles();
      case 'Pintura Interior':
        return _buildPinturaInteriorDetalles();
      case 'Aplicacion Textura Techo':
        return _buildTexturaTechoDetalles();
      default:
        return _buildDetallesGenericos();
    }
  }

  Widget _buildPinturaExteriorDetalles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Tipo de Propiedad', widget.cotizacionData['tipoPropiedad']),
        _buildInfoRow('Perímetro', '${widget.cotizacionData['perimetro']} m'),
        _buildInfoRow('Altura por piso', '${widget.cotizacionData['alturaPiso']} m'),
        _buildInfoRow('Número de pisos', widget.cotizacionData['numPisos'].toString()),
        _buildInfoRow('Tipo de superficie', widget.cotizacionData['tipoSuperficie']),
        _buildInfoRow('Condición', widget.cotizacionData['condicionSuperficie']),
        _buildInfoRow('Calidad de pintura', widget.cotizacionData['calidadPintura']),
        _buildInfoRow('Lavado a presión', widget.cotizacionData['lavadoPresion'] == true ? 'Sí' : 'No'),
        _buildInfoRow('Pintar trim', widget.cotizacionData['pintarTrim'] == true ? 'Sí' : 'No'),
        if (widget.cotizacionData['trimColorDiferente'] == true)
          _buildInfoRow('Trim color diferente', 'Sí'),
      ],
    );
  }

  Widget _buildPinturaInteriorDetalles() {
    final habitaciones = widget.cotizacionData['habitaciones'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Total de habitaciones', habitaciones.length.toString()),
        ...habitaciones.asMap().entries.map((entry) {
          final index = entry.key;
          final hab = entry.value as Map<String, dynamic>; 
          final num precioNum = hab['precioEstimadoHabitacion'] ?? 0;
          final String precioFormateado = '\$${precioNum.toStringAsFixed(2)}';
          return Card(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            elevation: 0,
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habitación ${index + 1}: ${hab['tipoHabitacion']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  _buildInfoRow('  - Medidas', '${hab['largo']}m x ${hab['ancho']}m'),
                  _buildInfoRow('  - Altura', '${hab['altura']}m'),
                  _buildInfoRow('  - Estado', hab['estadoHabitacion']),
                  _buildInfoRow('  - Precio', precioFormateado, highlight: true),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTexturaTechoDetalles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Tipo de textura', widget.cotizacionData['tipoTextura']),
        _buildInfoRow('Medidas', '${widget.cotizacionData['largoHabitacion']}m x ${widget.cotizacionData['anchoHabitacion']}m'),
        _buildInfoRow('Altura del techo', '${widget.cotizacionData['alturaTecho']}m'),
        _buildInfoRow('Estado del techo', widget.cotizacionData['estadoTecho']),
        _buildInfoRow('Estado habitación', widget.cotizacionData['estadoHabitacion']),
      ],
    );
  }

  Widget _buildDetallesGenericos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.cotizacionData.entries.map((entry) {
        if (entry.key != 'userId' && entry.key != 'ubicacion' && entry.key != 'servicio' && entry.key != 'precioEstimado' && entry.key != 'tiempoEstimadoDias' && entry.key != 'estado_estimado' && entry.key != 'fechaCreacion') {
          return _buildInfoRow(entry.key, entry.value.toString());
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String? value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: TextStyle(
                color: value == null ? Colors.grey : (highlight ? Colors.blue[700] : Colors.black54),
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard(String precio, String? tiempo, String estado) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[700], // Fondo azul principal
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Estimado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.greenAccent[400],
                  size: 40,
                ),
                const SizedBox(width: 8),
                Text(
                  precio,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResumenItem(
                  Icons.schedule,
                  'Tiempo Estimado',
                  tiempo != null ? '$tiempo días' : 'N/A',
                ),
                _buildResumenItem(
                  Icons.info_outline,
                  'Estado',
                  _formatStatus(estado),
                  chipColor: _getStatusColor(estado),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResumenItem(IconData icon, String label, String value, {Color? chipColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            if (chipColor != null) 
              Chip(
                label: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: chipColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              )
            else 
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  // --- FUNCIONES DE ESTADO ACTUALIZADAS ---
  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'aceptada':
      case 'trabajo_aceptado': // Añadido
        return Colors.green[600]!;
      case 'rechazada':
      case 'rechazada_cliente': // Añadido
        return Colors.red[600]!;
      case 'pendiente':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatStatus(String estado) {
    if (estado.isEmpty) return 'Desconocido';
    if (estado == 'trabajo_aceptado') return 'Trabajo Aceptado'; // Añadido
    if (estado == 'rechazada_cliente') return 'Rechazado por ti'; // Añadido
    return estado[0].toUpperCase() + estado.substring(1);
  }

  // --- ¡NUEVO WIDGET DE BOTONES! ---
  /// Muestra los botones de acción correctos según el estado de la cotización
  Widget _buildBotonesDeAccion(String estado) {
    // Si está pendiente, el cliente no puede hacer nada, solo esperar.
    if (estado == 'pendiente' || estado == 'trabajo_aceptado') {
      return const SizedBox.shrink(); // No mostrar nada
    }

    // Si el admin RECHAZÓ la cotización
    if (estado == 'rechazada') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar de mi lista'),
            onPressed: _isUpdating ? null : _borrarCotizacion,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      );
    }

    // Si el admin ACEPTÓ la cotización, el cliente puede confirmar o rechazar.
    if (estado == 'aceptada') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isUpdating ? null : () => _actualizarEstadoTrabajo('rechazada_cliente'), // Cliente rechaza
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Rechazar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isUpdating ? null : () => _actualizarEstadoTrabajo('trabajo_aceptado'), // Cliente acepta
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Aceptar Trabajo'),
              ),
            ),
          ],
        ),
      );
    }
    
    // Si la cotización fue rechazada por el cliente
    if (estado == 'rechazada_cliente') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar de mi lista'),
            onPressed: _isUpdating ? null : _borrarCotizacion,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      );
    }
    
    // Cualquier otro caso
    return const SizedBox.shrink();
  }
  // --- FIN DE LA ADICIÓN ---

  @override
  Widget build(BuildContext context) {
    final ubicacion =
        widget.cotizacionData['ubicacion'] as Map<String, dynamic>? ?? {};
    
    final num? precioNum = widget.cotizacionData['precioEstimado'];
    final String precio = precioNum != null
        ? '\$${precioNum.toStringAsFixed(2)}'
        : 'No calculado';

    final int? tiempo = widget.cotizacionData['tiempoEstimadoDias'];
    final String estado = widget.cotizacionData['estado_estimado'] ?? 'desconocido';


    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo más suave
      appBar: AppBar(
        title: const Text(
          'Detalles de mi Cotización',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Tarjeta de Resumen
                  _buildResumenCard(precio, tiempo?.toString(), estado),
                  
                  const SizedBox(height: 24),
                  
                  // Título para la sección de desglose
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'Desglose del Servicio',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),

                  // Detalles del Servicio
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles del Servicio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Servicio',
                            widget.cotizacionData['servicio'],
                          ),
                          _buildDetallesServicio(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ubicación
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación del Proyecto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // --- BUG CORREGIDO ---
                          _buildInfoRow('Dirección', ubicacion['direccion']),
                          _buildInfoRow('Ciudad', ubicacion['municipio']), // <-- Corregido
                          _buildInfoRow('Estado', ubicacion['departamento']), // <-- Corregido
                          _buildInfoRow('Código Postal', ubicacion['codigoPostal']),
                          
                        ],
                      ),
                    ),
                  ),
                  
                  // --- ¡SECCIÓN DE BOTONES AÑADIDA! ---
                  // Muestra los botones correctos según el estado
                  _buildBotonesDeAccion(estado),
                  // --- FIN DE LA ADICIÓN ---

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}