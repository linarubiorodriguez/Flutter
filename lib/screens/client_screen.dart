import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClienteForm extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? cliente;
  final List<dynamic> tiposDoc;
  final VoidCallback onClienteGuardado;

  const ClienteForm({
    super.key,
    required this.token,
    this.cliente,
    required this.tiposDoc,
    required this.onClienteGuardado,
  });

  @override
  _ClienteFormState createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _numDocumentoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  String? _tipoDoc;
  String _estado = 'Activo';
  bool _mostrarContrasena = false;
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.cliente != null;
    
    if (_esEdicion) {
      _nombreController.text = widget.cliente!['nombres'] ?? "";
      _apellidoController.text = widget.cliente!['apellidos'] ?? "";
      _telefonoController.text = widget.cliente!['telefono'] ?? "";
      _emailController.text = widget.cliente!['email'] ?? "";
      _direccionController.text = widget.cliente!['direccion'] ?? "";
      _numDocumentoController.text = widget.cliente!['num_documento'] ?? "";
      _tipoDoc = widget.cliente!['tipo_doc']?.toString();
      _estado = widget.cliente!['estado'] ?? "Activo";
    }
  }

  void guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> datos = {
      "nombres": _nombreController.text,
      "apellidos": _apellidoController.text,
      "telefono": _telefonoController.text,
      "email": _emailController.text,
      "direccion": _direccionController.text,
      "tipo_doc": _tipoDoc != null ? int.parse(_tipoDoc!) : null,
      "estado": _estado
    };

    // Solo incluir número de documento si es nuevo usuario
    if (!_esEdicion) {
      datos["num_documento"] = _numDocumentoController.text;
    }

    // Solo agregar contraseña si es un nuevo usuario
    if (!_esEdicion && _contrasenaController.text.isNotEmpty) {
      datos["contrasena"] = _contrasenaController.text;
    }

    String url = "http://127.0.0.1:5000/Priv";
    var method = _esEdicion ? http.put : http.post;

    if (_esEdicion) {
      url = "$url/${widget.cliente!['id_usuario']}";
    }

    final response = await method(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json"
      },
      body: jsonEncode(datos),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      widget.onClienteGuardado();
      Navigator.pop(context);
    } else {
      print("Error al guardar cliente: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? "Editar Cliente" : "Agregar Cliente"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: "Apellidos"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección"),
              ),
              TextFormField(
                controller: _numDocumentoController,
                decoration: const InputDecoration(labelText: "Número de Documento"),
                validator: (value) => !_esEdicion && value!.isEmpty ? "Campo requerido" : null,
                readOnly: _esEdicion, // Hacer el campo de solo lectura en edición
                enabled: !_esEdicion, // Deshabilitar en edición
              ),
              if (!_esEdicion) ...[
                TextFormField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    suffixIcon: IconButton(
                      icon: Icon(_mostrarContrasena ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _mostrarContrasena = !_mostrarContrasena;
                        });
                      },
                    ),
                  ),
                  obscureText: !_mostrarContrasena,
                  validator: (value) => !_esEdicion && value!.isEmpty ? "Campo requerido" : null,
                ),
              ],
              DropdownButtonFormField<String>(
                value: _tipoDoc,
                decoration: const InputDecoration(labelText: "Tipo de Documento"),
                items: widget.tiposDoc.map<DropdownMenuItem<String>>((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo['id_TipoDocumento'].toString(),
                    child: Text(tipo['Nombre']),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _tipoDoc = value;
                  });
                },
                validator: (value) => value == null ? "Seleccione un tipo de documento" : null,
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: "Estado"),
                items: ["Activo", "Inactivo"]
                    .map((estado) => DropdownMenuItem(value: estado, child: Text(estado)))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    _estado = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: guardarCliente,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}

class AdminClientes extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const AdminClientes({super.key, required this.token, required this.isAdmin});

  @override
  _AdminClientesState createState() => _AdminClientesState();
}

class _AdminClientesState extends State<AdminClientes> {
  List<dynamic> clientes = [];
  List<dynamic> tiposDoc = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      fetchTiposDocumento().then((_) => fetchClientes());
    }
  }

  Future<void> fetchTiposDocumento() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/tipo_doc'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );
    if (response.statusCode == 200) {
      setState(() {
        tiposDoc = jsonDecode(response.body)['tipo_docs'];
      });
    }
  }

  Future<void> fetchClientes() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/Priv'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        clientes = jsonDecode(response.body)['clientes'];
        isLoading = false;
      });
    }
  }

  Future<void> toggleEstadoCliente(int id, String estadoActual) async {
    String nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';

    final response = await http.patch(
      Uri.parse('http://127.0.0.1:5000/Priv/$id'),
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"estado": nuevoEstado}),
    );

    if (response.statusCode == 200) {
      setState(() {
        clientes = clientes.map((cliente) {
          if (cliente['id_usuario'] == id) {
            cliente['estado'] = nuevoEstado;
          }
          return cliente;
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado cambiado a $nuevoEstado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cambiar estado: ${response.body}")),
      );
    }
  }

  void mostrarFormulario({Map<String, dynamic>? cliente}) {
    showDialog(
      context: context,
      builder: (context) => ClienteForm(
        token: widget.token,
        cliente: cliente,
        tiposDoc: tiposDoc,
        onClienteGuardado: fetchClientes,
      ),
    );
  }

  void confirmarCambioEstado(int id, String estadoActual) {
    String accion = estadoActual == 'Activo' ? 'desactivar' : 'activar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar acción"),
        content: Text("¿Estás seguro que deseas $accion este cliente?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              toggleEstadoCliente(id, estadoActual);
            },
            child: Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) {
      return Scaffold(
        body: Center(
          child: Text("Acceso denegado"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Clientes")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
              ? Center(child: Text("No hay clientes registrados"))
              : ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${cliente['nombres']} ${cliente['apellidos']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => mostrarFormulario(cliente: cliente),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        cliente['estado'] == 'Activo' 
                                            ? Icons.toggle_off 
                                            : Icons.toggle_on,
                                        color: cliente['estado'] == 'Activo' 
                                            ? Colors.red 
                                            : Colors.green,
                                        size: 30,
                                      ),
                                      onPressed: () => confirmarCambioEstado(
                                        cliente['id_usuario'], 
                                        cliente['estado'],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text("ID: ${cliente['id_usuario']}"),
                            Text("Email: ${cliente['email']}"),
                            Text("Teléfono: ${cliente['telefono'] ?? 'No especificado'}"),
                            Text("Dirección: ${cliente['direccion'] ?? 'No especificada'}"),
                            Text("Tipo Documento: ${_getTipoDocName(cliente['tipo_doc'])}"),
                            Text("N° Documento: ${cliente['num_documento']}"),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text("Estado: "),
                                Chip(
                                  label: Text(
                                    cliente['estado'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: cliente['estado'] == 'Activo' 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _getTipoDocName(int? tipoDocId) {
    if (tipoDocId == null) return 'No especificado';
    final tipo = tiposDoc.firstWhere(
      (t) => t['id_TipoDocumento'] == tipoDocId,
      orElse: () => {'Nombre': 'Desconocido'},
    );
    return tipo['Nombre'];
  }
}