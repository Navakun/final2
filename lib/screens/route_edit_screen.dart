import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';

class RouteEditScreen extends StatefulWidget {
  final SmartRoute route;

  const RouteEditScreen({super.key, required this.route});

  @override
  State<RouteEditScreen> createState() => _RouteEditScreenState();
}

class _RouteEditScreenState extends State<RouteEditScreen> {
  final formKey = GlobalKey<FormState>();
  final routeNameController = TextEditingController();
  final startPointController = TextEditingController();
  final endPointController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final departureTimeController = TextEditingController();
  final estimatedArrivalTimeController = TextEditingController();
  final crowdLevelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นจากข้อมูลที่ส่งมา
    routeNameController.text = widget.route.routeName;
    startPointController.text = widget.route.startPoint;
    endPointController.text = widget.route.endPoint;
    vehicleNumberController.text = widget.route.vehicleNumber;
    departureTimeController.text = widget.route.departureTime;
    estimatedArrivalTimeController.text = widget.route.estimatedArrivalTime;
    crowdLevelController.text = widget.route.crowdLevel.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('แก้ไขเส้นทาง'),
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
                decoration: const InputDecoration(labelText: 'เวลาออกเดินทาง (เช่น 08:00)'),
                controller: departureTimeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนเวลาออกเดินทาง";
                  }
                  return null; // อาจเพิ่มการตรวจสอบรูปแบบเวลาในอนาคต
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
                decoration: const InputDecoration(labelText: 'ระดับความหนาแน่น (%)'),
                keyboardType: TextInputType.number,
                controller: crowdLevelController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณาป้อนระดับความหนาแน่น";
                  }
                  try {
                    int crowdLevel = int.parse(value);
                    if (crowdLevel < 0 || crowdLevel > 100) {
                      return "กรุณาป้อนค่าระหว่าง 0-100";
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
                    // สร้าง SmartRoute ใหม่จากข้อมูลในฟอร์ม
                    SmartRoute updatedRoute = SmartRoute(
                      id: widget.route.id,
                      routeName: routeNameController.text,
                      startPoint: startPointController.text,
                      endPoint: endPointController.text,
                      vehicleNumber: vehicleNumberController.text,
                      departureTime: departureTimeController.text,
                      estimatedArrivalTime: estimatedArrivalTimeController.text,
                      crowdLevel: int.parse(crowdLevelController.text),
                    );

                    // อัปเดตข้อมูลผ่าน Provider
                    Provider.of<SmartTransportProvider>(context, listen: false)
                        .updateRoute(updatedRoute);

                    // ปิดหน้าจอ
                    Navigator.pop(context);
                  }
                },
                child: const Text('แก้ไขข้อมูลเส้นทาง'),
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
    startPointController.dispose();
    endPointController.dispose();
    vehicleNumberController.dispose();
    departureTimeController.dispose();
    estimatedArrivalTimeController.dispose();
    crowdLevelController.dispose();
    super.dispose();
  }
}