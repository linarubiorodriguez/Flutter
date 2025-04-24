import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class UsuariosReport extends StatefulWidget {
  final String token;

  const UsuariosReport({super.key, required this.token});

  @override
  _UsuariosReportState createState() => _UsuariosReportState();
}

class _UsuariosReportState extends State<UsuariosReport> {
  Map<String, dynamic> data = {
    'usuarios_activos': 0,
    'nuevos_clientes': 0,
    'usuarios_por_rol': []
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/reportes/usuarios'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      final responseData = jsonDecode(response.body);
      setState(() {
        data = {
          'usuarios_activos': responseData['usuarios_activos'] ?? 0,
          'nuevos_clientes': responseData['nuevos_clientes'] ?? 0,
          'usuarios_por_rol': [
            {'name': 'Administradores', 'value': 10},
            {'name': 'Empleados', 'value': 15},
            {'name': 'Clientes', 'value': 75},
          ],
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserSummaryCards(),
          const SizedBox(height: 20),
          _buildUserCharts(),
        ],
      ),
    );
  }

  Widget _buildUserSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Usuarios Activos', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    data['usuarios_activos'].toString(),
                    style: const TextStyle(fontSize: 32, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Nuevos Clientes (30 días)', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    data['nuevos_clientes'].toString(),
                    style: const TextStyle(fontSize: 32, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCharts() {
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribución por Rol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(),
                      centerSpaceRadius: 60,
                      sectionsSpace: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actividad de Usuarios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May'];
                              if (value.toInt() >= 0 && value.toInt() < months.length) {
                                return Text(months[value.toInt()]);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt().toString());
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 120)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 150)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 180)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 200)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 220)]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = data['usuarios_por_rol']
        .fold<double>(0, (sum, item) => sum + (item['value'] as num).toDouble());
    
    return data['usuarios_por_rol'].asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item['value'] as num).toDouble();
      final percentage = (value / total * 100).round();
      
      const colors = [
        Color(0xFF0088FE),
        Color(0xFF00C49F),
        Color(0xFFFFBB28),
        Color(0xFFFF8042),
      ];
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '$percentage%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}