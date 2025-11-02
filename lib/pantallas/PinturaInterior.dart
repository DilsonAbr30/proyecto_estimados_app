import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- (Opcional) Clase de datos para guardar la info de una habitación ---
// Esto hace más fácil manejar la lista de habitaciones
class Habitacion {
  final String tipoHabitacion;
  final double largo;
  final double ancho;
  final double altura;
  final Map<String, bool> quePintar;
  final String? condicionParedes;
  final bool cambioColorDrastico;
  final int numPuertas;
  final int numVentanas;
  final String estadoHabitacion;
  final String calidadPintura;
  final int cantidadFotos;

  Habitacion({
    required this.tipoHabitacion,
    required this.largo,
    required this.ancho,
    required this.altura,
    required this.quePintar,
    this.condicionParedes,
    required this.cambioColorDrastico,
    required this.numPuertas,
    required this.numVentanas,
    required this.estadoHabitacion,
    required this.calidadPintura,
    required this.cantidadFotos,
  });

  // --- MÉTODO AÑADIDO ---
  // Convierte el objeto Habitacion a un Mapa, listo para ser enviado
  Map<String, dynamic> toJson() {
    return {
      'tipoHabitacion': tipoHabitacion,
      'largo': largo,
      'ancho': ancho,
      'altura': altura,
      'quePintar': quePintar,
      'condicionParedes': condicionParedes,
      'cambioColorDrastico': cambioColorDrastico,
      'numPuertas': numPuertas,
      'numVentanas': numVentanas,
      'estadoHabitacion': estadoHabitacion,
      'calidadPintura': calidadPintura,
      'cantidadFotos': cantidadFotos,
    };
  }
}

// -----------------------------------------------------------------
// --- Pantalla Principal: Lista de Habitaciones ---
// -----------------------------------------------------------------
class PinturaInteriorScreen extends StatefulWidget {
  const PinturaInteriorScreen({super.key});

  @override
  State<PinturaInteriorScreen> createState() => _PinturaInteriorScreenState();
}

class _PinturaInteriorScreenState extends State<PinturaInteriorScreen> {
  // Aquí guardamos la lista de habitaciones que el usuario agrega
  final List<Habitacion> _habitaciones = [];

