import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminRoles extends StatefulWidget {
  final String token;

  const AdminRoles({super.key, required this.token});

  @override
  _AdminRolesState createState() => _AdminRolesState();
}

class _AdminRolesState extends State<AdminRoles> {
  List<dynamic> roles = [];
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
      await fetchRoles();
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchRoles() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/rol'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      setState(() {
        roles = jsonDecode(response.body)['roles'] ?? [];
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar roles');
    }
  }

  void _showEditDialog({Map<String, dynamic>? role}) {
    final isNew = role == null;
    final controller = _RoleFormController(
      id: isNew ? '' : role['id_Rol'].toString(),
      nombre: isNew ? '' : role['Nombre'],
      descripcion: isNew ? '' : role['Descripcion'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => _RoleForm(
        controller: controller,
        isNew: isNew,
        onSave: (data) async {
          try {
            final url = isNew 
              ? 'http://localhost:5000/rol'
              : 'http://localhost:5000/rol/${data['id_Rol']}';
            
            final method = isNew ? http.post : http.put;
            
            final response = await method(
              Uri.parse(url),
              headers: {
                "Authorization": "Bearer ${widget.token}",
                "Content-Type": "application/json"
              },
              body: jsonEncode({
                "Nombre": data['Nombre'],
                "Descripcion": data['Descripcion'],
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isNew ? 'Rol creado' : 'Rol actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
              await fetchRoles();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
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
              : roles.isEmpty
                  ? const Center(child: Text('No hay roles registrados'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: roles.map((role) {
                          return DataRow(cells: [
                            DataCell(Text(role['id_Rol'].toString())),
                            DataCell(Text(role['Nombre'])),
                            DataCell(Text(role['Descripcion'] ?? 'Sin descripción')),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(role: role),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
    );
  }
}

class _RoleFormController {
  String id;
  String nombre;
  String descripcion;

  _RoleFormController({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_Rol': id,
      'Nombre': nombre,
      'Descripcion': descripcion,
    };
  }
}

class _RoleForm extends StatefulWidget {
  final _RoleFormController controller;
  final bool isNew;
  final Function(Map<String, dynamic>) onSave;

  const _RoleForm({
    required this.controller,
    required this.isNew,
    required this.onSave,
  });

  @override
 __RoleFormState createState() => __RoleFormState();
}

class __RoleFormState extends State<_RoleForm> {
final _formKey = GlobalKey<FormState>();

@override
Widget build(BuildContext context) {
return AlertDialog(
title: Text(widget.isNew ? 'Agregar Rol' : 'Editar Rol'),
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
initialValue: widget.controller.descripcion,
decoration: const InputDecoration(labelText: 'Descripción'),
onChanged: (value) => widget.controller.descripcion = value,
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