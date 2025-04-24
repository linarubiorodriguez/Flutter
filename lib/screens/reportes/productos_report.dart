import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class ProductosReport extends StatefulWidget {
  final String token;

  const ProductosReport({super.key, required this.token});

  @override
  _ProductosReportState createState() => _ProductosReportState();
}

class _ProductosReportState extends State<ProductosReport> {
  Map<String, dynamic> data = {
    'top_productos': [],
    'stock_bajo': []
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
        Uri.parse('http://localhost:5000/api/reportes/productos'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      
      setState(() {
        data = jsonDecode(response.body);
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
          _buildTopProductsChart(),
          const SizedBox(height: 20),
          _buildLowStockTable(),
        ],
      ),
    );
  }

  Widget _buildTopProductsChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos Más Vendidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: data['top_productos'].isEmpty
                  ? const Center(child: Text('No hay datos de productos vendidos'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '\$${(rod.toY).toStringAsFixed(2)}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < data['top_productos'].length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      data['top_productos'][index]['nombre'],
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 100,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toStringAsFixed(0));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: data['top_productos'].asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: product['ingresos']?.toDouble() ?? 0,
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos con Stock Bajo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            data['stock_bajo'].isEmpty
                ? const Center(child: Text('No hay productos con stock bajo'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Producto')),
                        DataColumn(label: Text('Stock'), numeric: true),
                        DataColumn(label: Text('Precio'), numeric: true),
                        DataColumn(label: Text('Estado')),
                      ],
                      rows: data['stock_bajo'].map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product['nombre'])),
                          DataCell(Text(product['stock'].toString())),
                          DataCell(Text('\$${product['precio'].toStringAsFixed(2)}')),
                          DataCell(
                            Chip(
                              label: Text(product['stock'] < 5 ? 'Crítico' : 'Bajo'),
                              backgroundColor: product['stock'] < 5 
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: product['stock'] < 5 ? Colors.red : Colors.orange,
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}