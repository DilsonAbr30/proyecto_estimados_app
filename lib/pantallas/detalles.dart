import 'package:flutter/material.dart';
// Importa la pantalla de destino (asumiendo que existe en el mismo nivel)
import 'home.dart';

class DetallesScreen extends StatefulWidget {
  // Aseguramos que el argumento location se maneje correctamente
  final String location;
  const DetallesScreen({super.key, required this.location});

  @override
  State<DetallesScreen> createState() => _DetallesScreenState();
}

class _DetallesScreenState extends State<DetallesScreen> {
  final TextEditingController metrosController = TextEditingController(text: "5");
  final TextEditingController comentariosController = TextEditingController();
  String estadoSuperficie = "";
  String urgencia = "";

  final List<String> estados = ["Buena", "Regular", "Dañada"];
  final List<String> urgencias = ["Normal", "Urgente"];

  @override
  void dispose() {
    metrosController.dispose();
    comentariosController.dispose();
    super.dispose();
  }

  // FUNCIÓN CLAVE: Muestra el diálogo y navega al home
  void _sendInformation() {
    // 1. (Opcional) Mostrar datos en la consola para depuración
    debugPrint(
        "ENVIANDO: Ubicación: ${widget.location}, Metros: ${metrosController.text} m², Estado: $estadoSuperficie, Urgencia: $urgencia, Comentarios: ${comentariosController.text}");

    // 2. Mostrar el diálogo de "Información enviada"
    showDialog(
      context: context,
      barrierDismissible: false, // Bloquea la interacción fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Información enviada', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
          content: const Text('Los detalles de tu servicio han sido enviados exitosamente. Serás redirigido al inicio.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                // 2.1. Cerrar el diálogo
                Navigator.of(context).pop();
                
                // 2.2. Redirigir al Home y limpiar la pila de navegación
                // Esto asegura que el usuario no pueda usar el botón 'atrás' para volver aquí.
                Navigator.pushAndRemoveUntil(
                  context,
                  // Asumimos que HomeScreen existe en home.dart
                  MaterialPageRoute(builder: (context) => const HomeClienteScreen()), 
                  (Route<dynamic> route) => false, // La condición `false` elimina todas las rutas anteriores
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      appBar: AppBar(

        centerTitle: true,

        elevation: 0,

        title: const Text('Detalles del servicio'),

        flexibleSpace: Container(

          decoration: const BoxDecoration(

            gradient: LinearGradient(

              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],

              begin: Alignment.topLeft,

              end: Alignment.bottomRight,

            ),

          ),

        ),

      ),

      body: SafeArea(

        child: Container(

          decoration: const BoxDecoration(

            gradient: LinearGradient(

              colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],

              begin: Alignment.topCenter,

              end: Alignment.bottomCenter,

            ),

          ),

          padding: const EdgeInsets.all(16),

          child: SingleChildScrollView(

            child: Card(

              shape: RoundedRectangleBorder(borderRadius:
                  BorderRadius.circular(16)),

              elevation: 8,

              child: Padding(

                padding: const EdgeInsets.symmetric(horizontal:
                    18, vertical: 20),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Header

                    Row(

                      children: [

                        Container(

                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(

                            gradient: const LinearGradient(

                              colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],

                            ),

                            borderRadius: BorderRadius.circular(12),

                          ),

                          child: const Icon(Icons.home_repair_service, color: Colors.white, size: 28),

                        ),

                        const SizedBox(width: 12),

                        Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text('Detalles del servicio', style: theme.textTheme.titleLarge),

                            const SizedBox(height: 4),

                            Text(
                              'Completa la información para cotizar',
                              style: theme.textTheme.bodySmall?.copyWith(color:
                                  Colors.grey[600]),

                            ),

                          ],

                        ),

                      ],

                    ),

                    const SizedBox(height:
                        20),
                    
                    // Metros

                    const Text('Metros cuadrados o dimensiones', style: TextStyle(fontWeight: FontWeight.w600)),

                    const SizedBox(height:
                        8),

                    Row(

                      children: [

                        Expanded(

                          child: TextField(

                            controller: metrosController,

                            keyboardType: const TextInputType.numberWithOptions(decimal: true),

                            decoration: InputDecoration(

                              hintText: "5",

                              prefixIcon: const Icon(Icons.square_foot),

                              suffixText: "m²",

                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                            ),

                          ),

                        ),

                        const SizedBox(width:
                            12),

                        ElevatedButton.icon(

                          onPressed: () {
                            debugPrint('Medida rápida: ${metrosController.text} m²');
                          },

                          icon: const Icon(Icons.straighten),

                          label: const Text("Medir"),

                          style: ElevatedButton.styleFrom(

                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height:
                        18),

                    // Estado
                    // superficie

                    const Text('Estado actual de la superficie', style: TextStyle(fontWeight: FontWeight.w600)),

                    const SizedBox(height:
                        8),

                    Wrap(

                      spacing: 8,

                      children: estados.map((e) {

                        final selected = estadoSuperficie == e;

                        return ChoiceChip(

                          label: Text(e),

                          selected: selected,

                          onSelected: (sel) => setState(() => estadoSuperficie = sel ? e : ""),

                          selectedColor: theme.colorScheme.primary,

                          backgroundColor: Colors.grey[200],

                          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),

                        );

                      }).toList(),

                    ),

                    const SizedBox(height:
                        18),

                    // Urgencia

                    const Text('Urgencia', style: TextStyle(fontWeight: FontWeight.w600)),

                    const SizedBox(height:
                        8),

                    Row(

                      children: urgencias.map((u) {

                        final isSelected = urgencia == u;

                        return Expanded(

                          child: Container(

                            margin: const EdgeInsets.only(right: 8),

                            child: OutlinedButton(

                              style: OutlinedButton.styleFrom(

                                backgroundColor: isSelected ? theme.colorScheme.primary
                                    : Colors.transparent,

                                foregroundColor: isSelected ? Colors.white : Colors.black87,

                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                                side: BorderSide(color: isSelected ? theme.colorScheme.primary
                                    : Colors.grey.shade300),

                                padding: const EdgeInsets.symmetric(vertical: 14),

                              ),

                              onPressed: () => setState(() => urgencia = isSelected
                                  ? "" : u),

                              child: Text(u),

                            ),

                          ),

                        );

                      }).toList(),

                    ),

                    const SizedBox(height:
                        18),

                    // Comentarios

                    const Text('Comentarios adicionales', style: TextStyle(fontWeight: FontWeight.w600)),

                    const SizedBox(height:
                        8),

                    TextField(

                      controller: comentariosController,

                      maxLines: 4,

                      decoration: InputDecoration(

                        hintText: "Describe cualquier detalle importante...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                      ),

                    ),

                    const SizedBox(height:
                        18),

                    // Fotos /
                    // placeholder

                    const Text('Fotos', style: TextStyle(fontWeight: FontWeight.w600)),

                    const SizedBox(height:
                        8),

                    Container(

                      height: 120,

                      decoration: BoxDecoration(

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: Colors.grey.shade300),

                        color: Colors.grey.shade50,

                      ),

                      child: Center(

                        child: Column(

                          mainAxisSize: MainAxisSize.min,

                          children: const [

                            Icon(Icons.photo_camera, size: 36, color: Colors.grey),

                            SizedBox(height: 6),

                            Text('Agrega fotos para mejor cotización', style: TextStyle(color:
                                Colors.grey)),

                          ],

                        ),

                      ),

                    ),

                    const SizedBox(height:
                        18),

                    //
                    // Acciones

                    Row(

                      children: [

                        Expanded(

                          child: OutlinedButton.icon(

                            onPressed: () => debugPrint('Agregar fotos pulsado'),

                            icon: const Icon(Icons.add_a_photo),

                            label: const Text("Agregar fotos"),

                            style: OutlinedButton.styleFrom(

                              padding: const EdgeInsets.symmetric(vertical: 14),

                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                            ),

                          ),

                        ),

                        const SizedBox(width:
                            12),

                        Expanded(

                          child: ElevatedButton.icon(

                            // ¡Conecta el botón a la nueva función!
                            onPressed: _sendInformation,

                            icon: const Icon(Icons.send),

                            label: const Text("Enviar"),

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height:
                        6),

                    Center(

                      child: Text(
                        'Tu cliente verá una cotización más precisa si agregas fotos y comentarios.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontStyle:
                            FontStyle.italic),

                        textAlign: TextAlign.center,

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    );
  }
}