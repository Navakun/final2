import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/model/transport_ticket.dart';

class RouteDatabase {
  final String dbName;

  RouteDatabase({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    return await dbFactory.openDatabase(dbLocation);
  }

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
      'crowdLevel': route.crowdLevel,
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
        routeName: record['routeName'].toString(),
        startPoint: record['startPoint'].toString(),
        endPoint: record['endPoint'].toString(),
        vehicleNumber: record['vehicleNumber'].toString(),
        departureTime: record['departureTime'].toString(),
        estimatedArrivalTime: record['estimatedArrivalTime'].toString(),
        crowdLevel: int.parse(record['crowdLevel'].toString()),
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
        'crowdLevel': route.crowdLevel,
      },
      finder: Finder(filter: Filter.equals(Field.key, route.id)),
    );
    await db.close();
  }

  Future<int?> insertTicket(TransportTicket ticket) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('tickets');
    int? keyID = await store.add(db, {
      'routeId': ticket.routeId,
      'routeName': ticket.routeName,
      'fare': ticket.fare,
      'purchaseDate': ticket.purchaseDate.toIso8601String(),
      'status': ticket.status,
    });
    await db.close();
    return keyID;
  }

  Future<List<TransportTicket>> loadAllTickets() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('tickets');
    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('purchaseDate', false)]),
    );
    List<TransportTicket> tickets = snapshot.map((record) {
      return TransportTicket(
        id: record.key,
        routeId: int.parse(record['routeId'].toString()),
        routeName: record['routeName'].toString(),
        fare: double.parse(record['fare'].toString()),
        purchaseDate: DateTime.parse(record['purchaseDate'].toString()),
        status: record['status'].toString(),
      );
    }).toList();
    await db.close();
    return tickets;
  }
}