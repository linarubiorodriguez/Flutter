import 'package:flutter/material.dart';
import 'package:app1/constans.dart';
import '../screens/registro_page.dart';
import '../screens/login_screen.dart'; // si también vas a redirigir el login

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  void toggleRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroPage()),
    );
  }

  void toggleLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              '../../assets/imagen/fondo.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                '¡Bienvenido al\nEscondite Animal!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Más que una tienda, un hogar para los amantes de los animales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: toggleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.naranjaClaro,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: const Text('Regístrate', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: toggleLogin,
                      child: const Text.rich(
                        TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: 'Inicia sesión aquí',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
