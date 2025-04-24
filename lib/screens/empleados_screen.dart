import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpleadoForm extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? empleado;
  final List<dynamic> tiposDoc;
  final VoidCallback onEmpleadoGuardado;

  const EmpleadoForm({
    Key? key,
    required this.token,
    this.empleado,
    required this.tiposDoc,
    required this.onEmpleadoGuardado,
  }) : super(key: key);

  @override
  _EmpleadoFormState createState() => _EmpleadoFormState();
}

class _EmpleadoFormState extends State<EmpleadoForm> {
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
    _esEdicion = widget.empleado != null;
    
    if (_esEdicion) {
      _nombreController.text = widget.empleado!['nombres'] ?? "";
      _apellidoController.text = widget.empleado!['apellidos'] ?? "";
      _telefonoController.text = widget.empleado!['telefono'] ?? "";
      _emailController.text = widget.empleado!['email'] ?? "";
      _direccionController.text = widget.empleado!['direccion'] ?? "";
      _numDocumentoController.text = widget.empleado!['num_documento'] ?? "";
      _tipoDoc = widget.empleado!['tipo_doc']?.toString();
      _estado = widget.empleado!['estado'] ?? "Activo";
    }
  }

  Future<void> guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> datos = {
      "nombres": _nombreController.text,
      "apellidos": _apellidoController.text,
      "telefono": _telefonoController.text,
      "email": _emailController.text,
      "direccion": _direccionController.text,
      "tipo_doc": _tipoDoc != null ? int.parse(_tipoDoc!) : null,
      "estado": _estado,
      "id_rol": 3 // Rol de empleado
    };

    if (!_esEdicion) {
      datos["num_documento"] = _numDocumentoController.text;
    }

    if ((!_esEdicion || _contrasenaController.text.isNotEmpty) && _contrasenaController.text.isNotEmpty) {
      datos["contrasena"] = _contrasenaController.text;
    } else if (!_esEdicion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La contraseña es requerida para nuevos empleados"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String url = "http://127.0.0.1:5000/adminPrivEm";
    var method = _esEdicion ? http.put : http.post;

    if (_esEdicion) {
      url = "$url/${widget.empleado!['id_usuario']}";
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
        widget.onEmpleadoGuardado();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_esEdicion ? "Empleado actualizado" : "Empleado creado"),
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
                _esEdicion ? "Editar Empleado" : "Agregar Empleado",
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
                    _buildTextField(_nombreController, "Nombre", Icons.person),
                    _buildTextField(_apellidoController, "Apellidos", Icons.person_outline),
                    _buildTextField(_telefonoController, "Teléfono", Icons.phone),
                    _buildTextField(_emailController, "Email", Icons.email),
                    _buildTextField(_direccionController, "Dirección", Icons.home),
                    _buildTextField(
                      _numDocumentoController,
                      "Número de Documento",
                      Icons.assignment_ind,
                      readOnly: _esEdicion,
                      enabled: !_esEdicion,
                    ),
                    _buildPasswordField(),
                    _buildDropdown(
                      "Tipo de Documento",
                      _tipoDoc,
                      widget.tiposDoc.map((tipo) => DropdownMenuItem<String>(
                        value: tipo['id_TipoDocumento'].toString(),
                        child: Text("${tipo['Nombre']} - ${tipo['Descripcion']}"),
                      )).toList(),
                      (value) => setState(() => _tipoDoc = value),
                    ),
                    _buildDropdown(
                      "Estado",
                      _estado,
                      ["Activo", "Inactivo"].map((estado) => DropdownMenuItem<String>(
                        value: estado,
                        child: Text(estado),
                      )).toList(),
                      (value) => setState(() => _estado = value!),
                    ),
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
                          onPressed: guardarEmpleado,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {bool readOnly = false, bool enabled = true}) {
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
        validator: (value) => value!.isEmpty ? "Campo requerido" : null,
        readOnly: readOnly,
        enabled: enabled,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: _contrasenaController,
        obscureText: !_mostrarContrasena,
        decoration: InputDecoration(
          labelText: "Contraseña",
          prefixIcon: const Icon(Icons.lock, color: Color(0xFFFAC172)),
          suffixIcon: IconButton(
            icon: Icon(
              _mostrarContrasena ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFFFAC172),
            ),
            onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
          ),
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
        validator: (value) => !_esEdicion && value!.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, 
      List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFAC172)),
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
        items: items,
        onChanged: onChanged,
        validator: (value) => value == null ? "Seleccione $label" : null,
      ),
    );
  }
}

