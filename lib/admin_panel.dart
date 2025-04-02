// admin_panel.dart
import 'package:app1/screens/client_screen.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  final String token;

  const AdminPanel({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.people, size: 30),
              label: const Text('Gestión de Clientes', style: TextStyle(fontSize: 20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminClientes(
                      token: token,
                      isAdmin: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
            ),
            const SizedBox(height: 30),
            // Puedes agregar más botones para otras funcionalidades aquí
            /*
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, size: 30),
              label: const Text('Otra Función', style: TextStyle(fontSize: 20)),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}