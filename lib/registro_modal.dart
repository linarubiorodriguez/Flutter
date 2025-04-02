import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'custom_alert.dart';
import 'package:app1/constans.dart';

class RegistroModal extends StatefulWidget {
  final VoidCallback handleLoginClick;
  final VoidCallback onClose;

  const RegistroModal({
    Key? key,
    required this.handleLoginClick,
    required this.onClose,
  }) : super(key: key);

  @override
  _RegistroModalState createState() => _RegistroModalState();
}

class _RegistroModalState extends State<RegistroModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numDocumentoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmContrasenaController = TextEditingController();

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
    } catch (e) {
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
    "tipo_doc": int.parse(selectedTipoDoc!), // Asegurar que es int
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
      widget.onClose();
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
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
                        "Registro de Usuario",
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nombresController,
                          decoration: InputDecoration(
                            labelText: 'Nombres',
                            prefixIcon: Icon(Icons.person, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: apellidosController,
                          decoration: InputDecoration(
                            labelText: 'Apellidos',
                            prefixIcon: Icon(Icons.person_outline, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: telefonoController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
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
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: selectedTipoDoc,
                          decoration: InputDecoration(
                            labelText: 'Tipo de Documento',
                            prefixIcon: Icon(Icons.assignment, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
                        TextFormField(
                          controller: numDocumentoController,
                          decoration: InputDecoration(
                            labelText: 'Número de Documento',
                            prefixIcon: Icon(Icons.credit_card, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: direccionController,
                          decoration: InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: Icon(Icons.home, color: Constants.naranjaOscuro),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: contrasenaController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock, color: Constants.naranjaOscuro),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarContrasena ? Icons.visibility : Icons.visibility_off,
                                color: Constants.naranjaOscuro,
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarContrasena = !_mostrarContrasena;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: !_mostrarContrasena,
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: confirmContrasenaController,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            prefixIcon: Icon(Icons.lock_outline, color: Constants.naranjaOscuro),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarConfirmContrasena ? Icons.visibility : Icons.visibility_off,
                                color: Constants.naranjaOscuro,
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarConfirmContrasena = !_mostrarConfirmContrasena;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Constants.naranjaOscuro),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: !_mostrarConfirmContrasena,
                          validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.naranjaOscuro,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿Ya tienes una cuenta? ",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            TextButton(
                              onPressed: widget.handleLoginClick,
                              child: Text(
                                "Inicia sesión",
                                style: TextStyle(color: Constants.naranjaOscuro),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}