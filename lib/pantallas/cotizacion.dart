import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

// Clase principal de la app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotización Demo',
      theme: ThemeData(
        brightness: Brightness.light, // Modo claro
        primarySwatch: Colors.blue,
      ),
      home: const CotizacionScreen(
        precioEstimado: '\$250.00', // Dólares
        tiempoEstimado: '3 días',
      ),
    );
  }
}

// Pantalla de cotización
class CotizacionScreen extends StatelessWidget {
  final String precioEstimado;
  final String tiempoEstimado;

  const CotizacionScreen({
    Key? key,
    this.precioEstimado = '',
    this.tiempoEstimado = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController priceController =
        TextEditingController(text: precioEstimado);
    final TextEditingController timeController =
        TextEditingController(text: tiempoEstimado);

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: const Text(
          'COTIZACIÓN ESTIMADA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Tarjeta Precio
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.moneyBillWave,
                      color: Colors.blue, size: 40),
                  const SizedBox(height: 15),
                  const Text(
                    "Precio Estimado",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Tarjeta Tiempo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.clock,
                      color: Colors.green, size: 40),
                  const SizedBox(height: 15),
                  const Text(
                    "Tiempo Estimado",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: timeController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Botón principal - Solicitar Visita Técnica
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.engineering, color: Colors.black87),
              label: const Text(
                'Solicitar Visita Técnica',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Letras negras
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blue[200], // Fondo azul claro
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 15),
            // Botón secundario - Confirmar y Guardar (ahora igual que Solicitar Visita Técnica)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, color: Colors.black87),
              label: const Text(
                'Confirmar y Guardar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Letras negras
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blue[200], // Fondo azul claro
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

