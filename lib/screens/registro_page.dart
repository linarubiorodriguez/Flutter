import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';
import '../custom_alert.dart';
import '../constans.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final numDocumentoController = TextEditingController();
  final direccionController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmContrasenaController = TextEditingController();

  List<dynamic> tipoDocs = [];
  String? selectedTipoDoc;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmContrasena = false;

  @override
  void initState() {
    super.initState();
    fetchTiposDocumento();
  }

  Future<void> fetchTiposDocumento() async {
    try {
      var data = await ApiService.getTiposDocumento();
      setState(() {
        tipoDocs = data;
        if (tipoDocs.isNotEmpty) {
          selectedTipoDoc = tipoDocs.first['id_TipoDocumento'].toString();
        }
      });
    } catch (_) {
      CustomAlert.showError(context, 'Error al obtener los tipos de documento');
    }
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (contrasenaController.text != confirmContrasenaController.text) {
      CustomAlert.showError(context, 'Las contraseñas no coinciden');
      return;
    }

    Map<String, dynamic> formData = {
      "nombres": nombresController.text,
      "apellidos": apellidosController.text,
      "telefono": telefonoController.text,
      "email": emailController.text,
      "tipo_doc": int.parse(selectedTipoDoc!),
      "num_documento": numDocumentoController.text,
      "direccion": direccionController.text,
      "contrasena": contrasenaController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/signin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );
      if (response.statusCode == 201) {
        CustomAlert.showSuccess(context, 'Registro exitoso');
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        CustomAlert.showError(context, errorData['mensaje'] ?? 'Error en el registro');
      }
    } catch (e) {
      CustomAlert.showError(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔶 Encabezado curvo
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFFF8357),
                ),
              ),

              // 🔙 Botón "Volver" debajo del header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context),
                  splashColor: Colors.orange.shade100,
                  highlightColor: Colors.orange.shade50,
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Color(0xFFFAC172)),
                      SizedBox(width: 5),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: Color(0xFFFAC172),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔽 Título y formulario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFAC172),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildInputField(nombresController, 'Nombres', Icons.person),
                          buildInputField(apellidosController, 'Apellidos', Icons.person_outline),
                          buildInputField(telefonoController, 'Teléfono', Icons.phone),
                          buildInputField(emailController, 'Email', Icons.email),
                          DropdownButtonFormField<String>(
                            value: selectedTipoDoc,
                            decoration: buildInputDecoration('Tipo de documento', Icons.assignment),
                            items: tipoDocs.map((tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo['id_TipoDocumento'].toString(),
                                child: Text("${tipo['Nombre']} - ${tipo['Descripcion']}"),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => selectedTipoDoc = value),
                            validator: (value) => value == null ? 'Seleccione un tipo' : null,
                          ),
                          const SizedBox(height: 15),
                          buildInputField(numDocumentoController, 'Número de documento', Icons.credit_card),
                          buildInputField(direccionController, 'Dirección', Icons.home),
                          buildPasswordField(contrasenaController, 'Contraseña', _mostrarContrasena, () {
                            setState(() => _mostrarContrasena = !_mostrarContrasena);
                          }),
                          buildPasswordField(confirmContrasenaController, 'Confirmar contraseña', _mostrarConfirmContrasena, () {
                            setState(() => _mostrarConfirmContrasena = !_mostrarConfirmContrasena);
                          }),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFAC172),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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

  Widget buildInputField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: buildInputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFFF8357)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFF8357)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label, bool mostrar, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: !mostrar,
        decoration: buildInputDecoration(label, Icons.lock).copyWith(
          suffixIcon: IconButton(
            icon: Icon(mostrar ? Icons.visibility : Icons.visibility_off, color: const Color(0xFFFF8357)),
            onPressed: toggle,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}

// 🔶 Custom clipper para el header curvo hacia abajo
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
