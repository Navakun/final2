import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';
import 'package:smart_transport/screens/route_form_screen.dart';
import 'package:smart_transport/screens/route_edit_screen.dart';
import 'package:smart_transport/screens/ticket_management_screen.dart';
import 'package:smart_transport/screens/user_profile_screen.dart';
import 'package:smart_transport/model/transport_ticket.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SmartTransportProvider()),
      ],
      child: const SmartTransportApp(),
    ),
  );
}

class SmartTransportApp extends StatelessWidget {
  const SmartTransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Public Transport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TransportNavigationHost(),
        '/routeForm': (context) => const RouteFormScreen(),
        '/routeEdit': (context) => RouteEditScreen(
              route: ModalRoute.of(context)!.settings.arguments as SmartRoute,
            ),
      },
    );
  }
}

class TransportNavigationHost extends StatefulWidget {
  const TransportNavigationHost({super.key});

  @override
  State<TransportNavigationHost> createState() => _TransportNavigationHostState();
}

class _TransportNavigationHostState extends State<TransportNavigationHost> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TransportHomePage(), // หน้าเส้นทาง
    const TicketManagementScreen(), // หน้าตั๋ว
    const UserProfileScreen(), // หน้าโปรไฟล์
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<SmartTransportProvider>(context, listen: false).fetchRoutes();
    Provider.of<SmartTransportProvider>(context, listen: false).fetchTickets();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SmartTransportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _screens[_selectedIndex];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'เส้นทาง'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'ตั๋ว'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}

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
                        Text('ความหนาแน่น: ${route.crowdLevel}%'),
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
        final fareController = TextEditingController();

        return AlertDialog(
          title: Text('ซื้อตั๋วสำหรับ ${route.routeName}'),
          content: TextFormField(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                if (fareController.text.isNotEmpty) {
                  provider.purchaseTicket(route, double.parse(fareController.text));
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