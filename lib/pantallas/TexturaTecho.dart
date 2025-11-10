import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'dart:math'; // Para usar 'ceil' para redondear los días

// -----------------------------------------------------------------
// --- Formulario: Aplicación de Textura en Cielo Falso ---
// -----------------------------------------------------------------
class TexturaTechoForm extends StatefulWidget {
  const TexturaTechoForm({super.key});

  @override
  State<TexturaTechoForm> createState() => _TexturaTechoFormState();
}

class _TexturaTechoFormState extends State<TexturaTechoForm> {
  final _formKey = GlobalKey<FormState>();

  // --- Controladores ---
  final _largoController = TextEditingController();
  final _anchoController = TextEditingController();
  final _alturaController = TextEditingController();

  // --- Opciones para Dropdowns ---
  final _opcionesTextura = ['Popcorn (Palomitas)', 'Knockdown', 'Piel de Naranja (Orange Peel)', 'Lisa (Nivel 4/5)'];
  final _opcionesEstadoTecho = ['Drywall nuevo (sin \'primer\')', 'Ya tiene \'primer\'', 'Ya está pintado'];
  final _opcionesEstadoHabitacion = ['Vacía', 'Amueblada'];

  // --- Estado del formulario ---
  String? _tipoTextura;
  String? _estadoTecho;
  String? _estadoHabitacion;
  int _cantidadFotos = 0;

