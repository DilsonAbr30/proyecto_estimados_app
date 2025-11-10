import 'package:flutter/material.dart';

// --- IMPORTACIONES DE FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // <--- 1. ELIMINAMOS ESTA LÍNEA

// --- TUS PANTALLAS ---
import 'pantallas/registro.dart';
import 'pantallas/login.dart';
import 'pantallas/detalles.dart';
import 'pantallas/ubicacion.dart';
import 'pantallas/admin.dart';
import 'pantallas/servicios.dart';
import 'pantallas/cotizacion.dart';
import 'pantallas/home.dart';
import 'pantallas/homeAdmin.dart';
import 'pantallas/PinturaExteriorForm.dart';
import 'pantallas/PinturaInterior.dart';
import 'pantallas/TexturaTecho.dart';
import 'pantallas/cotizaciones_pendientes.dart';
import 'pantallas/detalles_cotizacion_pendiente.dart';
import 'pantallas/cotizaciones_aceptadas.dart';
// --- ¡IMPORTACIÓN AÑADIDA! ---
import 'pantallas/detalles_cotizacion_aceptada.dart';


// --- FUNCIÓN MAIN MODIFICADA ---
void main() async {
  // 1. Convertir a async
  // 2. Asegurar que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializar Firebase (sin opciones)
  //    De esta forma, buscará automáticamente el google-services.json
  await Firebase.initializeApp(); // <--- 2. ESTA ES LA LÍNEA MODIFICADA

  // 4. Correr la app
  runApp(const MyApp());
}
// --- FIN DE LA MODIFICACIÓN ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Pintura',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 5. Cambiar la ruta inicial a /login
      //    Así, la app siempre pedirá autenticación primero.
      //    Si quieres que inicie en registro, puedes poner '/registro'
      initialRoute: '/login',

      routes: {
        '/registro': (context) => const RegistroScreen(),
        '/login': (context) => const LoginScreen(),
        '/detalles': (context) => const DetallesScreen(location: ''),
        '/ubicacion': (context) => const LocationSelectionScreen(),
        '/admin': (context) => const PanelAdministracion(),
        '/servicios': (context) => const ServiceSelectionScreen(),
        '/cotizacion': (context) => const CotizacionScreen(),
        '/home': (context) => const HomeClienteScreen(),
        '/homeAdmin': (context) => const HomeAdminScreen(),
        '/PinturaExteriorForm': (context) => const PinturaExteriorForm(),
        '/PinturaInterior': (context) => const PinturaInteriorScreen(),
        '/TexturaTecho': (context) => const TexturaTechoForm(),
        
        // --- RUTAS DEL ADMIN AÑADIDAS/ACTUALIZADAS ---
        '/cotizaciones_pendientes': (context) =>
            const CotizacionesPendientesScreen(),
        
        // Esta ruta es para los detalles de las PENDIENTES
        '/detalles_cotizacion_pendiente': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DetallesCotizacionPendienteScreen(
            cotizacionId: args['cotizacionId'],
            cotizacionData: args['cotizacionData'],
          );
        },
        
        // --- ¡NUEVAS RUTAS AÑADIDAS! ---
        '/cotizaciones_aceptadas': (context) =>
            const CotizacionesAceptadasScreen(),

        // Esta ruta es para los detalles de las ACEPTADAS
        '/detalles_cotizacion_aceptada': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DetallesCotizacionAceptadaScreen(
            cotizacionId: args['cotizacionId'],
            cotizacionData: args['cotizacionData'],
          );
        },
        // --- FIN DE LA ADICIÓN ---
      },
    );
  }
}