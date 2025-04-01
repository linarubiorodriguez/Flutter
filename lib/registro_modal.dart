import 'package:flutter/material.dart';
import 'api_service.dart';
import 'custom_alert.dart';

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
    return AlertDialog(
      title: const Text('Registro de Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nombresController, decoration: const InputDecoration(labelText: 'Nombres'), validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null),
              TextFormField(controller: apellidosController, decoration: const InputDecoration(labelText: 'Apellidos'), validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null),
              TextFormField(controller: telefonoController, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
              TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
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
              TextFormField(controller: numDocumentoController, decoration: const InputDecoration(labelText: 'Número de Documento')),
              TextFormField(controller: direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
              TextFormField(controller: contrasenaController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              TextFormField(controller: confirmContrasenaController, decoration: const InputDecoration(labelText: 'Confirmar Contraseña'), obscureText: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancelar')),
        ElevatedButton(onPressed: handleSubmit, child: const Text('Registrarse')),
      ],
    );
  }
}
