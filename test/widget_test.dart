import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/main.dart'; // อ้างอิงไฟล์ main.dart
import 'package:smart_transport/provider/smart_transport_provider.dart';

void main() {
  testWidgets('Smart Transport App displays home page correctly', (WidgetTester tester) async {
    // สร้าง Provider สำหรับการทดสอบ
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SmartTransportProvider()),
        ],
        child: const SmartTransportApp(), // เปลี่ยนจาก MyApp เป็น SmartTransportApp
      ),
    );

    // รอให้ UI ถูก render
    await tester.pumpAndSettle();

    // ตรวจสอบว่า AppBar มีข้อความ "ระบบขนส่งสาธารณะอัจฉริยะ"
    expect(find.text('ระบบขนส่งสาธารณะอัจฉริยะ'), findsOneWidget);

    // ตรวจสอบว่ามีปุ่มเพิ่มเส้นทาง (IconButton ที่มี Icons.add)
    expect(find.byIcon(Icons.add), findsOneWidget);

    // ตรวจสอบข้อความเริ่มต้นเมื่อยังไม่มีข้อมูล
    expect(find.text('ไม่มีเส้นทางขนส่งในขณะนี้'), findsOneWidget);
  });

  testWidgets('Navigate to RouteFormScreen on add button tap', (WidgetTester tester) async {
    // สร้าง Provider และรันแอป
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SmartTransportProvider()),
        ],
        child: const SmartTransportApp(),
      ),
    );

    await tester.pumpAndSettle();

    // กดปุ่มเพิ่มเส้นทาง
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // ตรวจสอบว่าไปที่หน้า RouteFormScreen โดยเช็ค AppBar title
    expect(find.text('เพิ่มข้อมูลเส้นทาง'), findsOneWidget);
  });
}