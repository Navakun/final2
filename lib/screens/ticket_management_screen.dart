import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/model/transport_ticket.dart';
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
              return Dismissible(
                key: Key(ticket.id.toString()),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  provider.cancelTicket(ticket);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ยกเลิกตั๋ว ${ticket.routeName} แล้ว')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    title: Text(ticket.routeName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ค่าโดยสาร: ${ticket.fare} บาท'),
                        Text('จำนวน: ${ticket.quantity} ใบ'),
                        Text('ราคารวม: ${ticket.fare * ticket.quantity} บาท'), // เพิ่มราคารวมที่นี่
                        Text('วันที่ซื้อ: ${ticket.purchaseDate.toString().substring(0, 16)}'),
                        Text('สถานะ: ${ticket.status}'),
                      ],
                    ),
                    leading: const Icon(Icons.confirmation_num),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        _confirmCancelTicket(context, provider, ticket);
                      },
                    ),
                  ),
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
      final quantityController = TextEditingController(text: '1');

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
                fareController.text = value?.fare.toString() ?? '';
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'จำนวนตั๋ว'),
              keyboardType: TextInputType.number,
              controller: quantityController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาป้อนจำนวนตั๋ว';
                }
                try {
                  int quantity = int.parse(value);
                  if (quantity <= 0) return 'จำนวนตั๋วต้องมากกว่า 0';
                  if (quantity > 10) return 'จำนวนตั๋วต้องไม่เกิน 10'; // จำกัดสูงสุด 10
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
              if (selectedRoute != null &&
                  fareController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty) {
                provider.purchaseTicket(
                  selectedRoute!,
                  double.parse(fareController.text),
                  int.parse(quantityController.text),
                );
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

  void _confirmCancelTicket(BuildContext context, SmartTransportProvider provider, TransportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการยกเลิกตั๋ว'),
          content: Text('คุณต้องการยกเลิกตั๋วสำหรับ ${ticket.routeName} หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ไม่'),
            ),
            TextButton(
              onPressed: () {
                provider.cancelTicket(ticket);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ยกเลิกตั๋ว ${ticket.routeName} แล้ว')),
                );
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}