import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ¡Importante para FieldValue!
import 'package:firebase_auth/firebase_auth.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController(); // Este es 'ciudad'
  final _estadoController = TextEditingController(); // Este es 'estado'
  final _codigoPostalController = TextEditingController();

  Map<String, dynamic>? _estimadoData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _estimadoData = arguments;
      print("Datos del estimado recibidos en Ubicación: $_estimadoData");
    } else {
      print("Advertencia: No se recibieron datos de estimado en la pantalla de Ubicación.");
    }
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  void _enviarEstimadoCompleto() {
    if (_formKey.currentState!.validate()) {
      if (_estimadoData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudieron recuperar los datos del estimado anterior.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Error: No se recibieron datos del estimado anterior al intentar enviar.");
        return;
      }

      final User? usuarioActual = FirebaseAuth.instance.currentUser;

      if (usuarioActual == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo identificar al usuario. Inicia sesión de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // --- ¡CORRECCIÓN DE BUG DE UBICACIÓN! ---
      // Guardamos como 'ciudad' y 'estado' para que coincida con la pantalla de detalles
      final Map<String, dynamic> ubicacionData = {
        'direccion': _direccionController.text,
        'ciudad': _ciudadController.text, // <-- CORREGIDO
        'estado': _estadoController.text, // <-- CORREGIDO
        'codigoPostal': _codigoPostalController.text,
      };
      // --- FIN DE LA CORRECCIÓN ---

      final Map<String, dynamic> estimadoCompleto = {
        ..._estimadoData!, 
        'ubicacion': ubicacionData, 
        'estado_estimado': 'pendiente', 
        
        // --- ¡CORRECCIÓN DE BUG DE FECHA! ---
        // 'fechaCreacion': DateTime.now().toIso8601String(), // <-- MALO (es String)
        'fechaCreacion': FieldValue.serverTimestamp(), // <-- BUENO (es Timestamp)
        // --- FIN DE LA CORRECCIÓN ---

        'userId': usuarioActual.uid,
      };

      print('--- ENVIANDO ESTIMADO COMPLETO A FIREBASE ---');
      print(estimadoCompleto);

      // Descomentado para que SÍ guarde en Firebase
      FirebaseFirestore.instance.collection('estimados').add(estimadoCompleto);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Estimado enviado! Te contactaremos pronto.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación del Proyecto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Form( 
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Último paso: ¿Dónde se realizará el trabajo?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Por favor, ingresa los detalles de la ubicación del proyecto.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección (Calle y Número)',
                    hintText: 'Ej: Av. Principal #123',
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
                ),
                const SizedBox(height: 16),
                
                // --- ¡TEXTOS CORREGIDOS! ---
                TextFormField(
                  controller: _ciudadController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad', // <-- CORREGIDO
                    hintText: 'Ej: San Salvador', // <-- CORREGIDO
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _estadoController,
                  decoration: InputDecoration(
                    labelText: 'Estado / Departamento', // <-- CORREGIDO
                    hintText: 'Ej: San Salvador', // <-- CORREGIDO
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
                ),
                // --- FIN DE LA CORRECCIÓN ---
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoPostalController,
                  decoration: InputDecoration(
                    labelText: 'Código Postal',
                    hintText: 'Ej: 01000',
                    prefixIcon: const Icon(Icons.local_post_office),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
                ),
                
                const SizedBox(height: 32), 
                
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _enviarEstimadoCompleto, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700]!,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Confirmar Ubicación y Enviar Estimado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}