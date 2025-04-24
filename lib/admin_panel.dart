import 'package:flutter/material.dart';
import 'package:app1/screens/client_screen.dart';
import 'package:app1/screens/empleados_screen.dart';
import 'package:app1/screens/proveedores_screen.dart';
import 'package:app1/screens/roles_screen.dart';
import 'package:app1/screens/reportes/reportes_screen.dart';

class AdminPanel extends StatefulWidget {
  final String token;

  const AdminPanel({super.key, required this.token});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? _expandedSection;

  Map<String, List<Map<String, dynamic>>> get _sections {
    return {
      'Usuarios': [
        {
          'title': 'Clientes',
          'icon': Icons.people,
          'screen': AdminClientes(token: widget.token, isAdmin: true)
        },
        {
          'title': 'Empleados',
          'icon': Icons.badge,
          'screen': AdminEmpleados(token: widget.token, isAdmin: true)
        },
        {
          'title': 'Proveedores',
          'icon': Icons.local_shipping,
          'screen': AdminProveedores(token: widget.token, isAdmin: true)
        },
        {
          'title': 'Roles',
          'icon': Icons.admin_panel_settings,
          'screen': AdminRoles(token: widget.token, isAdmin: true)
        },
      ],
      'Productos': [
        {'title': 'Inventario', 'icon': Icons.inventory},
        {'title': 'Categorías', 'icon': Icons.category},
        {'title': 'Marcas', 'icon': Icons.branding_watermark},
      ],
      'Animales': [
        {'title': 'Animales', 'icon': Icons.pets},
      ],
      'Ventas': [
        {'title': 'Descuentos', 'icon': Icons.discount},
      ],
      'Facturas': [
        {'title': 'Facturas', 'icon': Icons.receipt},
      ],
      'Reportes': [
        {
          'title': 'Ver Reportes',
          'icon': Icons.analytics,
          'screen': ReportesScreen(token: widget.token)
        },
      ],
    };
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Panel de Administración',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFF8357),
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF2EE), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: _sections.keys.map((section) {
            return _buildSectionCard(section);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String section) {
    final bool isExpanded = _expandedSection == section;
    final items = _sections[section]!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _getSectionIcon(section),
            title: Text(section,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8357))),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFFAC172),
            ),
            onTap: () => _toggleSection(section),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: items.map((item) {
                  return _buildSubItem(item);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        leading: Icon(item['icon'], color: const Color(0xFFFAC172)),
        title: Text(item['title'],
            style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFFAC172)),
        onTap: () {
          if (item['screen'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => item['screen'],
              ),
            );
          }
        },
      ),
    );
  }

  Icon _getSectionIcon(String section) {
    switch (section) {
      case 'Usuarios':
        return const Icon(Icons.people_alt, color: Color(0xFFFAC172));
      case 'Productos':
        return const Icon(Icons.shopping_bag, color: Color(0xFFFAC172));
      case 'Animales':
        return const Icon(Icons.pets, color: Color(0xFFFAC172));
      case 'Ventas':
        return const Icon(Icons.point_of_sale, color: Color(0xFFFAC172));
      case 'Facturas':
        return const Icon(Icons.receipt_long, color: Color(0xFFFAC172));
      case 'Reportes':
        return const Icon(Icons.analytics, color: Color(0xFFFAC172));
      default:
        return const Icon(Icons.category, color: Color(0xFFFAC172));
    }
  }
}