  void _navegarAFormularioHabitacion() async {
    // Navegamos a la pantalla del formulario y esperamos un resultado
    final nuevaHabitacion = await Navigator.push<Habitacion>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioHabitacionScreen(),
      ),
    );

    // Si el usuario guardó (no solo 'atrás'), añadimos la habitación a la lista
    if (nuevaHabitacion != null) {
      setState(() {
        _habitaciones.add(nuevaHabitacion);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${nuevaHabitacion.tipoHabitacion} añadida.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- FUNCIÓN MODIFICADA ---
  void _enviarEstimadoCompleto() {
    if (_habitaciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos una habitación antes de enviar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // 1. Convertir la lista de objetos Habitación a una lista de Mapas
    final List<Map<String, dynamic>> habitacionesData = 
        _habitaciones.map((hab) => hab.toJson()).toList();

    // 2. Crear el paquete de datos del estimado
    final estimadoData = {
      'servicio': 'Pintura Interior',
      'habitaciones': habitacionesData, // Lista de mapas
      'totalHabitaciones': _habitaciones.length,
      // 'fotos': ... (si tuvieras fotos generales del proyecto)
    };

    // Imprime los datos en la consola (para debug)
    print('--- Datos del Formulario Interior (para enviar a /ubicacion) ---');
    print(estimadoData);
    print('-------------------------------------------');

    // 3. NAVEGAR a la pantalla de ubicación y PASA LOS DATOS
    //    como "arguments".
    Navigator.pushNamed(
      context, 
      '/ubicacion', 
      arguments: estimadoData, // <--- Esta es la clave
    );

    // El SnackBar de "enviado" ahora se mostrará en la pantalla de Ubicación
    // después de enviar a Firebase.
  }
  // --- FIN DE LA MODIFICACIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimado: Pintura Interior'),
        // El color se toma del tema principal
      ),
      body: Column(
        children: [
          // --- Lista de habitaciones añadidas ---
          Expanded(
            child: _habitaciones.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Añade habitaciones para tu estimado usando el botón (+).',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    itemCount: _habitaciones.length,
                    itemBuilder: (context, index) {
                      final hab = _habitaciones[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.room, color: Theme.of(context).primaryColor),
                          title: Text(hab.tipoHabitacion, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Área: ${hab.largo}m x ${hab.ancho}m'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _habitaciones.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // --- Botón de Enviar Estimado Completo ---
          Padding(
            // Aumentamos el padding inferior para dejar espacio al FloatingActionButton
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calculate),
              label: const Text('Obtener Estimado Completo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                minimumSize: const Size(double.infinity, 50), // Ancho completo
                // Estilos tomados de tu tema
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _enviarEstimadoCompleto, // Llama a la función MODIFICADA
            ),
          )
        ],
      ),
      // --- Botón flotante para añadir habitación ---
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Añadir Habitacion'),
        onPressed: _navegarAFormularioHabitacion,
      ),
    );
  }
}


// -----------------------------------------------------------------
// --- Pantalla del Formulario: Añadir Habitación Individual ---
// -----------------------------------------------------------------
class FormularioHabitacionScreen extends StatefulWidget {
  const FormularioHabitacionScreen({super.key});

  @override
  State<FormularioHabitacionScreen> createState() => _FormularioHabitacionScreenState();
}

class _FormularioHabitacionScreenState extends State<FormularioHabitacionScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controladores ---
  final _largoController = TextEditingController();
  final _anchoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _puertasController = TextEditingController(text: '0');
  final _ventanasController = TextEditingController(text: '0');

  // --- Opciones para Dropdowns ---
  final _opcionesHabitacion = ['Dormitorio', 'Sala de Estar', 'Comedor', 'Baño', 'Cocina', 'Pasillo', 'Oficina'];
  final _opcionesCondicionParedes = ['Buena', 'Regular (pequeños hoyos)', 'Mala (necesita parches)'];
  final _opcionesEstadoHabitacion = ['Vacía', 'Parcialmente amueblada', 'Llena de muebles'];
  final _opcionesCalidadPintura = ['Económica', 'Estándar (lavable)', 'Premium (anti-hongos)'];

  // --- Estado del formulario ---
  String? _tipoHabitacion;
  String? _condicionParedes;
  String? _estadoHabitacion;
  String? _calidadPintura;
  int _cantidadFotos = 0;

  // Estado para los checkboxes
  final Map<String, bool> _quePintar = {
    'Paredes': false,
    'Cielo Falso (Techo)': false,
    '\'Trim\' (Baseboards/Zócalos)': false,
    'Puertas': false,
    'Marcos de Ventanas': false,
    'Closets': false,
  };
  
  bool _cambioColorDrastico = false;

  @override
  void dispose() {
    _largoController.dispose();
    _anchoController.dispose();
    _alturaController.dispose();
    _puertasController.dispose();
    _ventanasController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Creamos el objeto Habitacion con los datos
      final nuevaHabitacion = Habitacion(
        tipoHabitacion: _tipoHabitacion!,
        largo: double.tryParse(_largoController.text) ?? 0,
        ancho: double.tryParse(_anchoController.text) ?? 0,
        altura: double.tryParse(_alturaController.text) ?? 0,
        quePintar: _quePintar,
        condicionParedes: _quePintar['Paredes']! ? _condicionParedes : null,
        cambioColorDrastico: _quePintar['Paredes']! ? _cambioColorDrastico : false,
        numPuertas: _quePintar['Puertas']! ? (int.tryParse(_puertasController.text) ?? 0) : 0,
        numVentanas: _quePintar['Marcos de Ventanas']! ? (int.tryParse(_ventanasController.text) ?? 0) : 0,
        estadoHabitacion: _estadoHabitacion!,
        calidadPintura: _calidadPintura!,
        cantidadFotos: _cantidadFotos,
      );

      // Regresamos a la pantalla anterior, enviando el nuevo objeto
      Navigator.pop(context, nuevaHabitacion);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      appBar: AppBar(
        title: const Text('Añadir Habitación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Sección Info General ---
                _buildSectionTitle('Información de la Habitación'),
                _buildDropdown(
                  label: 'Tipo de Habitación',
                  hint: 'Selecciona un tipo',
                  items: _opcionesHabitacion,
                  value: _tipoHabitacion,
                  onChanged: (val) => setState(() => _tipoHabitacion = val),
                ),
                const SizedBox(height: 16),

                // --- Sección Medidas ---
                _buildSectionTitle('Medidas (Metros)'),
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

                // --- Sección ¿Qué Pintar? ---
                _buildSectionTitle('¿Qué vamos a pintar?'),
                ..._quePintar.keys.map((String key) {
                  return _buildCheckbox(
                    title: key,
                    value: _quePintar[key]!,
                    onChanged: (val) {
                      setState(() {
                        _quePintar[key] = val ?? false;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),

                // --- Sección Condicional: Paredes ---
                if (_quePintar['Paredes'] == true)
                  _buildConditionalSection(
                    title: 'Detalles de Paredes',
                    children: [
                      _buildDropdown(
                        label: 'Condición de las paredes',
                        hint: 'Selecciona la condición',
                        items: _opcionesCondicionParedes,
                        value: _condicionParedes,
                        onChanged: (val) => setState(() => _condicionParedes = val),
                      ),
                      _buildCheckbox(
                        title: '¿Cambio de color drástico?',
                        subtitle: '(Ej. oscuro a claro)',
                        value: _cambioColorDrastico,
                        onChanged: (val) => setState(() => _cambioColorDrastico = val ?? false),
                      ),
                    ],
                  ),
                
                // --- Sección Condicional: Puertas/Ventanas ---
                if (_quePintar['Puertas'] == true || _quePintar['Marcos de Ventanas'] == true)
                  _buildConditionalSection(
                    title: 'Detalles de Puertas/Ventanas',
                    children: [
                      if (_quePintar['Puertas'] == true)
                        _buildTextField(
                          controller: _puertasController,
                          label: 'Número de puertas a pintar',
                          hint: 'Ej: 2',
                          icon: Icons.door_front_door_outlined,
                          isInteger: true,
                        ),
                      if (_quePintar['Puertas'] == true) const SizedBox(height: 12),
                      if (_quePintar['Marcos de Ventanas'] == true)
                        _buildTextField(
                          controller: _ventanasController,
                          label: 'Número de ventanas a pintar',
                          hint: 'Ej: 3',
                          icon: Icons.window_outlined,
                          isInteger: true,
                        ),
                    ],
                  ),

                // --- Sección Estado y Calidad ---
                _buildSectionTitle('Preparación y Acabado'),
                _buildDropdown(
                  label: 'Estado de la Habitación',
                  hint: 'Selecciona el estado',
                  items: _opcionesEstadoHabitacion,
                  value: _estadoHabitacion,
                  onChanged: (val) => setState(() => _estadoHabitacion = val),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Calidad de Pintura',
                  hint: 'Selecciona la calidad',
                  items: _opcionesCalidadPintura,
                  value: _calidadPintura,
                  onChanged: (val) => setState(() => _calidadPintura = val),
                ),
                const SizedBox(height: 16),

                // --- Sección Fotos ---
                _buildSectionTitle('Fotos'),
                const Text('Sube 2-3 fotos de la habitación.'),
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

                // --- Botón de Guardar Habitación ---
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_task),
                    label: const Text('Guardar Habitación'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _submitForm,
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

  // Widget helper para las secciones que aparecen/desaparecen
  Widget _buildConditionalSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
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
        // --- EDICIÓN AQUÍ: Estilos unificados ---
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
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        // --- EDICIÓN AQUÍ: Permite 0 en campos no requeridos ---
        if (label.contains('Número de')) {
          if (value == null || value.isEmpty) return 'Introduce un número (ej. 0)';
          if (int.tryParse(value) == null) return 'Número inválido';
          return null;
        }
        // Validación estándar para campos requeridos
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
        // --- EDICIÓN AQUÍ: Estilos unificados ---
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
        // --- EDICIÓN AQUÍ: Permite nulo si es condicional ---
        if (label.contains('Condición de las paredes') && _quePintar['Paredes'] == false) {
          return null;
        }
        // Validación estándar
        if (value == null || value.isEmpty) {
          return 'Selecciona una opción';
        }
        return null;
      },
    );
  }

  Widget _buildCheckbox({
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}

