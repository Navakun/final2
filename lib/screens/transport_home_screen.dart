import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';

class TransportHomePage extends StatelessWidget {
  const TransportHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ระบบขนส่งสาธารณะอัจฉริยะ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/routeForm');
            },
          ),
        ],
      ),
      body: Consumer<SmartTransportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.routes.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีเส้นทางขนส่งในขณะนี้',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.routes.length,
            itemBuilder: (context, index) {
              SmartRoute route = provider.routes[index];
              return Dismissible(
                key: Key(route.id.toString()),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  provider.removeRoute(route);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${route.routeName} ถูกลบแล้ว')),
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
                    title: Text(route.routeName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('จาก: ${route.startPoint} → ถึง: ${route.endPoint}'),
                        Text('ออก: ${route.departureTime} | ถึง: ${route.estimatedArrivalTime}'),
                        Text('ราคาตั๋ว: ${route.fare} บาท'),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(route.vehicleNumber),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(context, '/routeEdit', arguments: route);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.confirmation_num),
                          onPressed: () {
                            _showPurchaseDialog(context, route);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, SmartRoute route) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SmartTransportProvider>(context, listen: false);
        final fareController = TextEditingController(text: route.fare.toString());
        final quantityController = TextEditingController(text: '1'); // เพิ่มช่องจำนวนตั๋ว

        return AlertDialog(
          title: Text('ซื้อตั๋วสำหรับ ${route.routeName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                if (fareController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                  provider.purchaseTicket(
                    route,
                    double.parse(fareController.text),
                    int.parse(quantityController.text), // เพิ่ม quantity
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
}