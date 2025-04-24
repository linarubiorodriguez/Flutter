import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminEmpleados extends StatefulWidget {
  final String token;

  const AdminEmpleados({super.key, required this.token});

  @override
  _AdminEmpleadosState createState() => _AdminEmpleadosState();
}

class _AdminEmpleadosState extends State<AdminEmpleados> {
  List<dynamic> empleados = [];
  List<dynamic> tiposDoc = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await fetchTiposDocumento();
      await fetchEmpleados();
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchTiposDocumento() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/tipo_doc'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );
    
    if (response.statusCode == 200) {
      setState(() {
        tiposDoc = jsonDecode(response.body)['tipo_docs'];
      });
    } else {
      throw Exception('Error al cargar tipos de documento');
    }
  }

  Future<void> fetchEmpleados() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/adminPrivEm'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        empleados = data['empleados'].map((empleado) {
          final tipoDoc = tiposDoc.firstWhere(
            (t) => t['id_TipoDocumento'] == empleado['tipo_doc'],
            orElse: () => {'Nombre': 'N/A'},
          );
          return {
            ...empleado,
            'tipo_doc_nombre': tipoDoc['Nombre'],
            'estado': empleado['estado'] ?? 'Activo'
          };
        }).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar empleados');
    }
  }

  void _showEditDialog({Map<String, dynamic>? empleado}) {
    final isNew = empleado == null;
    final controller = _EmpleadoFormController(
      id: isNew ? '' : empleado['id_usuario'].toString(),
      nombres: isNew ? '' : empleado['nombres'],
      apellidos: isNew ? '' : empleado['apellidos'],
      telefono: isNew ? '' : empleado['telefono'],
      email: isNew ? '' : empleado['email'],
      tipoDoc: isNew ? '' : empleado['tipo_doc'].toString(),
      numDocumento: isNew ? '' : empleado['num_documento'],
      direccion: isNew ? '' : empleado['direccion'],
      estado: isNew ? 'Activo' : empleado['estado'],
    );

    showDialog(
      context: context,
      builder: (context) => _EmpleadoForm(
        controller: controller,
        tiposDoc: tiposDoc,
        isNew: isNew,
        onSave: (data) async {
          try {
            final url = isNew 
              ? 'http://localhost:5000/adminPrivEm'
              : 'http://localhost:5000/adminPrivEm/${data['id_usuario']}';
            
            final method = isNew ? http.post : http.put;
            
            final response = await method(
              Uri.parse(url),
              headers: {
                "Authorization": "Bearer ${widget.token}",
                "Content-Type": "application/json"
              },
              body: jsonEncode({
                "nombres": data['nombres'],
                "apellidos": data['apellidos'],
                "telefono": data['telefono'],
                "email": data['email'],
                "tipo_doc": int.parse(data['tipo_doc']),
                "num_documento": data['num_documento'],
                "direccion": data['direccion'],
                "estado": data['estado'],
                "contrasena": isNew ? data['contrasena'] : null,
                "id_rol": 3 // Rol de empleado
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isNew ? 'Empleado creado' : 'Empleado actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
              await fetchEmpleados();
              Navigator.pop(context);
            } else {
              throw Exception(response.body);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> toggleEstado(int id, String estadoActual) async {
    final nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';
    
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/adminPrivEm/$id'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"estado": nuevoEstado}),
      );

      if (response.statusCode == 200) {
        setState(() {
          empleados = empleados.map((e) {
            if (e['id_usuario'] == id) {
              return {...e, 'estado': nuevoEstado};
            }
            return e;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a $nuevoEstado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Empleados'),
        backgroundColor: const Color(0xFFFF8357),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        backgroundColor: const Color(0xFFFF8357),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text('Error: $errorMessage'))
              : empleados.isEmpty
                  ? const Center(child: Text('No hay empleados registrados'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Apellidos')),
                          DataColumn(label: Text('Teléfono')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Tipo Doc')),
                          DataColumn(label: Text('N° Doc')),
                          DataColumn(label: Text('Dirección')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: empleados.map((empleado) {
                          return DataRow(cells: [
                            DataCell(Text(empleado['id_usuario'].toString())),
                            DataCell(Text(empleado['nombres'])),
                            DataCell(Text(empleado['apellidos'])),
                            DataCell(Text(empleado['telefono'] ?? '')),
                            DataCell(Text(empleado['email'])),
                            DataCell(Text(empleado['tipo_doc_nombre'])),
                            DataCell(Text(empleado['num_documento'])),
                            DataCell(Text(empleado['direccion'] ?? '')),
                            DataCell(
                              Chip(
                                label: Text(empleado['estado'],
                                    style: const TextStyle(color: Colors.white)),
                                backgroundColor: empleado['estado'] == 'Activo'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(empleado: empleado),
                                ),
                                IconButton(
                                  icon: Icon(
                                    empleado['estado'] == 'Activo'
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    color: empleado['estado'] == 'Activo'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  onPressed: () => toggleEstado(
                                    empleado['id_usuario'],
                                    empleado['estado'],
                                  ),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
    );
  }
}

class _EmpleadoFormController {
  String id;
  String nombres;
  String apellidos;
  String telefono;
  String email;
  String tipoDoc;
  String numDocumento;
  String direccion;
  String estado;
  String contrasena = '';

  _EmpleadoFormController({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.tipoDoc,
    required this.numDocumento,
    required this.direccion,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'tipo_doc': tipoDoc,
      'num_documento': numDocumento,
      'direccion': direccion,
      'estado': estado,
      'contrasena': contrasena,
    };
  }
}

class _EmpleadoForm extends StatefulWidget {
  final _EmpleadoFormController controller;
  final List<dynamic> tiposDoc;
  final bool isNew;
  final Function(Map<String, dynamic>) onSave;

  const _EmpleadoForm({
    required this.controller,
    required this.tiposDoc,
    required this.isNew,
    required this.onSave,
  });

  @override
  __EmpleadoFormState createState() => __EmpleadoFormState();
}

class __EmpleadoFormState extends State<_EmpleadoForm> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Agregar Empleado' : 'Editar Empleado'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.controller.nombres,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                onChanged: (value) => widget.controller.nombres = value,
              ),
              TextFormField(
                initialValue: widget.controller.apellidos,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                onChanged: (value) => widget.controller.apellidos = value,
              ),
              TextFormField(
                initialValue: widget.controller.telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) => widget.controller.telefono = value,
              ),
              TextFormField(
                initialValue: widget.controller.email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                onChanged: (value) => widget.controller.email = value,
              ),
              DropdownButtonFormField<String>(
                value: widget.controller.tipoDoc.isEmpty ? null : widget.controller.tipoDoc,
                items: widget.tiposDoc.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo['id_TipoDocumento'].toString(),
                    child: Text('${tipo['Nombre']} - ${tipo['Descripcion']}'),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Tipo Documento'),
                validator: (value) => value == null ? 'Seleccione un tipo' : null,
                onChanged: (value) => widget.controller.tipoDoc = value!,
              ),
              if (widget.isNew) ...[
                TextFormField(
                  initialValue: widget.controller.numDocumento,
                  decoration: const InputDecoration(labelText: 'Número Documento'),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  onChanged: (value) => widget.controller.numDocumento = value,
                ),
                TextFormField(
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  onChanged: (value) => widget.controller.contrasena = value,
                ),
              ],
              TextFormField(
                initialValue: widget.controller.direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
                onChanged: (value) => widget.controller.direccion = value,
              ),
              DropdownButtonFormField<String>(
                value: widget.controller.estado,
                items: ['Activo', 'Inactivo'].map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Estado'),
                onChanged: (value) => widget.controller.estado = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(widget.controller.toMap());
            }
          },
          child: Text(widget.isNew ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}