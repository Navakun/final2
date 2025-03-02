import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';

class TicketManagementScreen extends StatelessWidget {
  const TicketManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('จัดการตั๋ว'),
      ),
      body: Consumer<SmartTransportProvider>(
        builder: (context, provider, child) {
          if (provider.tickets.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีตั๋ว',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = provider.tickets[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(ticket.routeName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ค่าโดยสาร: ${ticket.fare} บาท'),
                      Text('วันที่ซื้อ: ${ticket.purchaseDate.toString().substring(0, 16)}'),
                      Text('สถานะ: ${ticket.status}'),
                    ],
                  ),
                  leading: const Icon(Icons.confirmation_num),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPurchaseDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'ซื้อตั๋ว',
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SmartTransportProvider>(context, listen: false);
        SmartRoute? selectedRoute;
        final fareController = TextEditingController();

        return AlertDialog(
          title: const Text('ซื้อตั๋ว'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SmartRoute>(
                decoration: const InputDecoration(labelText: 'เลือกเส้นทาง'),
                items: provider.routes.map((route) {
                  return DropdownMenuItem<SmartRoute>(
                    value: route,
                    child: Text(route.routeName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRoute = value;
                },
                validator: (value) => value == null ? 'กรุณาเลือกเส้นทาง' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ค่าโดยสาร (บาท)'),
                keyboardType: TextInputType.number,
                controller: fareController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาป้อนค่าโดยสาร';
                  }
                  try {
                    double fare = double.parse(value);
                    if (fare <= 0) return 'ค่าโดยสารต้องมากกว่า 0';
                  } catch (e) {
                    return 'กรุณาป้อนตัวเลขเท่านั้น';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                if (selectedRoute != null && fareController.text.isNotEmpty) {
                  provider.purchaseTicket(selectedRoute!, double.parse(fareController.text));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ซื้อตั๋วสำเร็จ')),
                  );
                }
              },
              child: const Text('ซื้อ'),
            ),
          ],
        );
      },
    );
  }
}