import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProveedores extends StatefulWidget {
  final String token;

  const AdminProveedores({super.key, required this.token});

  @override
  _AdminProveedoresState createState() => _AdminProveedoresState();
}

class _AdminProveedoresState extends State<AdminProveedores> {
  List<dynamic> proveedores = [];
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
      await fetchProveedores();
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchProveedores() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/adminProveedor'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        proveedores = jsonDecode(response.body)['proveedores'];
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar proveedores');
    }
  }

  void _showEditDialog({Map<String, dynamic>? proveedor}) {
    final isNew = proveedor == null;
    final controller = _ProveedorFormController(
      id: isNew ? '' : proveedor['id_proveedor'].toString(),
      nombre: isNew ? '' : proveedor['nombre'],
      telefono: isNew ? '' : proveedor['telefono'],
      correo: isNew ? '' : proveedor['correo'],
      estado: isNew ? 'activo' : proveedor['estado'],
    );

    showDialog(
      context: context,
      builder: (context) => _ProveedorForm(
        controller: controller,
        isNew: isNew,
        onSave: (data) async {
          try {
            final url = isNew 
              ? 'http://localhost:5000/adminProveedor'
              : 'http://localhost:5000/adminProveedor/${data['id_proveedor']}';
            
            final method = isNew ? http.post : http.put;
            
            final response = await method(
              Uri.parse(url),
              headers: {
                "Authorization": "Bearer ${widget.token}",
                "Content-Type": "application/json"
              },
              body: jsonEncode({
                "nombre": data['nombre'],
                "telefono": data['telefono'],
                "correo": data['correo'],
                "estado": data['estado'],
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isNew ? 'Proveedor creado' : 'Proveedor actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
              await fetchProveedores();
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
    final nuevoEstado = estadoActual == 'activo' ? 'inactivo' : 'activo';
    
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/adminProveedor/$id'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"estado": nuevoEstado}),
      );

      if (response.statusCode == 200) {
        setState(() {
          proveedores = proveedores.map((p) {
            if (p['id_proveedor'] == id) {
              return {...p, 'estado': nuevoEstado};
            }
            return p;
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
        title: const Text('Gestión de Proveedores'),
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
              : proveedores.isEmpty
                  ? const Center(child: Text('No hay proveedores registrados'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Teléfono')),
                          DataColumn(label: Text('Correo')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: proveedores.map((proveedor) {
                          return DataRow(cells: [
                            DataCell(Text(proveedor['id_proveedor'].toString())),
                            DataCell(Text(proveedor['nombre'])),
                            DataCell(Text(proveedor['telefono'] ?? '')),
                            DataCell(Text(proveedor['correo'])),
                            DataCell(
                              Chip(
                                label: Text(proveedor['estado'],
                                    style: const TextStyle(color: Colors.white)),
                                backgroundColor: proveedor['estado'] == 'activo'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(proveedor: proveedor),
                                ),
                                IconButton(
                                  icon: Icon(
                                    proveedor['estado'] == 'activo'
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    color: proveedor['estado'] == 'activo'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  onPressed: () => toggleEstado(
                                    proveedor['id_proveedor'],
                                    proveedor['estado'],
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

class _ProveedorFormController {
  String id;
  String nombre;
  String telefono;
  String correo;
  String estado;

  _ProveedorFormController({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_proveedor': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'estado': estado,
    };
  }
}

class _ProveedorForm extends StatefulWidget {
  final _ProveedorFormController controller;
  final bool isNew;
  final Function(Map<String, dynamic>) onSave;

  const _ProveedorForm({
    required this.controller,
    required this.isNew,
    required this.onSave,
  });

  @override
  __ProveedorFormState createState() => __ProveedorFormState();
}

class __ProveedorFormState extends State<_ProveedorForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Agregar Proveedor' : 'Editar Proveedor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.controller.nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                onChanged: (value) => widget.controller.nombre = value,
              ),
              TextFormField(
                initialValue: widget.controller.telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) => widget.controller.telefono = value,
              ),
              TextFormField(
                initialValue: widget.controller.correo,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
                onChanged: (value) => widget.controller.correo = value,
              ),
              DropdownButtonFormField<String>(
                value: widget.controller.estado,
                items: ['activo', 'inactivo'].map((estado) {
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