import 'package:flutter/material.dart';
import 'registro_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showRegister = false;

  void toggleRegister() {
    setState(() {
      showRegister = !showRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuarios')),
      body: Center(
        child: ElevatedButton(
          onPressed: toggleRegister,
          child: const Text('Abrir Registro'),
        ),
      ),
      floatingActionButton: showRegister
          ? RegistroModal(
              handleLoginClick: toggleRegister,
              onClose: toggleRegister,
            )
          : null,
    );
  }
}
