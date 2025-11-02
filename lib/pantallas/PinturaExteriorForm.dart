import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// --- Widget del Formulario de Pintura Exterior ---
/// Este es el widget que debes integrar en tu aplicación.
class PinturaExteriorForm extends StatefulWidget {
  const PinturaExteriorForm({super.key});

  @override
  State<PinturaExteriorForm> createState() => _PinturaExteriorFormState();
}

class _PinturaExteriorFormState extends State<PinturaExteriorForm> {
  // Clave para manejar la validación del formulario
  final _formKey = GlobalKey<FormState>();

  // --- Controladores para campos de texto ---
  final _perimetroController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pisosController = TextEditingController();

  // --- Opciones para Dropdowns ---
  final List<String> _opcionesPropiedad = [
    'Casa de 1 piso',
    'Casa de 2 pisos',
    'Casa de 3+ pisos',
    'Otro'
  ];
  final List<String> _opcionesSuperficie = [
    'Madera',
    'Vinilo',
    'Estuco',
    'Ladrillo',
    'Fibrocemento',
    'Otro'
  ];
  final List<String> _opcionesCondicion = [
    'Buena (Solo limpieza)',
    'Regular (Lijado ligero)',
    'Mala (Lijado profundo, reparaciones)'
  ];
  final List<String> _opcionesCalidadPintura = [
    'Económica (1-3 años)',
    'Estándar (5-7 años)',
    'Premium (10+ años)'
  ];

  // --- Variables para guardar el estado del formulario ---
  String? _tipoPropiedad;
  String? _tipoSuperficie;
  String? _condicionSuperficie;
  String? _calidadPintura;

  bool _lavadoPresion = false;
  bool _pintarTrim = false;
  bool _trimColorDiferente = false;

  // Lista para guardar las fotos (simulada)
  final List<String> _fotos = [];

  @override
  void dispose() {
    // Limpiar controladores al cerrar el widget
    _perimetroController.dispose();
    _alturaController.dispose();
    _pisosController.dispose();
    super.dispose();
  }

