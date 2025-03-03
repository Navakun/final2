import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';

class RouteFormScreen extends StatefulWidget {
  const RouteFormScreen({super.key});

  @override
  State<RouteFormScreen> createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends State<RouteFormScreen> {
  final formKey = GlobalKey<FormState>();
  final routeNameController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final startPointController = TextEditingController();
  final endPointController = TextEditingController();
  final departureTimeController = TextEditingController();
  final estimatedArrivalTimeController = TextEditingController();
  final fareController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('เพิ่มข้อมูลเส้นทาง'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อเส้นทาง'),
                controller: routeNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนชื่อเส้นทาง";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'หมายเลขยานพาหนะ'),
                controller: vehicleNumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนหมายเลขยานพาหนะ";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'จุดเริ่มต้น'),
                controller: startPointController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนจุดเริ่มต้น";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'จุดสิ้นสุด'),
                controller: endPointController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนจุดสิ้นสุด";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'เวลาออกเดินทาง (เช่น 08:00)'),
                controller: departureTimeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนเวลาออกเดินทาง";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'เวลาคาดว่าจะถึง (เช่น 08:30)'),
                controller: estimatedArrivalTimeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนเวลาคาดว่าจะถึง";
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ราคาตั๋ว (บาท)'),
                keyboardType: TextInputType.number,
                controller: fareController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนราคาตั๋ว";
                  }
                  try {
                    double fare = double.parse(value);
                    if (fare <= 0) {
                      return "ราคาตั๋วต้องมากกว่า 0";
                    }
                  } catch (e) {
                    return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var provider = Provider.of<SmartTransportProvider>(context, listen: false);

                    SmartRoute newRoute = SmartRoute(
                      id: 0,
                      routeName: routeNameController.text,
                      vehicleNumber: vehicleNumberController.text,
                      startPoint: startPointController.text,
                      endPoint: endPointController.text,
                      departureTime: departureTimeController.text,
                      estimatedArrivalTime: estimatedArrivalTimeController.text,
                      fare: double.parse(fareController.text),
                    );

                    provider.addRoute(newRoute);
                    Navigator.pop(context);
                  }
                },
                child: const Text('เพิ่มข้อมูล'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    routeNameController.dispose();
    vehicleNumberController.dispose();
    startPointController.dispose();
    endPointController.dispose();
    departureTimeController.dispose();
    estimatedArrivalTimeController.dispose();
    fareController.dispose();
    super.dispose();
  }
}