import 'package:flutter/material.dart';
import 'package:app1/screens/reportes/productos_report.dart';
import 'package:app1/screens/reportes/usuarios_report.dart';
import 'package:app1/screens/reportes/ventas_report.dart';

class ReportesDetalles extends StatefulWidget {
  final String token;
  final int currentTab;
  final VoidCallback onBack;

  const ReportesDetalles({
    super.key,
    required this.token,
    required this.currentTab,
    required this.onBack,
  });

  @override
  _ReportesDetallesState createState() => _ReportesDetallesState();
}

class _ReportesDetallesState extends State<ReportesDetalles> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.currentTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Detallados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Ventas'),
              Tab(text: 'Productos'),
              Tab(text: 'Usuarios'),
            ],
            onTap: (index) => setState(() => _currentTab = index),
            controller: TabController(
              initialIndex: _currentTab,
              length: 3,
              vsync: ScaffoldState(),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [
                VentasReport(token: widget.token),
                ProductosReport(token: widget.token),
                UsuariosReport(token: widget.token),
              ],
            ),
          ),
        ],
      ),
    );
  }
}