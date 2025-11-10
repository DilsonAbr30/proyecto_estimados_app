import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Para redondear

class DetallesCotizacionPendienteScreen extends StatefulWidget {
  final String cotizacionId;
  final Map<String, dynamic> cotizacionData;

  const DetallesCotizacionPendienteScreen({
    super.key,
    required this.cotizacionId,
    required this.cotizacionData,
  });

  @override
  State<DetallesCotizacionPendienteScreen> createState() =>
      _DetallesCotizacionPendienteScreenState();
}

class _DetallesCotizacionPendienteScreenState
    extends State<DetallesCotizacionPendienteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // --- ¡CORRECCIÓN DE BUG! ---
      // La colección se llama 'usuarios' (en español), no 'users'.
      final userDoc = await _firestore
          .collection('usuarios') // <-- CORREGIDO
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

  void _actualizarEstado(String nuevoEstado) async {
    try {
      await _firestore.collection('estimados').doc(widget.cotizacionId).update({
        'estado_estimado': nuevoEstado,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cotización $nuevoEstado'),
          backgroundColor: nuevoEstado == 'aceptada' ? Colors.green : Colors.red,
        ),
      );

      // Regresar a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          final hab = entry.value as Map<String, dynamic>; // Aseguramos el tipo

          // --- ¡CORRECCIÓN DE BUG! ---
          // El precio puede ser int o double. Usamos 'num' y lo formateamos.
          final num precioNum = hab['precioEstimadoHabitacion'] ?? 0;
          final String precioFormateado = '\$${precioNum.toStringAsFixed(2)}';
          // --- FIN DE CORRECIÓN ---

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
                    precioFormateado, // Usamos el precio formateado
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
    
    // --- ¡CORRECCIÓN DE BUG! ---
    // Usamos 'num' para aceptar int o double
    final num? precioNum = widget.cotizacionData['precioEstimado'];
    final String precio = precioNum != null
        ? '\$${precioNum.toStringAsFixed(2)}'
        : 'No calculado';

    final int? tiempo = widget.cotizacionData['tiempoEstimadoDias'];
    // --- FIN DE CORRECIÓN ---

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalles de Cotización',
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
                            _userData?['nombre'], // Usamos 'nombre'
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
                          // --- Usamos las variables corregidas ---
                          _buildInfoRow(
                            'Precio estimado',
                            precio,
                          ),
                          if (tiempo != null)
                            _buildInfoRow('Tiempo estimado', '$tiempo días'),
                          // --- Fin ---
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
                          // --- ¡CORRECCIÓN DE BUG! ---
                          // Corregidos los nombres de los campos
                          _buildInfoRow('Dirección', ubicacion['direccion']),
                          _buildInfoRow('Municipio', ubicacion['municipio']), 
                          _buildInfoRow('Departamento', ubicacion['departamento']),
                          _buildInfoRow('Código Postal', ubicacion['codigoPostal']),
                          // --- FIN DE CORRECIÓN ---
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _actualizarEstado('rechazada'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            'Rechazar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _actualizarEstado('aceptada'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}