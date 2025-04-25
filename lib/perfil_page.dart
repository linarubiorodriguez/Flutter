import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'sesion.dart';
import 'constans.dart';
import './screens/login_screen.dart';
import 'principal.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String nombres = "";
  String apellidos = "";
  String email = "";
  String telefono = "";

  int _currentImageIndex = 0;
  late Timer _timer;

  final List<String> _imagenes = [
    "../assets/imagen/perro_perfil.png",
    "../assets/imagen/gato_perfil.png",
  ];

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _imagenes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> obtenerDatosUsuario() async {
    await Sesion.cargarSesion();

    if (Sesion.id == null || Sesion.token == null) {
      print("No hay sesión activa");
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/Priv/${Sesion.id}');
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${Sesion.token}",
        "Cache-Control": "no-cache",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cliente = data["cliente"];
      setState(() {
        nombres = cliente["nombres"] ?? "";
        apellidos = cliente["apellidos"] ?? "";
        email = cliente["email"] ?? "";
        telefono = cliente["telefono"] ?? "";
      });
    } else {
      print("Error al obtener datos del usuario: ${response.statusCode}");
    }
  }

  void cerrarSesion() async {
    await Sesion.cerrar();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),

          // Flecha de volver
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Constants.naranjaOscuro),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PrincipalPage()),
                  );
                },
              ),
              const Text(
                "Volver",
                style: TextStyle(
                  color: Constants.naranjaOscuro,
                  fontSize: 16,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          // Título con ícono
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.account_circle, color: Constants.naranjaClaro, size: 30),
              SizedBox(width: 8),
              Text(
                'Perfil',
                style: TextStyle(
                  color: Constants.naranjaClaro,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tarjeta centrada
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Imagen con cambio automático
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Image.asset(
                          _imagenes[_currentImageIndex],
                          key: ValueKey<String>(_imagenes[_currentImageIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  infoRow("Nombres:", nombres),
                  infoRow("Apellidos:", apellidos),
                  infoRow("Correo:", email),
                  infoRow("Teléfono:", telefono),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: cerrarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.naranjaOscuro,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Cerrar sesión",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 5),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
