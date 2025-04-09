import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../admin_panel.dart';
import '../constans.dart';

class LoginModal extends StatefulWidget {
  final VoidCallback onClose;
  
  const LoginModal({super.key, required this.onClose});

  @override
  _LoginModalState createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Credenciales de administrador
  static const String _adminEmail = "paola01@gmail.com";
  static const String _adminPassword = "El1234Escondite5656Animal42224235";

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    final String url = "http://127.0.0.1:5000/login";
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Validación básica de campos
    if (email.isEmpty || password.isEmpty) {
      showErrorToast("Por favor complete todos los campos");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "contrasena": password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token_de_acceso'];
        final int userId = data['usuario'];

        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("id", userId);
        await prefs.setBool("isLogged", true);

        showSuccessToast("Inicio de sesión exitoso");

        // Verificar si es admin (comparando tanto email como contraseña)
        bool isAdmin = email == _adminEmail && password == _adminPassword;

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPanel(token: token),
            ),
          );
        } else {
          // Cerrar el modal después de login exitoso para usuarios normales
          widget.onClose();
        }
      } else {
        showErrorToast("Email o contraseña incorrectos");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorToast("Error de conexión: ${e.toString()}");
    }
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Constants.naranjaOscuro,
                  Constants.naranjaClaro,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(4), // Grosor del borde
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Reducido para que coincida con el borde
              ),
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Constants.naranjaOscuro,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Constants.naranjaOscuro),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Constants.naranjaOscuro),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Constants.naranjaOscuro),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock, color: Constants.naranjaOscuro),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Constants.naranjaOscuro),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.naranjaOscuro,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        // Aquí podrías agregar funcionalidad para recuperar contraseña
                      },
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(color: Constants.naranjaOscuro),
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