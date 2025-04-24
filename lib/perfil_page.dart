import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'sesion.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? nombres, apellidos, correo, telefono;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    final id = Sesion.idUsuario;
    final token = Sesion.token;

    if (id == null || token == null) return;

    final url = Uri.parse('http://10.0.2.2:5000/Priv/$id'); // CAMBIADO

    final respuesta = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body)['cliente'];
      setState(() {
        nombres = data['nombres'];
        apellidos = data['apellidos'];
        correo = data['email'];
        telefono = data['telefono'];
      });
    } else {
      print("Error al obtener el perfil: ${respuesta.statusCode} ${respuesta.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil", style: TextStyle(color: Colors.orange)),
        actions: const [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image, size: 100, color: Colors.orange),
              const SizedBox(height: 20),
              InfoTexto(label: "Nombres", valor: nombres),
              InfoTexto(label: "Apellidos", valor: apellidos),
              InfoTexto(label: "Correo", valor: correo),
              InfoTexto(label: "Telefono", valor: telefono),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Sesion.cerrarSesion();
                  Navigator.pushReplacementNamed(context, "/login");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shadowColor: Colors.black45,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTexto extends StatelessWidget {
  final String label;
  final String? valor;

  const InfoTexto({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(valor ?? "-", style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
