import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';
import 'package:smart_transport/screens/route_form_screen.dart';
import 'package:smart_transport/screens/route_edit_screen.dart';
import 'package:smart_transport/screens/ticket_management_screen.dart';
import 'package:smart_transport/screens/user_profile_screen.dart';

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
    const TransportHomePage(),
    const TicketManagementScreen(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SmartTransportProvider>(context, listen: false);
      provider.fetchUsers();
      provider.fetchRoutes();
      provider.fetchTickets();
    });
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

class TransportHomePage extends StatefulWidget {
  const TransportHomePage({super.key});

  @override
  State<TransportHomePage> createState() => _TransportHomePageState();
}

class _TransportHomePageState extends State<TransportHomePage> {
  String _searchQuery = '';

  // คำแนะนำ: ถ้าต้องการค้นหาแบบเจาะจงตามจุดเริ่มต้นและจุดสิ้นสุด
  // String _startPointQuery = '';
  // String _endPointQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Consumer<SmartTransportProvider>(
          builder: (context, provider, child) {
            return Text(
              'ระบบขนส่งสาธารณะอัจฉริยะ - ${provider.currentUser?.username ?? "ไม่ระบุ"}',
            );
          },
        ),
        actions: [
          Consumer<SmartTransportProvider>(
            builder: (context, provider, child) {
              final userRole = provider.currentUser?.role ?? 'general';
              if (userRole == 'admin') {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/routeForm');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ค้นหาเส้นทาง (ชื่อ, จุดเริ่มต้น, จุดสิ้นสุด)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = ''; // ล้างคำค้นหา
                          });
                        },
                      )
                    : null, // ปุ่มล้างคำค้นหา (คำแนะนำ)
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // คำแนะนำ: ถ้าต้องการค้นหาแบบเจาะจงตามจุดเริ่มต้นและจุดสิ้นสุด
          // เพิ่ม TextField อีก 2 ช่องสำหรับ startPoint และ endPoint
          /*
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'จุดเริ่มต้น',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _startPointQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'จุดสิ้นสุด',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _endPointQuery = value.toLowerCase();
                });
              },
            ),
          ),
          */
          Expanded(
            child: Consumer<SmartTransportProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.currentUser == null) {
                  return const Center(
                    child: Text(
                      'กรุณาเลือกผู้ใช้ในหน้าโปรไฟล์',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                // กรองเส้นทางตามคำค้นหา
                final filteredRoutes = provider.routes.where((route) {
                   return route.routeName.toLowerCase().contains(_searchQuery) ||
                      route.startPoint.toLowerCase().contains(_searchQuery) ||
                      route.endPoint.toLowerCase().contains(_searchQuery);
                  // คำแนะนำ: ถ้าต้องการค้นหาแบบเจาะจงตามจุดเริ่มต้นและจุดสิ้นสุด
                  // return route.startPoint.toLowerCase().contains(_startPointQuery) &&
                  //        route.endPoint.toLowerCase().contains(_endPointQuery);
                }).toList();

                if (filteredRoutes.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีเส้นทางที่ตรงกับคำค้นหา',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredRoutes.length,
                  itemBuilder: (context, index) {
                    SmartRoute route = filteredRoutes[index];
                    return Dismissible(
                      key: Key(route.id.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: provider.currentUser?.role == 'admin'
                          ? (direction) {
                              provider.removeRoute(route);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${route.routeName} ถูกลบแล้ว')),
                              );
                            }
                          : null,
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
                              if (provider.currentUser?.role == 'admin')
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
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, SmartRoute route) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SmartTransportProvider>(context, listen: false);
        final fareController = TextEditingController(text: route.fare.toString());
        final quantityController = TextEditingController(text: '1');

        return AlertDialog(
          title: Text('ซื้อตั๋วสำหรับ ${route.routeName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ผู้ใช้: ${provider.currentUser?.username ?? "ไม่ระบุ"}'),
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
                if (provider.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาเลือกผู้ใช้ก่อนซื้อตั๋ว')),
                  );
                  Navigator.pop(context);
                  return;
                }
                if (fareController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                  provider.purchaseTicket(
                    route,
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
}