import 'package:flutter/material.dart';
import 'package:app1/screens/reportes/dashboard_preview.dart';
import 'package:app1/screens/reportes/reportes_detalles.dart';

class ReportesScreen extends StatefulWidget {
  final String token;

  const ReportesScreen({super.key, required this.token});

  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool showDetails = false;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    // Puedes agregar lógica para detectar parámetros de URL si es necesario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showDetails 
          ? ReportesDetalles(
              token: widget.token,
              currentTab: currentTab,
              onBack: () => setState(() => showDetails = false),
            )
          : DashboardPreview(
              token: widget.token,
              onViewDetails: (tab) {
                setState(() {
                  currentTab = tab;
                  showDetails = true;
                });
              },
            ),
    );
  }
}