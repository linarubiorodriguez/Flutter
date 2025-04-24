import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RolForm extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? rol;
  final VoidCallback onRolGuardado;

  const RolForm({
    Key? key,
    required this.token,
    this.rol,
    required this.onRolGuardado,
  }) : super(key: key);

  @override
  _RolFormState createState() => _RolFormState();
}

class _RolFormState extends State<RolForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.rol != null;
    
    if (_esEdicion) {
      _nombreController.text = widget.rol!['Nombre'] ?? "";
      _descripcionController.text = widget.rol!['Descripcion'] ?? "";
    }
  }

  Future<void> guardarRol() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> datos = {
      "Nombre": _nombreController.text,
      "Descripcion": _descripcionController.text,
    };

    String url = "http://localhost:5000/rol";
    var method = _esEdicion ? http.put : http.post;

    if (_esEdicion) {
      url = "$url/${widget.rol!['id_Rol']}";
    }

    try {
      final response = await method(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(datos),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onRolGuardado();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_esEdicion ? "Rol actualizado" : "Rol creado"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2EE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _esEdicion ? "Editar Rol" : "Agregar Rol",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8357),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nombreController, "Nombre", Icons.badge),
                    _buildTextField(_descripcionController, "Descripción", Icons.description),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF8357),
                          ),
                          child: const Text("Cancelar"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: guardarRol,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8357),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          ),
                          child: const Text("Guardar"),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFAC172)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFAC172)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFAC172)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF8357), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => label == "Nombre" && value!.isEmpty ? "Campo requerido" : null,
      ),
    );
  }
}

class AdminRoles extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const AdminRoles({Key? key, required this.token, required this.isAdmin}) : super(key: key);

  @override
  _AdminRolesState createState() => _AdminRolesState();
}

class _AdminRolesState extends State<AdminRoles> {
  List<Map<String, dynamic>> roles = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _loadData();
    }
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        roles = (data['roles'] as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar roles');
    }
  }

  void mostrarFormulario({Map<String, dynamic>? rol}) {
    showDialog(
      context: context,
      builder: (context) => RolForm(
        token: widget.token,
        rol: rol,
        onRolGuardado: fetchRoles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF2EE),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block, size: 50, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text("Acceso denegado",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  const SizedBox(height: 10),
                  const Text("No tienes permisos para acceder a esta sección"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8357),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Volver"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2EE),
      appBar: AppBar(
        title: const Text("Gestión de Roles",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF8357),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
                isError = false;
              });
              _loadData();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        backgroundColor: const Color(0xFFFF8357),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8357)),
              ),
            )
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(errorMessage,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8357),
                        ),
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                )
              : roles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 50, color: Color(0xFFFAC172)),
                          const SizedBox(height: 20),
                          const Text("No hay roles registrados",
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => mostrarFormulario(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8357),
                            ),
                            child: const Text("Agregar Rol"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: roles.length,
                        itemBuilder: (context, index) {
                          final rol = roles[index];
                          return _buildRolCard(rol);
                        },
                      ),
                    ),
    );
  }

  Widget _buildRolCard(Map<String, dynamic> rol) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => mostrarFormulario(rol: rol),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rol['Nombre'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8357)),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFFF8357)),
              _buildInfoRow("ID", rol['id_Rol'].toString()),
              _buildInfoRow("Descripción", rol['Descripcion'] ?? 'Sin descripción'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFAC172)),
                    onPressed: () => mostrarFormulario(rol: rol),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFFAC172))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}