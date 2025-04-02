import 'package:flutter/material.dart';
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
      "tipo_doc": selectedTipoDoc,
      "num_documento": numDocumentoController.text,
      "direccion": direccionController.text,
      "contrasena": contrasenaController.text,
    };

    try {
      bool success = await ApiService.registerUser(formData);
      if (success) {
        CustomAlert.showSuccess(context, 'Registro exitoso');
        widget.onClose();
      } else {
        CustomAlert.showError(context, 'Error en el registro');
      }
    } catch (e) {
      CustomAlert.showError(context, 'Hubo un error al registrar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // Fondo blanco
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Constants.naranjaOscuro, width: 2), // Borde sólido
          boxShadow: [
            BoxShadow(
              color: Constants.naranjaClaro.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ], // Efecto difuminado
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Registro de Usuario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: nombresController,
                  decoration: const InputDecoration(labelText: 'Nombres'),
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                ),
                TextFormField(
                  controller: apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                ),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),

                DropdownButtonFormField<String>(
                  value: selectedTipoDoc,
                  decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                  items: tipoDocs.map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo['id_TipoDocumento'].toString(),
                      child: Text("${tipo['Nombre']} - ${tipo['Descripcion']}"),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedTipoDoc = value),
                ),
                TextFormField(
                  controller: numDocumentoController,
                  decoration: const InputDecoration(labelText: 'Número de Documento'),
                ),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                TextFormField(
                  controller: contrasenaController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                TextFormField(
                  controller: confirmContrasenaController,
                  decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onClose,
                      style: TextButton.styleFrom(
                        foregroundColor: Constants.naranjaOscuro,
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.naranjaOscuro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Constants.naranjaClaro.withOpacity(0.5), // Difuminado con naranja claro
                        elevation: 5,
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
