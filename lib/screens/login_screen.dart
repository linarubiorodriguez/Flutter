import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../admin_panel.dart';
import '../constans.dart';
import '../principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isHovering = false;

  Future<void> login() async {
    setState(() => _isLoading = true);

    final String url = "http://127.0.0.1:5000/login";
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorToast("Por favor complete todos los campos");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "contrasena": password}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token_de_acceso'];
        final String userId = data['usuario'].toString();

        // Decodificar el token para obtener el rol
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception('Token inválido');
        }
        
        final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
        final int role = payload['rol'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("id", userId);
        await prefs.setBool("isLogged", true);
        await prefs.setInt("rol", role);

        showSuccessToast("Inicio de sesión exitoso");

        // Redirección basada en el rol
        if (role == 1) { // 1 = Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminPanel(token: token)),
          );
        } else if (role == 3) { // 3 = Empleado
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PrincipalPage()),
          );
        } else { // 2 = Cliente
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PrincipalPage()),
          );
        }
      } else {
        showErrorToast("Email o contraseña incorrectos");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showErrorToast("Error de conexión: ${e.toString()}");
    }
  }

  // ... (el resto del código permanece igual)
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
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco como la imagen
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔶 Header curvo naranja claro
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Constants.naranjaOscuro,
                ),
              ),

              // 🔙 Botón "Volver"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  onTapDown: (_) => setState(() => _isHovering = true),
                  onTapUp: (_) => setState(() => _isHovering = false),
                  onTapCancel: () => setState(() => _isHovering = false),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: _isHovering ? Constants.naranjamasOscuro : Constants.naranjaClaro),
                      const SizedBox(width: 5),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: _isHovering ? Constants.naranjamasOscuro : Constants.naranjaClaro,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🟠 Título y formulario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Inicio de sesión",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Constants.naranjaClaro,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 📧 Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email, color: Constants.naranjaOscuro),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    // 🔒 Contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock, color: Constants.naranjaOscuro),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ✅ Botón iniciar sesión
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.naranjaClaro,
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                "Iniciar Sesión",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // 🔴 ¿Olvidaste tu contraseña?
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔶 Header curvo naranja
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
