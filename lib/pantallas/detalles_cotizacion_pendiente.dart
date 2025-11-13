import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Para los formatters de texto
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

  // --- ¡NUEVAS VARIABLES DE ESTADO! ---
  bool _isEditing = false; // Controla el modo edición
  bool _isSaving = false;  // Controla el loading del botón Guardar

  // Controladores para los campos editables
  late TextEditingController _precioController;
  late TextEditingController _tiempoController;
  // --- FIN DE VARIABLES NUEVAS ---


  @override
  void initState() {
    super.initState();
    // Inicializamos los controllers aquí
    _initializeControllers();
    _loadUserData();
  }

  // --- ¡NUEVA FUNCIÓN! ---
  /// Inicializa o resetea los valores de los controllers
  void _initializeControllers() {
    final num? precioNum = widget.cotizacionData['precioEstimado'];
    final int? tiempoNum = widget.cotizacionData['tiempoEstimadoDias'];

    _precioController = TextEditingController(text: precioNum?.toStringAsFixed(2) ?? '0.0');
    _tiempoController = TextEditingController(text: tiempoNum?.toString() ?? '0');
  }

  @override
  void dispose() {
    // Hay que hacer dispose de los controllers
    _precioController.dispose();
    _tiempoController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    try {
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

  // --- ¡NUEVA FUNCIÓN! ---
  /// Guarda solo los campos de precio y tiempo
  void _guardarCambios() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final double nuevoPrecio = double.parse(_precioController.text);
      final int nuevoTiempo = int.parse(_tiempoController.text);

      await _firestore.collection('estimados').doc(widget.cotizacionId).update({
        'precioEstimado': nuevoPrecio,
        'tiempoEstimadoDias': nuevoTiempo,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      // Actualizar los datos locales para que se reflejen en la UI
      // Usamos setState para redibujar la UI
      setState(() {
        widget.cotizacionData['precioEstimado'] = nuevoPrecio;
        widget.cotizacionData['tiempoEstimadoDias'] = nuevoTiempo;
        _isEditing = false; // Salir del modo edición
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente'), backgroundColor: Colors.blue),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }


  // --- ¡FUNCIÓN ACTUALIZADA! ---
  // Esta función ahora SOLO se encarga de ACEPTAR la cotización
  void _actualizarEstado(String nuevoEstado) async {
    // El estado 'rechazada' ya no se usa aquí
    if (nuevoEstado != 'aceptada') return; 

    try {
      await _firestore.collection('estimados').doc(widget.cotizacionId).update({
        'estado_estimado': nuevoEstado,
        // --- ¡CORRECCIÓN DE TYPO AQUÍ! ---
        'fechaActualizacion': DateTime.now().toIso8601String(), // Era 8001
        // --- FIN DE LA CORRECCIÓN ---
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización Aceptada'), // Mensaje específico
          backgroundColor: Colors.green,
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
    // ... (Esta función no cambia) ...
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
    // ... (Esta función no cambia) ...
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
    // ... (Esta función no cambia) ...
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
    // ... (Esta función no cambia) ...
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
    // ... (Esta función no cambia) ...
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
    // ... (Esta función no cambia) ...
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

  // --- ¡NUEVO WIDGET! ---
  /// Un TextFormField con el estilo de la app
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDecimal = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        if (isDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo no puede estar vacío';
        }
        if (isDecimal && double.tryParse(value) == null) {
          return 'Ingresa un número válido';
        }
        if (!isDecimal && int.tryParse(value) == null) {
          return 'Ingresa un número entero';
        }
        return null;
      },
    );
  }
  // --- FIN DE WIDGET NUEVO ---

  @override
  Widget build(BuildContext context) {
    final ubicacion =
        widget.cotizacionData['ubicacion'] as Map<String, dynamic>? ?? {};
    
    // --- LÓGICA DE PRECIO/TIEMPO MOVIDA AQUÍ ---
    // Leemos de los *controllers* si estamos editando,
    // o de los *props* si estamos en modo lectura.
    final num? precioNum = double.tryParse(_precioController.text);
    final String precio = precioNum != null
        ? '\$${precioNum.toStringAsFixed(2)}'
        : 'No calculado';

    final int? tiempo = int.tryParse(_tiempoController.text);
    // --- FIN DE LA LÓGICA ---

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
              // --- ¡NUEVO! AÑADIMOS UN FORM ---
              // para validar los campos de precio y tiempo
              child: Form(
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
                            _buildInfoRow('Nombre', _userData?['nombre']),
                            _buildInfoRow('Email', _userData?['email']),
                            _buildInfoRow('Teléfono', _userData?['telefono']),
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
                            
                            // --- ¡SECCIÓN MODIFICADA! ---
                            // Muestra campos de texto o texto normal
                            // dependiendo del estado _isEditing
                            if (_isEditing) ...[
                              // MODO EDICIÓN
                              const SizedBox(height: 16),
                              _buildEditableField(
                                controller: _precioController,
                                label: 'Precio Estimado',
                                icon: Icons.attach_money,
                                isDecimal: true,
                              ),
                              const SizedBox(height: 12),
                              _buildEditableField(
                                controller: _tiempoController,
                                label: 'Tiempo Estimado (días)',
                                icon: Icons.schedule,
                                isDecimal: false,
                              ),
                              const SizedBox(height: 8),
                            ] else ...[
                              // MODO LECTURA
                              _buildInfoRow(
                                'Precio estimado',
                                precio,
                              ),
                              if (tiempo != null)
                                _buildInfoRow('Tiempo estimado', '$tiempo días'),
                            ],
                            // --- FIN DE LA SECCIÓN ---
                            
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
                            _buildInfoRow('Ciudad', ubicacion['municipio']), 
                            _buildInfoRow('Estado', ubicacion['departamento']),
                            _buildInfoRow('Código Postal', ubicacion['codigoPostal']),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- ¡BOTONES MODIFICADOS! ---
                    _buildBotonesAccion(),
                    // --- FIN DE BOTONES ---

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  // --- ¡NUEVO WIDGET DE BOTONES! ---
  /// Muestra los botones correctos según el estado
  Widget _buildBotonesAccion() {
    // Si estamos en modo EDICIÓN
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () {
                // Resetea los controllers y sale del modo edición
                _initializeControllers();
                setState(() => _isEditing = false);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _guardarCambios, // Llama a guardar
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700], // Botón azul
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : const Text('Guardar Cambios'),
            ),
          ),
        ],
      );
    }
    
    // Si estamos en modo LECTURA
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _isEditing = true), // Entra a modo edición
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue[700]!),
            ),
            child: Text(
              'Editar',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _actualizarEstado('aceptada'), // Confirma
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirmar'),
          ),
        ),
      ],
    );
  }
  // --- FIN DE WIDGET DE BOTONES ---
}