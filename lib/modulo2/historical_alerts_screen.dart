import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoricalAlertsScreen extends StatefulWidget {
  const HistoricalAlertsScreen({super.key});

  @override
  State<HistoricalAlertsScreen> createState() => _HistoricalAlertsScreenState();
}

class _HistoricalAlertsScreenState extends State<HistoricalAlertsScreen> {
  late Future<List<AlertWithNode>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _alertsFuture = DatabaseHelper.instance.getAlertsWithNodeInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Alertas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: FutureBuilder<List<AlertWithNode>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos locales'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay alertas guardadas.'));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final item = alerts[index];
              return ListTile(
                leading: Icon(
                  Icons.warning,
                  color: item.value > 35.0 ? Colors.red : Colors.orange,
                ),
                title: Text('${item.nodeName} — ${item.sensorType.toUpperCase()}: ${item.value} °C'),
                subtitle: Text('Fecha: ${item.timestamp}'),
              );
            },
          );
        },
      ),
    );
  }
}