  @override
  void dispose() {
    _largoController.dispose();
    _anchoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------
  // --- ¡NUEVO! MOTOR DE CÁLCULO DE TEXTURA ---
  // -----------------------------------------------------------------
  Map<String, dynamic> _calcularEstimadoTextura(Map<String, dynamic> datos) {
    
    // --- 1. Definir Precios Base (¡Modifica esto!) ---
    // (Incluye material de textura y labor base)
    const double precioBasePorM2 = 7.0; 
    const double horasPorM2 = 0.1; // 100 m² = 10 horas
    
    // --- 2. Extraer Datos ---
    double largo = datos['largoHabitacion'] ?? 0.0;
    double ancho = datos['anchoHabitacion'] ?? 0.0;
    double altura = datos['alturaTecho'] ?? 2.5; // Asumir 2.5m si no se pone
    String textura = datos['tipoTextura'] ?? 'Knockdown';
    String estadoTecho = datos['estadoTecho'] ?? 'Ya está pintado';
    String estadoHab = datos['estadoHabitacion'] ?? 'Vacía';

    // --- 3. Calcular Área ---
    double areaTotal = largo * ancho;
    if (areaTotal == 0) {
      return {'precioEstimado': 0.0, 'tiempoEstimadoDias': 0};
    }

    // --- 4. Calcular Modificadores (Multiplicadores) ---
    
    // Modificador por Tipo de Textura
    double modTextura = 1.0;
    if (textura == 'Popcorn (Palomitas)') {
      modTextura = 1.3; // Más material y más sucio
    } else if (textura == 'Lisa (Nivel 4/5)') {
      modTextura = 2.5; // MUCHO más trabajo y tiempo (múltiples capas de lijado)
    }

    // Modificador por Estado del Techo (Preparación)
    double modEstado = 1.0;
    if (estadoTecho == 'Drywall nuevo (sin \'primer\')') {
      modEstado = 1.25; // 25% más por aplicar primer
    }

    // Modificador por Muebles (¡Muy importante!)
    // Cubrir todo en una habitación amueblada toma mucho tiempo
    double modMuebles = 1.0;
    if (estadoHab == 'Amueblada') {
      modMuebles = 1.8; // 80% más de tiempo/costo por enmascarar todo
    }

    // Modificador por Altura (andamios)
    double modAltura = 1.0;
    if (altura > 3.0) { // Si el techo mide más de 3 metros
      modAltura = 1.4; // 40% más caro por armar andamios
    }

    // --- 5. Calcular Total ---
    double precioTotalEstimado = precioBasePorM2 * areaTotal * modTextura * modEstado * modMuebles * modAltura;
    double tiempoTotalHoras = horasPorM2 * areaTotal * modTextura * modEstado * modMuebles * modAltura;

    // Asegurar un precio mínimo por visita
    if (precioTotalEstimado < 200.0) {
      precioTotalEstimado = 200.0;
    }

    // --- 6. Calcular Tiempo de Ejecución ---
    // Convertir horas a días (asumiendo 8 horas por día de trabajo)
    int tiempoTotalDias = (tiempoTotalHoras / 8).ceil();
    if (tiempoTotalDias < 1) {
      tiempoTotalDias = 1; // Mínimo 1 día
    }

    print('--- CÁLCULO DE TEXTURA ---');
    print('Área Total: ${areaTotal.toStringAsFixed(2)} m²');
    print('Precio Base: \$${(precioBasePorM2 * areaTotal).toStringAsFixed(2)}');
    print('Modificadores (Textura, Estado, Muebles, Altura): ${(modTextura * modEstado * modMuebles * modAltura).toStringAsFixed(2)}x');
    print('PRECIO FINAL: \$${precioTotalEstimado.toStringAsFixed(2)}');
    print('TIEMPO ESTIMADO: $tiempoTotalDias días');
    print('---------------------------');

    // Devolver los dos valores calculados
    return {
      'precioEstimado': precioTotalEstimado,
      'tiempoEstimadoDias': tiempoTotalDias,
    };
  }
  // --- FIN DEL MOTOR DE CÁLCULO ---


  // --- FUNCIÓN SUBMIT MODIFICADA ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      
      // 1. Recolectar todos los datos en un Map
      final estimadoData = {
        'servicio': 'Aplicacion Textura Techo',
        'largoHabitacion': double.tryParse(_largoController.text) ?? 0,
        'anchoHabitacion': double.tryParse(_anchoController.text) ?? 0,
        'alturaTecho': double.tryParse(_alturaController.text) ?? 0,
        'tipoTextura': _tipoTextura,
        'estadoTecho': _estadoTecho,
        'estadoHabitacion': _estadoHabitacion,
        'cantidadFotos': _cantidadFotos,
      };

      // 2. LLAMA AL MOTOR DE CÁLCULO
      final calculos = _calcularEstimadoTextura(estimadoData);

      // 3. COMBINA los datos del formulario + los datos calculados
      final datosCompletosParaUbicacion = {
        ...estimadoData, // Todos los datos del formulario
        ...calculos,   // Añade 'precioEstimado' y 'tiempoEstimadoDias'
      };

      // (Opcional: imprime para verificar)
      print('--- Datos Completos para enviar a /ubicacion ---');
      print(datosCompletosParaUbicacion);
      print('------------------------------------------------');

      // 4. NAVEGAR a la pantalla de ubicación y PASA LOS DATOS COMPLETOS
      Navigator.pushNamed(
        context, 
        '/ubicacion', 
        arguments: datosCompletosParaUbicacion, // <--- Esta es la clave
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // --- FIN DE LA MODIFICACIÓN ---

  /// Función para simular la carga de fotos
  void _cargarFoto() {
    setState(() {
      _cantidadFotos++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto ${_cantidadFotos} añadida (simulación).'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR MODIFICADA ---
      appBar: AppBar(
        title: const Text(
          'Textura de Techo', // Título actualizado
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- FIN DE LA MODIFICACIÓN ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- Sección Medidas ---
                  _buildSectionTitle('Medidas de la Habitación (Metros)'),
                Row(
                  children: [
                      Expanded(
                      child: _buildTextField(
                          controller: _largoController,
                          label: 'Largo',
                          hint: 'Ej: 4.5',
                          icon: Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 12),
                      Expanded(
                      child: _buildTextField(
                          controller: _anchoController,
                          label: 'Ancho',
                          hint: 'Ej: 3.0',
                          icon: Icons.straighten,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    controller: _alturaController,
                    label: 'Altura del techo',
                    hint: 'Ej: 2.5',
                    icon: Icons.height,
                ),
                const SizedBox(height: 16),
 
                // --- Sección Detalles de Textura ---
                  _buildSectionTitle('Detalles de Textura y Preparación'),
                _buildDropdown(
                  label: 'Tipo de Textura Deseada',
                    hint: 'Selecciona un tipo',
                    items: _opcionesTextura,
                    value: _tipoTextura,
                    onChanged: (val) => setState(() => _tipoTextura = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                    label: 'Estado del Techo Actual',
                    hint: 'Selecciona el estado',
                    items: _opcionesEstadoTecho,
                    value: _estadoTecho,
                    onChanged: (val) => setState(() => _estadoTecho = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                    label: 'Estado de la Habitación',
                    hint: 'Selecciona el estado',
                    items: _opcionesEstadoHabitacion,
                    value: _estadoHabitacion,
                    onChanged: (val) => setState(() => _estadoHabitacion = val),
                ),
                const SizedBox(height: 16),
 
                // --- Sección Fotos ---
                  _buildSectionTitle('Fotos del Techo'),
                const Text('Sube 1-2 fotos del techo actual.'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Añadir Foto'),
                  onPressed: _cargarFoto,
                ),
                if (_cantidadFotos > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '$_cantidadFotos fotos añadidas.',
                        style: TextStyle(color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                const SizedBox(height: 24),
 
                // --- Botón de Enviar ---
                  Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                      label: const Text('Continuar a Ubicación'), // Texto actualizado
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        minimumSize: const Size(double.infinity, 50),
                        // Usa el color primario de tu tema
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitForm, // Llama a la función MODIFICADA
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// --- Widgets de Ayuda (Helpers) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        // Estilos tomados de tu tema
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      inputFormatters: [
        if (isInteger)
          FilteringTextInputFormatter.digitsOnly
        else
          // Permite números decimales (ej. 4.5)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (double.tryParse(value) == null) {
          return 'Número inválido';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        // Estilos tomados de tu tema
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value,
      hint: Text(hint),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona una opción';
        }
        return null;
      },
    );
  }
}