class AdminEmpleados extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const AdminEmpleados({Key? key, required this.token, required this.isAdmin}) : super(key: key);

  @override
  _AdminEmpleadosState createState() => _AdminEmpleadosState();
}

class _AdminEmpleadosState extends State<AdminEmpleados> {
  List<Map<String, dynamic>> empleados = [];
  List<Map<String, dynamic>> tiposDoc = [];
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
      Uri.parse('http://127.0.0.1:5000/tipo_doc'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        tiposDoc = (data['tipo_docs'] as List).map<Map<String, dynamic>>((item) => 
          item as Map<String, dynamic>).toList();
      });
    } else {
      throw Exception('Error al cargar tipos de documento');
    }
  }

  Future<void> fetchEmpleados() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/adminPrivEm'),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      List<Map<String, dynamic>> empleadosData = 
        (data['empleados'] as List).cast<Map<String, dynamic>>();
      
      List<Map<String, dynamic>> empleadosConTipoDoc = empleadosData.map((empleado) {
        final tipoDoc = tiposDoc.firstWhere(
          (t) => t['id_TipoDocumento'] == empleado['tipo_doc'],
          orElse: () => {'Nombre': 'N/A', 'Descripcion': ''} as Map<String, dynamic>,
        );
        
        return {
          ...empleado,
          'tipo_doc_nombre': tipoDoc['Nombre'],
          'estado': empleado['estado'] ?? 'Activo'
        };
      }).toList();

      setState(() {
        empleados = empleadosConTipoDoc;
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar empleados');
    }
  }
  Future<void> toggleEstadoEmpleado(int id, String estadoActual) async {
    String nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';

    try {
      final response = await http.patch(
        Uri.parse('http://127.0.0.1:5000/adminPrivEm/$id'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"estado": nuevoEstado}),
      );

      if (response.statusCode == 200) {
        setState(() {
          empleados = empleados.map((empleado) {
            if (empleado['id_usuario'] == id) {
              empleado['estado'] = nuevoEstado;
            }
            return empleado;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Estado cambiado a $nuevoEstado"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      // Refrescar datos para asegurar consistencia
      await fetchEmpleados();
    }
  }

  void mostrarFormulario({Map<String, dynamic>? empleado}) {
    showDialog(
      context: context,
      builder: (context) => EmpleadoForm(
        token: widget.token,
        empleado: empleado,
        tiposDoc: tiposDoc,
        onEmpleadoGuardado: fetchEmpleados,
      ),
    );
  }

  void confirmarCambioEstado(int id, String estadoActual) {
    String accion = estadoActual == 'Activo' ? 'desactivar' : 'activar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar acción", style: TextStyle(color: Color(0xFFFF8357))),
        content: Text("¿Estás seguro que deseas $accion este empleado?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              toggleEstadoEmpleado(id, estadoActual);
            },
            child: const Text("Confirmar", style: TextStyle(color: Color(0xFFFF8357))),
          ),
        ],
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
        title: const Text("Gestión de Empleados",
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
              : empleados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 50, color: Color(0xFFFAC172)),
                          const SizedBox(height: 20),
                          const Text("No hay empleados registrados",
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => mostrarFormulario(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8357),
                            ),
                            child: const Text("Agregar Empleado"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: empleados.length,
                        itemBuilder: (context, index) {
                          final empleado = empleados[index];
                          return _buildEmpleadoCard(empleado);
                        },
                      ),
                    ),
    );
  }

Widget _buildEmpleadoCard(Map<String, dynamic> empleado) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => mostrarFormulario(empleado: empleado),
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
                      "${empleado['nombres']} ${empleado['apellidos']}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8357)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: empleado['estado'] == 'Activo'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      empleado['estado'],
                      style: TextStyle(
                        color: empleado['estado'] == 'Activo'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFFF8357)),
              _buildInfoRow("ID", empleado['id_usuario'].toString()),
              _buildInfoRow("Email", empleado['email']),
              _buildInfoRow("Teléfono", empleado['telefono'] ?? 'No especificado'),
              _buildInfoRow("Dirección", empleado['direccion'] ?? 'No especificada'),
              _buildInfoRow("Tipo Documento", empleado['tipo_doc_nombre']),
              _buildInfoRow("N° Documento", empleado['num_documento']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFAC172)),
                    onPressed: () => mostrarFormulario(empleado: empleado),
                  ),
                  IconButton(
                    icon: Icon(
                      empleado['estado'] == 'Activo'
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      color: empleado['estado'] == 'Activo'
                          ? Colors.green
                          : Colors.red,
                      size: 30,
                    ),
                    onPressed: () => confirmarCambioEstado(
                      empleado['id_usuario'],
                      empleado['estado'],
                    ),
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