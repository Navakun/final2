import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/model/transport_ticket.dart';
import 'package:smart_transport/model/user.dart';

class RouteDatabase {
  final String dbName;

  RouteDatabase({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    return await dbFactory.openDatabase(dbLocation);
  }

  // เส้นทาง
  Future<int?> insertRoute(SmartRoute route) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('routes');
    int? keyID = await store.add(db, {
      'routeName': route.routeName,
      'startPoint': route.startPoint,
      'endPoint': route.endPoint,
      'vehicleNumber': route.vehicleNumber,
      'departureTime': route.departureTime,
      'estimatedArrivalTime': route.estimatedArrivalTime,
      'fare': route.fare,
    });
    await db.close();
    return keyID;
  }

  Future<List<SmartRoute>> loadAllRoutes() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('routes');
    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('departureTime', false)]),
    );
    List<SmartRoute> routes = snapshot.map((record) {
      return SmartRoute(
        id: record.key,
        routeName: record['routeName']?.toString() ?? '',
        startPoint: record['startPoint']?.toString() ?? '',
        endPoint: record['endPoint']?.toString() ?? '',
        vehicleNumber: record['vehicleNumber']?.toString() ?? '',
        departureTime: record['departureTime']?.toString() ?? '',
        estimatedArrivalTime: record['estimatedArrivalTime']?.toString() ?? '',
        fare: record['fare'] != null ? double.tryParse(record['fare'].toString()) ?? 0.0 : 0.0,
      );
    }).toList();
    await db.close();
    return routes;
  }

  Future<void> deleteRoute(SmartRoute route) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('routes');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, route.id)));
    await db.close();
  }

  Future<void> updateRoute(SmartRoute route) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('routes');
    await store.update(
      db,
      {
        'routeName': route.routeName,
        'startPoint': route.startPoint,
        'endPoint': route.endPoint,
        'vehicleNumber': route.vehicleNumber,
        'departureTime': route.departureTime,
        'estimatedArrivalTime': route.estimatedArrivalTime,
        'fare': route.fare,
      },
      finder: Finder(filter: Filter.equals(Field.key, route.id)),
    );
    await db.close();
  }

  // ผู้ใช้
  Future<int?> insertUser(User user) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('users');
    int? keyID = await store.add(db, {
      'username': user.username,
      'email': user.email,
      'role': user.role, // บันทึก role
    });
    await db.close();
    return keyID;
  }

  Future<List<User>> loadAllUsers() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('users');
    var snapshot = await store.find(db);
    List<User> users = snapshot.map((record) {
      return User(
        id: record.key,
        username: record['username']?.toString() ?? '',
        email: record['email']?.toString() ?? '',
        role: record['role']?.toString() ?? 'general', // ค่าเริ่มต้นเป็น general
      );
    }).toList();
    await db.close();
    return users;
  }

  // ตั๋ว
  Future<int?> insertTicket(TransportTicket ticket) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('tickets');
    int? keyID = await store.add(db, {
      'routeId': ticket.routeId,
      'routeName': ticket.routeName,
      'fare': ticket.fare,
      'purchaseDate': ticket.purchaseDate.toIso8601String(),
      'status': ticket.status,
      'quantity': ticket.quantity,
      'userId': ticket.userId,
    });
    await db.close();
    return keyID;
  }

  Future<List<TransportTicket>> loadAllTickets({int? userId}) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('tickets');
    var finder = userId != null
        ? Finder(filter: Filter.equals('userId', userId), sortOrders: [SortOrder('purchaseDate', false)])
        : Finder(sortOrders: [SortOrder('purchaseDate', false)]);
    var snapshot = await store.find(db, finder: finder);
    List<TransportTicket> tickets = snapshot.map((record) {
      return TransportTicket(
        id: record.key,
        routeId: record['routeId'] != null ? int.parse(record['routeId'].toString()) : 0,
        routeName: record['routeName']?.toString() ?? '',
        fare: record['fare'] != null ? double.tryParse(record['fare'].toString()) ?? 0.0 : 0.0,
        purchaseDate: record['purchaseDate'] != null
            ? DateTime.parse(record['purchaseDate'].toString())
            : DateTime.now(),
        status: record['status']?.toString() ?? 'unknown',
        quantity: record['quantity'] != null ? int.parse(record['quantity'].toString()) : 1,
        userId: record['userId'] != null ? int.parse(record['userId'].toString()) : 0,
      );
    }).toList();
    await db.close();
    return tickets;
  }

  Future<void> deleteTicket(TransportTicket ticket) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('tickets');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, ticket.id)));
    await db.close();
  }
}