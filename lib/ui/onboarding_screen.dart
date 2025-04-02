import 'package:flutter/material.dart';
import 'package:app1/constans.dart';
import '../registro_modal.dart';
import '../login_modal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool showRegister = false;
  bool showLogin = false;

  // Mostrar formulario de registro
  void toggleRegister() {
    setState(() {
      showRegister = !showRegister;
      showLogin = false;  // Asegúrate de cerrar el formulario de inicio de sesión
    });
  }

  // Mostrar formulario de inicio de sesión
  void toggleLogin() {
    setState(() {
      showLogin = !showLogin;
      showRegister = false;  // Asegúrate de cerrar el formulario de registro
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fondo blanco
          Positioned.fill(
            child: Container(
              color: Colors.white, // Fondo blanco
            ),
          ),

          /// Imagen con borde inferior en forma de "S"
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 2, // Ocupa la mitad de la pantalla
            child: ClipPath(
              clipper: SShapeClipper(), // Usamos el custom clipper
              child: Image.asset(
                '../../assets/imagen/gato-flutter.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Contenido debajo del fondo
          Positioned(
            top: MediaQuery.of(context).size.height / 2, // Empieza justo debajo del fondo
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Subimos aún más el texto

                  /// Texto de bienvenida
                  Text(
                    "¡Bienvenido al Escondite Animal!",
                    style: TextStyle(
                      fontSize: 38, // Reducido un poco más
                      fontWeight: FontWeight.bold,
                      color: Constants.naranjaOscuro, 
                      shadows: [
                        Shadow(
                          offset: Offset(1.8, 1.8),
                          blurRadius: 2,
                          color: Constants.naranjaClaro,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  /// Slogan
                  Text(
                    "Más que una tienda, un hogar para los amantes de los animales.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Constants.naranjaOscuro,
                      shadows: [
                        Shadow(
                          offset: Offset(1.2, 1.2),
                          blurRadius: 2,
                          color: Constants.naranjaClaro,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30), // Ajuste para dar espacio antes de los botones

                  /// Fila con los dos botones (Registro e Iniciar sesión)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los botones
                    children: [
                      /// Botón de Registro
                      SizedBox(
                        width: 150, // Ajusta el tamaño del botón
                        height: 50,
                        child: OutlinedButton(
                          onPressed: toggleRegister, // Cambiado a toggleRegister
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Constants.naranjaOscuro, width: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Regístrate",
                            style: TextStyle(color: Constants.naranjaOscuro, fontSize: 20),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20), // Espacio entre los botones

                      /// Botón de Iniciar sesión
                      SizedBox(
                        width: 150, // Ajusta el tamaño del botón
                        height: 50,
                        child: OutlinedButton(
                          onPressed: toggleLogin, // Cambiado a toggleLogin
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Constants.naranjaOscuro , width: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Inicia sesión",
                            style: TextStyle(color: Constants.naranjaOscuro, fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// Muestra los modales cuando corresponda
      floatingActionButton: showRegister
          ? RegistroModal(
              handleLoginClick: toggleRegister,
              onClose: toggleRegister,
            )
          : showLogin
              ? LoginModal(onClose: toggleLogin)
              : null,
    );
  }
}

class SShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(size.width * 0.75, size.height - 40, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
