import 'package:flutter/material.dart';

// --- IMPORTACIONES DE FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // No se usa si se añade google-services.json manualmente

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
import 'pantallas/detalles_cotizacion_aceptada.dart';
// --- ¡IMPORTACIONES NUEVAS AÑADIDAS! ---
import 'pantallas/mis_cotizaciones.dart';
import 'pantallas/detalles_mi_cotizacion.dart';


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
      initialRoute: '/login',

      routes: {
        // Rutas de Auth y Cliente
        '/registro': (context) => const RegistroScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeClienteScreen(),
        '/servicios': (context) => const ServiceSelectionScreen(),
        '/ubicacion': (context) => const LocationSelectionScreen(), 

        // Rutas de Formularios de Estimado
        '/PinturaExteriorForm': (context) => const PinturaExteriorForm(),
        '/PinturaInterior': (context) => const PinturaInteriorScreen(),
        '/TexturaTecho': (context) => const TexturaTechoForm(),
        
        // --- ¡NUEVAS RUTAS DE CLIENTE! ---
        '/mis_cotizaciones': (context) => const MisCotizacionesScreen(),
        '/detalles_mi_cotizacion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DetallesMiCotizacionScreen(
            cotizacionId: args['cotizacionId'],
            cotizacionData: args['cotizacionData'],
          );
        },
        // --- FIN DE LA ADICIÓN ---

        // Rutas de Admin
        '/homeAdmin': (context) => const HomeAdminScreen(),
        '/cotizaciones_pendientes': (context) => const CotizacionesPendientesScreen(),
        '/cotizaciones_aceptadas': (context) => const CotizacionesAceptadasScreen(),
        
        '/detalles_cotizacion_pendiente': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DetallesCotizacionPendienteScreen(
            cotizacionId: args['cotizacionId'],
            cotizacionData: args['cotizacionData'],
          );
        },
        '/detalles_cotizacion_aceptada': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DetallesCotizacionAceptadaScreen(
            cotizacionId: args['cotizacionId'],
            cotizacionData: args['cotizacionData'],
          );
        },

        // Rutas Antiguas (revisa si aún las usas)
        // Estas rutas parecen ser reemplazadas por las nuevas,
        // pero las dejo por si las usas en otro lado.
        '/detalles': (context) => const DetallesScreen(location: ''),
        '/admin': (context) => const PanelAdministracion(),
        '/cotizacion': (context) => const CotizacionScreen(), // <-- Esta es la que reemplazamos por /mis_cotizaciones
      },
    );
  }
}