  /// Función para manejar el envío del formulario
void _submitForm() {
  if (_formKey.currentState!.validate()) {
    
    // 1. Recolecta los datos (como ya lo haces)
    final estimadoData = {
      'servicio': 'Pintura Exterior',
      'tipoPropiedad': _tipoPropiedad,
      'perimetro': double.tryParse(_perimetroController.text) ?? 0,
      'alturaPiso': double.tryParse(_alturaController.text) ?? 0,
      'numPisos': int.tryParse(_pisosController.text) ?? 0,
      'tipoSuperficie': _tipoSuperficie,
      // ... todos los demás datos ...
      'calidadPintura': _calidadPintura,
      'fotos': _fotos,
    };

    // 2. NO envíes a Firebase todavía.
    // print('--- Datos del Formulario ---'); // (Bueno para debug)

    // 3. NAVEGA a la pantalla de ubicación y PASA LOS DATOS
    //    como "arguments".
    Navigator.pushNamed(
      context, 
      '/ubicacion', 
      arguments: estimadoData, // <--- ¡Esta es la clave!
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
  
  /// Función para simular la carga de fotos
  void _cargarFoto() {
    // En una app real, aquí usarías un paquete como 'image_picker'
    // para abrir la cámara o la galería.
    setState(() {
      // Simulación: añadimos un placeholder
      _fotos.add('foto_placeholder_${_fotos.length + 1}.jpg');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulando carga de foto...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---- EDICIÓN AQUÍ ----
    // Agregamos un Scaffold para que este widget sea una pantalla completa.
    // Esto proporciona el 'Material' necesario para los TextFields y
    // el contexto para el 'ScaffoldMessenger'.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimado: Pintura Exterior'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Sección Tipo de Propiedad ---
                _buildSectionTitle('Información de la Propiedad'),
                _buildDropdown(
                  label: 'Tipo de Propiedad',
                  hint: 'Selecciona el tipo de casa',
                  items: _opcionesPropiedad,
                  value: _tipoPropiedad,
                  onChanged: (newValue) {
                    setState(() {
                      _tipoPropiedad = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // --- Sección Área a Pintar ---
                _buildSectionTitle('Área a Pintar (Cálculo)'),
                _buildTextField(
                  controller: _perimetroController,
                  label: 'Perímetro (Metros lineales)',
                  hint: 'Ej: 50',
                  icon: Icons.straighten,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _alturaController,
                  label: 'Altura promedio por piso (Metros)',
                  hint: 'Ej: 2.5',
                  icon: Icons.height,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _pisosController,
                  label: 'Número de pisos',
                  hint: 'Ej: 2',
                  icon: Icons.layers,
                  isInteger: true,
                ),
                const SizedBox(height: 16),

                // --- Sección Detalles de Superficie ---
                _buildSectionTitle('Detalles de la Superficie'),
                _buildDropdown(
                  label: 'Tipo de Superficie (Siding)',
                  hint: 'Selecciona el material',
                  items: _opcionesSuperficie,
                  value: _tipoSuperficie,
                  onChanged: (newValue) {
                    setState(() {
                      _tipoSuperficie = newValue;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Condición Actual',
                  hint: 'Selecciona la condición',
                  items: _opcionesCondicion,
                  value: _condicionSuperficie,
                  onChanged: (newValue) {
                    setState(() {
                      _condicionSuperficie = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // --- Sección Opciones Adicionales ---
                _buildSectionTitle('Servicios Adicionales'),
                _buildCheckbox(
                  title: '¿Se necesita Lavado a Presión?',
                  subtitle: '(Recomendado para toda pintura exterior)',
                  value: _lavadoPresion,
                  onChanged: (newValue) {
                    setState(() {
                      _lavadoPresion = newValue ?? false;
                    });
                  },
                ),
                _buildCheckbox(
                  title: '¿Pintar el \'trim\'?',
                  subtitle: '(Marcos de ventanas, puertas, cornisas)',
                  value: _pintarTrim,
                  onChanged: (newValue) {
                    setState(() {
                      _pintarTrim = newValue ?? false;
                      // Si desmarcan "pintar trim", reseteamos "trim color diferente"
                      if (!_pintarTrim) {
                        _trimColorDiferente = false;
                      }
                    });
                  },
                ),
                
                // --- Campo Condicional ---
                // Solo se muestra si _pintarTrim es verdadero
                if (_pintarTrim)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: _buildCheckbox(
                      title: '¿El \'trim\' será de un color diferente?',
                      subtitle: '(Requiere más tiempo de encintado)',
                      value: _trimColorDiferente,
                      onChanged: (newValue) {
                        setState(() {
                          _trimColorDiferente = newValue ?? false;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // --- Sección Calidad y Fotos ---
                _buildSectionTitle('Acabado y Fotos'),
                _buildDropdown(
                  label: 'Calidad de Pintura Deseada',
                  hint: 'Selecciona la calidad',
                  items: _opcionesCalidadPintura,
                  value: _calidadPintura,
                  onChanged: (newValue) {
                    setState(() {
                      _calidadPintura = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // --- Sección de Fotos (Simulada) ---
                const Text(
                  'Fotos (Mínimo 4, una por cada lado)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Añadir Foto'),
                  onPressed: _cargarFoto,
                ),
                // Muestra cuántas fotos se han "cargado"
                if (_fotos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${_fotos.length} fotos añadidas.',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                const SizedBox(height: 24),

                // --- Botón de Envío ---
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    label: const Text('Obtener Estimado'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      // --- Estilos añadidos para consistencia ---
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
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
    // ---- FIN DE LA EDICIÓN ----
  }

  /// --- Widgets de Ayuda (Helpers) para construir el formulario ---

  /// Construye un título de sección
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

  /// Construye un campo de texto estándar
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
        // --- Estilos añadidos para consistencia ---
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      // Teclado numérico
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      // Solo permite números (y punto decimal si no es entero)
      inputFormatters: [
        if (isInteger)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      // Validación
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (double.tryParse(value) == null) {
          return 'Por favor, introduce un número válido';
        }
        return null;
      },
    );
  }

  /// Construye un menú desplegable (Dropdown)
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
        // --- Estilos añadidos para consistencia ---
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
      // Validación
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecciona una opción';
        }
        return null;
      },
    );
  }

  /// Construye una casilla de verificación (Checkbox)
  Widget _buildCheckbox({
    required String title,
    String? subtitle,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600))
          : null,
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading, // Checkbox a la izquierda
      contentPadding: EdgeInsets.zero,
    );
  }
}