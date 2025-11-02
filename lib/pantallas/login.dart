import 'package:flutter/material.dart';
// Importaciones de Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// No necesitas el main() aquí

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Lógica para iniciar sesión y redirigir por ROL
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Iniciar sesión en Firebase Authentication
      UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // 2. LEER el documento del usuario desde Firestore para obtener el ROL
        DocumentSnapshot userDoc = 
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

        if (userDoc.exists) {
          // 3. Redirigir basado en el ROL
          // Usamos 'mounted' para asegurar que el widget todavía existe
          if (!mounted) return; 
          
          String rol = (userDoc.data() as Map<String, dynamic>)['rol'];

          if (rol == 'administrador') {
            // Si es admin, va a /homeAdmin
            Navigator.pushReplacementNamed(context, '/homeAdmin');
          } else {
            // Si es 'cliente' (o cualquier otra cosa), va a /home
            Navigator.pushReplacementNamed(context, '/home');
          }
         
        } else {
          // Si el usuario existe en Auth pero no en Firestore (caso raro)
          // Lo tratamos como cliente por defecto.
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejar errores de login (usuario no encontrado, contraseña incorrecta)
      String mensajeError = 'Correo o contraseña incorrectos.';
      if (e.code == 'user-not-found') {
        mensajeError = 'No se encontró usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        mensajeError = 'Contraseña incorrecta.';
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
    final Color primaryColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          // Usamos un Form para las validaciones
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Icon(Icons.construction_rounded, size: 80, color: primaryColor),
                const SizedBox(height: 15),
                const Text(
                  "Acceso de Clientes",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ingresa tus credenciales para continuar",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // CAMPO CORREO (convertido a TextFormField)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Correo electrónico",
                    hintText: "ejemplo@dominio.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: primaryColor),
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

                // CAMPO CONTRASEÑA (convertido a TextFormField)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: primaryColor),
                    suffixIcon: Icon(Icons.visibility_off, color: Colors.grey[400]),
                  ),
                  validator: (value) {
                     if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // BOTÓN INICIAR SESIÓN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Iniciar Sesión",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- BOTÓN CORREGIDO ---
                TextButton(
                  onPressed: () {
                    // 
                    // En lugar de Navigator.pop(context), 
                    // usamos pushNamed para IR A la pantalla de registro.
                    //
                    Navigator.pushNamed(context, '/registro');
                  },
                  child: Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
                // --- FIN DE LA CORRECCIÓN ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}
