import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para redondear

// --- WIDGET CREADO ---
// Este es un clon de "detalles_cotizacion_pendiente.dart"
// pero SIN los botones de "Aceptar" o "Rechazar".
class DetallesCotizacionAceptadaScreen extends StatefulWidget {
  final String cotizacionId;
  final Map<String, dynamic> cotizacionData;

  const DetallesCotizacionAceptadaScreen({
    super.key,
    required this.cotizacionId,
    required this.cotizacionData,
  });

  @override
  State<DetallesCotizacionAceptadaScreen> createState() =>
      _DetallesCotizacionAceptadaScreenState();
}

class _DetallesCotizacionAceptadaScreenState
    extends State<DetallesCotizacionAceptadaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Esta función se mantiene, ya que necesitamos los datos del cliente
  void _loadUserData() async {
    try {
      final userDoc = await _firestore
          .collection('usuarios') 
          .doc(widget.cotizacionData['userId'])
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data()!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- FUNCIÓN _actualizarEstado ELIMINADA ---
  // No se necesita, ya que esta pantalla es solo de lectura.

  // --- Todas las funciones _build... se mantienen igual ---

  Widget _buildDetallesServicio() {
    final servicio = widget.cotizacionData['servicio'] ?? 'No especificado';
    // ... (El código de esta función es idéntico al de detalles_cotizacion_pendiente.dart) ...
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
        _buildInfoRow(
          'Tipo de Propiedad',
          widget.cotizacionData['tipoPropiedad'],
        ),
        _buildInfoRow('Perímetro', '${widget.cotizacionData['perimetro']} m'),
        _buildInfoRow(
          'Altura por piso',
          '${widget.cotizacionData['alturaPiso']} m',
        ),
        _buildInfoRow(
          'Número de pisos',
          widget.cotizacionData['numPisos'].toString(),
        ),
        _buildInfoRow(
          'Tipo de superficie',
          widget.cotizacionData['tipoSuperficie'],
        ),
        _buildInfoRow(
          'Condición',
          widget.cotizacionData['condicionSuperficie'],
        ),
        _buildInfoRow(
          'Calidad de pintura',
          widget.cotizacionData['calidadPintura'],
        ),
        _buildInfoRow(
          'Lavado a presión',
          widget.cotizacionData['lavadoPresion'] == true ? 'Sí' : 'No',
        ),
        _buildInfoRow(
          'Pintar trim',
          widget.cotizacionData['pintarTrim'] == true ? 'Sí' : 'No',
        ),
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
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habitación ${index + 1}: ${hab['tipoHabitacion']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildInfoRow(
                    '  - Medidas',
                    '${hab['largo']}m x ${hab['ancho']}m',
                  ),
                  _buildInfoRow('  - Altura', '${hab['altura']}m'),
                  _buildInfoRow('  - Estado', hab['estadoHabitacion']),
                  _buildInfoRow(
                    '  - Precio',
                    precioFormateado,
                  ),
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
        _buildInfoRow(
          'Medidas',
          '${widget.cotizacionData['largoHabitacion']}m x ${widget.cotizacionData['anchoHabitacion']}m',
        ),
        _buildInfoRow(
          'Altura del techo',
          '${widget.cotizacionData['alturaTecho']}m',
        ),
        _buildInfoRow('Estado del techo', widget.cotizacionData['estadoTecho']),
        _buildInfoRow(
          'Estado habitación',
          widget.cotizacionData['estadoHabitacion'],
        ),
      ],
    );
  }

  Widget _buildDetallesGenericos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.cotizacionData.entries.map((entry) {
        if (entry.key != 'userId' &&
            entry.key != 'ubicacion' &&
            entry.key != 'servicio') {
          return _buildInfoRow(entry.key, entry.value.toString());
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value ?? 'No especificado',
              style: TextStyle(color: value == null ? Colors.grey : null),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ubicacion =
        widget.cotizacionData['ubicacion'] as Map<String, dynamic>? ?? {};
    
    final num? precioNum = widget.cotizacionData['precioEstimado'];
    final String precio = precioNum != null
        ? '\$${precioNum.toStringAsFixed(2)}'
        : 'No calculado';

    final int? tiempo = widget.cotizacionData['tiempoEstimadoDias'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Título actualizado para reflejar el estado
        title: const Text(
          'Detalles de Cotización Aceptada',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del Cliente
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información del Cliente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Nombre',
                            _userData?['nombre'], 
                          ),
                          _buildInfoRow(
                            'Email',
                            _userData?['email'],
                          ),
                          _buildInfoRow(
                            'Teléfono',
                            _userData?['telefono'],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Detalles del Servicio
                  Card(
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
                          _buildInfoRow(
                            'Precio estimado',
                            precio,
                          ),
                          if (tiempo != null)
                            _buildInfoRow('Tiempo estimado', '$tiempo días'),
                          const SizedBox(height: 8),
                          _buildDetallesServicio(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ubicación
                  Card(
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
                          _buildInfoRow('Dirección', ubicacion['direccion']),
                          _buildInfoRow('Municipio', ubicacion['municipio']), 
                          _buildInfoRow('Departamento', ubicacion['departamento']),
                          _buildInfoRow('Código Postal', ubicacion['codigoPostal']),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- BOTONES DE ACCIÓN ELIMINADOS ---
                  // Ya no hay Row, OutlinedButton ni ElevatedButton aquí.
                  
                ],
              ),
            ),
    );
  }
}