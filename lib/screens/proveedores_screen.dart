import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProveedorForm extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? proveedor;
  final VoidCallback onProveedorGuardado;

  const ProveedorForm({
    Key? key,
    required this.token,
    this.proveedor,
    required this.onProveedorGuardado,
  }) : super(key: key);

  @override
  _ProveedorFormState createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<ProveedorForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  String _estado = 'activo';
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.proveedor != null;
    
    if (_esEdicion) {
      _nombreController.text = widget.proveedor!['nombre'] ?? "";
      _telefonoController.text = widget.proveedor!['telefono'] ?? "";
      _correoController.text = widget.proveedor!['correo'] ?? "";
      _estado = widget.proveedor!['estado'] ?? "activo";
    }
  }

  Future<void> guardarProveedor() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> datos = {
      "nombre": _nombreController.text,
      "telefono": _telefonoController.text,
      "correo": _correoController.text,
      "estado": _estado
    };

    String url = "http://localhost:5000/adminProveedor";
    var method = _esEdicion ? http.put : http.post;

    if (_esEdicion) {
      url = "$url/${widget.proveedor!['id_proveedor']}";
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
        widget.onProveedorGuardado();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_esEdicion ? "Proveedor actualizado" : "Proveedor creado"),
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
                _esEdicion ? "Editar Proveedor" : "Agregar Proveedor",
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
                    _buildTextField(_nombreController, "Nombre", Icons.business),
                    _buildTextField(_telefonoController, "Teléfono", Icons.phone),
                    _buildTextField(_correoController, "Correo", Icons.email),
                    _buildDropdown(
                      "Estado",
                      _estado,
                      ["activo", "inactivo"].map((estado) => DropdownMenuItem<String>(
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
                          onPressed: guardarProveedor,
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
        validator: (value) => value!.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, 
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

class AdminProveedores extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const AdminProveedores({Key? key, required this.token, required this.isAdmin}) : super(key: key);

  @override
  _AdminProveedoresState createState() => _AdminProveedoresState();
}

class _AdminProveedoresState extends State<AdminProveedores> {
  List<Map<String, dynamic>> proveedores = [];
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        proveedores = (data['proveedores'] as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar proveedores');
    }
  }

  Future<void> toggleEstadoProveedor(int id, String estadoActual) async {
    String nuevoEstado = estadoActual == 'activo' ? 'inactivo' : 'activo';

    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/adminProveedor/$id'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"estado": nuevoEstado}),
      );

      if (response.statusCode == 200) {
        setState(() {
          proveedores = proveedores.map((proveedor) {
            if (proveedor['id_proveedor'] == id) {
              proveedor['estado'] = nuevoEstado;
            }
            return proveedor;
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
      await fetchProveedores();
    }
  }

  void mostrarFormulario({Map<String, dynamic>? proveedor}) {
    showDialog(
      context: context,
      builder: (context) => ProveedorForm(
        token: widget.token,
        proveedor: proveedor,
        onProveedorGuardado: fetchProveedores,
      ),
    );
  }

  void confirmarCambioEstado(int id, String estadoActual) {
    String accion = estadoActual == 'activo' ? 'desactivar' : 'activar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar acción", style: TextStyle(color: Color(0xFFFF8357))),
        content: Text("¿Estás seguro que deseas $accion este proveedor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              toggleEstadoProveedor(id, estadoActual);
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
        title: const Text("Gestión de Proveedores",
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
              : proveedores.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.business_outlined,
                              size: 50, color: Color(0xFFFAC172)),
                          const SizedBox(height: 20),
                          const Text("No hay proveedores registrados",
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => mostrarFormulario(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8357),
                            ),
                            child: const Text("Agregar Proveedor"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: proveedores.length,
                        itemBuilder: (context, index) {
                          final proveedor = proveedores[index];
                          return _buildProveedorCard(proveedor);
                        },
                      ),
                    ),
    );
  }

  Widget _buildProveedorCard(Map<String, dynamic> proveedor) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => mostrarFormulario(proveedor: proveedor),
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
                      proveedor['nombre'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8357)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: proveedor['estado'] == 'activo'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      proveedor['estado'],
                      style: TextStyle(
                        color: proveedor['estado'] == 'activo'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFFF8357)),
              _buildInfoRow("ID", proveedor['id_proveedor'].toString()),
              _buildInfoRow("Teléfono", proveedor['telefono'] ?? 'No especificado'),
              _buildInfoRow("Correo", proveedor['correo']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFAC172)),
                    onPressed: () => mostrarFormulario(proveedor: proveedor),
                  ),
                  IconButton(
                    icon: Icon(
                      proveedor['estado'] == 'activo'
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      color: proveedor['estado'] == 'activo'
                          ? Colors.green
                          : Colors.red,
                      size: 30,
                    ),
                    onPressed: () => confirmarCambioEstado(
                      proveedor['id_proveedor'],
                      proveedor['estado'],
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