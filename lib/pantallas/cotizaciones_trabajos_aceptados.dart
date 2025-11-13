import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homeAdmin.dart';
import 'detalles_cotizacion_aceptada.dart'; // Reutiliza la pantalla de detalles

class CotizacionesTrabajosAceptadosScreen extends StatefulWidget {
  const CotizacionesTrabajosAceptadosScreen({super.key});

  @override
  State<CotizacionesTrabajosAceptadosScreen> createState() =>
      _CotizacionesTrabajosAceptadosScreenState();
}

class _CotizacionesTrabajosAceptadosScreenState
    extends State<CotizacionesTrabajosAceptadosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- TÍTULO ACTUALIZADO ---
        title: const Text(
          'Trabajos Aceptados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700], // Mismo estilo
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // --- CONSULTA ACTUALIZADA ---
        stream: _firestore
            .collection('estimados')
            .where('estado_estimado', isEqualTo: 'trabajo_aceptado') // <-- Filtro cambiado
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        // --- FIN DE LA ACTUALIZACIÓN ---
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // --- TEXTO DE "VACÍO" ACTUALIZADO ---
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay trabajos aceptados por clientes',
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
                    future: _firestore
                        .collection('usuarios') 
                        .doc(data['userId'])
                        .get(),
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
                      
                      final nombreCliente =
                          userData?['nombre'] ?? 
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
                        builder: (context) => DetallesCotizacionAceptadaScreen( // Reutiliza la de "aceptada"
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
        return const Icon(Icons.house_siding, color: Colors.blue);
      case 'Pintura Interior':
        return const Icon(Icons.format_paint, color: Colors.green);
      case 'Aplicacion Textura Techo':
        return const Icon(Icons.texture, color: Colors.orange);
      default:
        return const Icon(Icons.build, color: Colors.grey);
    }
  }
}