import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // Para usar 'ceil' para redondear los días

// --- Clase de datos para guardar la info de una habitación ---
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
  
  // --- CAMPOS AÑADIDOS ---
  final double precioEstimadoHabitacion; // El precio de ESTA habitación
  final double tiempoEstimadoHoras; // El tiempo de ESTA habitación

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
    // --- CAMPOS AÑADIDOS AL CONSTRUCTOR ---
    required this.precioEstimadoHabitacion,
    required this.tiempoEstimadoHoras,
  });

  // --- MÉTODO ACTUALIZADO ---
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
      // --- CAMPOS AÑADIDOS AL JSON ---
      'precioEstimadoHabitacion': precioEstimadoHabitacion,
      'tiempoEstimadoHoras': tiempoEstimadoHoras,
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
          content: Text('${nuevaHabitacion.tipoHabitacion} añadida. Precio: \$${nuevaHabitacion.precioEstimadoHabitacion.toStringAsFixed(2)}'),
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
    
    // --- LÓGICA DE CÁLCULO TOTAL AÑADIDA ---
    double precioTotalGeneral = 0.0;
    double tiempoTotalGeneralHoras = 0.0;

    // 1. Sumar los totales de cada habitación
    for (var hab in _habitaciones) {
      precioTotalGeneral += hab.precioEstimadoHabitacion;
      tiempoTotalGeneralHoras += hab.tiempoEstimadoHoras;
    }

    // Convertir horas a días (asumiendo 8 horas por día de trabajo)
    int tiempoTotalGeneralDias = (tiempoTotalGeneralHoras / 8).ceil();
    if (tiempoTotalGeneralDias == 0) tiempoTotalGeneralDias = 1; // Mínimo 1 día


    // 2. Convertir la lista de objetos Habitación a una lista de Mapas
    final List<Map<String, dynamic>> habitacionesData = 
        _habitaciones.map((hab) => hab.toJson()).toList();

    // 3. Crear el paquete de datos del estimado
    final estimadoData = {
      'servicio': 'Pintura Interior',
      'habitaciones': habitacionesData, // Lista de mapas
      'totalHabitaciones': _habitaciones.length,
      
      // --- TOTALES AÑADIDOS ---
      'precioEstimado': precioTotalGeneral,
      'tiempoEstimadoDias': tiempoTotalGeneralDias,
    };

    // Imprime los datos en la consola (para debug)
    print('--- Datos del Formulario Interior (para enviar a /ubicacion) ---');
    print(estimadoData);
    print('-------------------------------------------');

    // 4. NAVEGAR a la pantalla de ubicación y PASA LOS DATOS
    Navigator.pushNamed(
      context, 
      '/ubicacion', 
      arguments: estimadoData, // <--- Esta es la clave
    );
  }
  // --- FIN DE LA MODIFICACIÓN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR MODIFICADA ---
      appBar: AppBar(
        title: const Text(
          'Pintura Interior',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                          // --- SUBTÍTULO ACTUALIZADO PARA MOSTRAR PRECIO ---
                          subtitle: Text('Área: ${hab.largo}m x ${hab.ancho}m | Precio: \$${hab.precioEstimadoHabitacion.toStringAsFixed(2)}'),
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
          
          // --- BOTÓN DE ENVIAR ELIMINADO DE AQUÍ ---
          // Se quitó el Padding( ... ElevatedButton.icon ... ) que estaba aquí.
        ],
      ),

      // --- 1. EL FLOATING ACTION BUTTON SE QUEDA IGUAL ---
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Añadir Habitación'),
        onPressed: _navegarAFormularioHabitacion,
      ),

      // --- 2. EL BOTÓN "CONTINUAR" AHORA ES UN BOTTOMNAVBAR ESTÁTICO ---
      bottomNavigationBar: Container(
        // padding para que no quede pegado a los bordes y al fondo (para gestos de iOS/Android)
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco para que contraste
          boxShadow: [
            BoxShadow( // Sombra para separarlo del contenido
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calculate),
          label: const Text('Continuar a Ubicación'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            // Lógica para deshabilitar el botón si no hay habitaciones
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          // Se deshabilita si la lista está vacía
          onPressed: _habitaciones.isEmpty ? null : _enviarEstimadoCompleto, 
        ),
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

  // -----------------------------------------------------------------
  // --- ¡NUEVO! MOTOR DE CÁLCULO POR HABITACIÓN ---
  // -----------------------------------------------------------------
  Map<String, dynamic> _calcularEstimadoHabitacion(Map<String, dynamic> datos) {

    // --- 1. Definir Precios Base (¡Modifica esto!) ---
    const double precioParedPorM2 = 8.0;
    const double precioTechoPorM2 = 5.0;
    const double precioTrimPorML = 3.0; // ML = Metro Lineal
    const double precioPorPuerta = 40.0;
    const double precioPorVentana = 30.0;
    const double precioPorCloset = 50.0;
    const double horasPorM2 = 0.15; // 100 m² = 15 horas
    const double horasPorPuerta = 1.0;
    const double horasPorVentana = 0.75;
    
    // --- 2. Extraer Datos ---
    double largo = datos['largo'] ?? 0.0;
    double ancho = datos['ancho'] ?? 0.0;
    double altura = datos['altura'] ?? 0.0;
    Map<String, bool> quePintar = datos['quePintar'] ?? {};
    String condicion = datos['condicionParedes'] ?? 'Buena';
    String estadoHab = datos['estadoHabitacion'] ?? 'Vacía';
    bool cambioDrastico = datos['cambioColorDrastico'] ?? false;
    int numPuertas = datos['numPuertas'] ?? 0;
    int numVentanas = datos['numVentanas'] ?? 0;
    
    // --- 3. Calcular Áreas ---
    double areaParedes = (largo + ancho) * 2 * altura;
    double areaTecho = largo * ancho;
    double metrosLinealesTrim = (largo + ancho) * 2;

    // --- 4. Calcular Modificadores ---
    double modCondicion = 1.0;
    if (condicion == 'Regular (pequeños hoyos)') modCondicion = 1.25;
    if (condicion == 'Mala (necesita parches)') modCondicion = 1.6;

    double modMuebles = 1.0;
    if (estadoHab == 'Parcialmente amueblada') modMuebles = 1.2;
    if (estadoHab == 'Llena de muebles') modMuebles = 1.5;

    double modColor = cambioDrastico ? 1.3 : 1.0; // 30% más por necesitar primer

    // --- 5. Calcular Costos y Tiempos Parciales ---
    double precioParedes = 0, horasParedes = 0;
    if (quePintar['Paredes'] == true) {
      precioParedes = areaParedes * precioParedPorM2 * modCondicion * modColor;
      horasParedes = areaParedes * horasPorM2 * modCondicion * modColor;
    }

    double precioTecho = 0, horasTecho = 0;
    if (quePintar['Cielo Falso (Techo)'] == true) {
      precioTecho = areaTecho * precioTechoPorM2;
      horasTecho = areaTecho * horasPorM2;
    }

    double precioTrim = 0, horasTrim = 0;
    if (quePintar['\'Trim\' (Baseboards/Zócalos)'] == true) {
      precioTrim = metrosLinealesTrim * precioTrimPorML;
      horasTrim = metrosLinealesTrim * 0.1; // 0.1 horas por metro lineal
    }

    double precioPuertas = 0, horasPuertas = 0;
    if (quePintar['Puertas'] == true) {
      precioPuertas = numPuertas * precioPorPuerta;
      horasPuertas = numPuertas * horasPorPuerta;
    }

    double precioVentanas = 0, horasVentanas = 0;
    if (quePintar['Marcos de Ventanas'] == true) {
      precioVentanas = numVentanas * precioPorVentana;
      horasVentanas = numVentanas * horasPorVentana;
    }

    double precioClosets = 0, horasClosets = 0;
    if (quePintar['Closets'] == true) {
      // Asumir un costo y tiempo fijo por closet
      precioClosets = precioPorCloset;
      horasClosets = 1.5; // 1.5 horas por closet
    }

    // --- 6. Sumar Totales y aplicar Modificador de Muebles ---
    double precioTotalHabitacion = (precioParedes + precioTecho + precioTrim + precioPuertas + precioVentanas + precioClosets) * modMuebles;
    double tiempoTotalHoras = (horasParedes + horasTecho + horasTrim + horasPuertas + horasVentanas + horasClosets) * modMuebles;

    // Asegurar un mínimo
    if (precioTotalHabitacion > 0 && precioTotalHabitacion < 100) precioTotalHabitacion = 100; // Mínimo $100 por habitación
    if (tiempoTotalHoras > 0 && tiempoTotalHoras < 2) tiempoTotalHoras = 2; // Mínimo 2 horas

    print('--- CÁLCULO HABITACIÓN ---');
    print('Precio: \$${precioTotalHabitacion.toStringAsFixed(2)}');
    print('Horas: ${tiempoTotalHoras.toStringAsFixed(2)}');
    print('--------------------------');

    return {
      'precioEstimadoHabitacion': precioTotalHabitacion,
      'tiempoEstimadoHoras': tiempoTotalHoras,
    };
  }
  // --- FIN DEL MOTOR DE CÁLCULO ---


  // --- FUNCIÓN SUBMIT MODIFICADA ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      
      // 1. Recolectar datos del formulario
      final datosHabitacion = {
        'tipoHabitacion': _tipoHabitacion!,
        'largo': double.tryParse(_largoController.text) ?? 0,
        'ancho': double.tryParse(_anchoController.text) ?? 0,
        'altura': double.tryParse(_alturaController.text) ?? 0,
        'quePintar': _quePintar,
        'condicionParedes': _quePintar['Paredes']! ? _condicionParedes : null,
        'cambioColorDrastico': _quePintar['Paredes']! ? _cambioColorDrastico : false,
        'numPuertas': _quePintar['Puertas']! ? (int.tryParse(_puertasController.text) ?? 0) : 0,
        'numVentanas': _quePintar['Marcos de Ventanas']! ? (int.tryParse(_ventanasController.text) ?? 0) : 0,
        'estadoHabitacion': _estadoHabitacion!,
        'calidadPintura': _calidadPintura!,
        'cantidadFotos': _cantidadFotos,
      };

      // 2. Calcular precio y tiempo para ESTA habitación
      final calculos = _calcularEstimadoHabitacion(datosHabitacion);

      // 3. Creamos el objeto Habitacion con los datos Y los cálculos
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
        // --- Pasar los valores calculados ---
        precioEstimadoHabitacion: calculos['precioEstimadoHabitacion']!,
        tiempoEstimadoHoras: calculos['tiempoEstimadoHoras']!,
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
      appBar: AppBar(
        // --- APPBAR MODIFICADA ---
        title: const Text(
          'Añadir Habitación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        if (label.contains('Número de')) {
          if (value == null || value.isEmpty) return 'Introduce un número (ej. 0)';
          if (int.tryParse(value) == null) return 'Número inválido';
          return null;
        }
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
        if (label.contains('Condición de las paredes') && _quePintar['Paredes'] == false) {
          return null; // No validar si no se pintan paredes
        }
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