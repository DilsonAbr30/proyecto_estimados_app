import 'package:flutter/material.dart';
// Importaciones de Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// No necesitas el main() aquí si lo llamas desde tu main.dart principal

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Lógica para registrar el usuario en Firebase
  Future<void> _registrarUsuario() async {
    // Validar que el formulario esté correcto
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Crear el usuario en Firebase Authentication
      UserCredential userCredential = 
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
      );

      // Si la creación fue exitosa, userCredential.user no será nulo
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // 2. Guardar los datos adicionales en Cloud Firestore
        //    Aquí es donde asignamos el ROL
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'uid': uid,
          'nombre': _nombreController.text.trim(),
          'telefono': _telefonoController.text.trim(),
          'email': _emailController.text.trim(),
          'rol': 'cliente', // <-- ROL ASIGNADO POR DEFECTO
          'fechaRegistro': FieldValue.serverTimestamp(),
        });

        // 3. Mostrar éxito y navegar a Login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro exitoso! Por favor, inicia sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          // Usamos pushReplacementNamed para que no pueda "regresar" a registro
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejar errores de Firebase Auth (contraseña débil, email en uso, etc.)
      String mensajeError = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'weak-password') {
        mensajeError = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        mensajeError = 'Este correo electrónico ya está en uso.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Manejar cualquier otro error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          // Usamos un Form para las validaciones
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.format_paint,
                  size: 80,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // CAMPOS DE TEXTO (convertidos a TextFormField para validación)
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: "Nombre completo",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => (value == null || value.isEmpty) 
                      ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Teléfono",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) => (value == null || value.isEmpty) 
                      ? 'Ingresa tu teléfono' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Ocultar contraseña
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                     if (value == null || value.isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'Debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // BOTÓN CONTINUAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Deshabilitar si está cargando, o llamar a la función
                    onPressed: _isLoading ? null : _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Continuar",
                          style: TextStyle(fontSize: 18),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // OPCIÓN DE LOGIN YA EXISTENTE
                TextButton(
                  onPressed: () {
                    // Navegar a Login (asumiendo que la ruta '/login' existe en main.dart)
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("¿Ya tienes cuenta? Inicia sesión"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
