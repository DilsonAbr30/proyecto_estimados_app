import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homeAdmin.dart';
import 'detalles_cotizacion_pendiente.dart';

class CotizacionesPendientesScreen extends StatefulWidget {
  const CotizacionesPendientesScreen({super.key});

  @override
  State<CotizacionesPendientesScreen> createState() =>
      _CotizacionesPendientesScreenState();
}

class _CotizacionesPendientesScreenState
    extends State<CotizacionesPendientesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cotizaciones Pendientes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // --- NAVEGACIÓN MODIFICADA ---
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
              (route) => false, // Esto limpia el stack de navegación
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('estimados')
            .where('estado_estimado', isEqualTo: 'pendiente')
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // El error del índice aparecerá aquí primero.
            // Si ya creaste el índice, este error ya no debería salir.
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay cotizaciones pendientes',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: _buildServiceIcon(data['servicio']),
                  title: Text(
                    data['servicio'] ?? 'Servicio no especificado',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: FutureBuilder<DocumentSnapshot>(
                    // --- ¡CORRECCIÓN DE BUG! ---
                    // La colección se llama 'usuarios' (en español), no 'users'.
                    future: _firestore
                        .collection('usuarios') // <-- CORREGIDO
                        .doc(data['userId'])
                        .get(),
                    // --- FIN DE CORRECIÓN ---
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Cargando...');
                      }
                      if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Text('Cliente no encontrado');
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;
                      
                      // Usamos 'nombre' (como lo guardamos en registro.dart)
                      final nombreCliente =
                          userData?['nombre'] ?? // <-- CORREGIDO
                          userData?['email'] ??
                          'Cliente';

                      return Text('Cliente: $nombreCliente');
                    },
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallesCotizacionPendienteScreen(
                          cotizacionId: doc.id,
                          cotizacionData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceIcon(String? servicio) {
    switch (servicio) {
      case 'Pintura Exterior':
        return const Icon(Icons.house_siding, color: Colors.blue); // Icono actualizado
      case 'Pintura Interior':
        return const Icon(Icons.format_paint, color: Colors.green); // Icono actualizado
      case 'Aplicacion Textura Techo':
        return const Icon(Icons.texture, color: Colors.orange);
      default:
        return const Icon(Icons.build, color: Colors.grey);
    }
  }
}