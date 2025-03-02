import 'package:flutter/material.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/model/transport_ticket.dart';
import 'package:smart_transport/screens/route_database.dart';

class SmartTransportProvider with ChangeNotifier {
  List<SmartRoute> _routes = [];
  List<TransportTicket> _tickets = [];
  late RouteDatabase _db;
  bool _isLoading = false;

  SmartTransportProvider() {
    _db = RouteDatabase(dbName: 'smart_transport.db');
    fetchRoutes();
    fetchTickets();
  }

  List<SmartRoute> get routes => _routes;
  List<TransportTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;

  Future<void> fetchRoutes() async {
    _isLoading = true;
    notifyListeners();
    _routes = await _db.loadAllRoutes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTickets() async {
    _isLoading = true;
    notifyListeners();
    _tickets = await _db.loadAllTickets();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRoute(SmartRoute route) async {
    int? newId = await _db.insertRoute(route);
    if (newId != null) {
      _routes.add(route.copyWith(id: newId));
      notifyListeners();
    }
  }

  Future<void> removeRoute(SmartRoute route) async {
    await _db.deleteRoute(route);
    _routes.removeWhere((r) => r.id == route.id);
    notifyListeners();
  }

  Future<void> updateRoute(SmartRoute updatedRoute) async {
    await _db.updateRoute(updatedRoute);
    final index = _routes.indexWhere((r) => r.id == updatedRoute.id);
    if (index != -1) {
      _routes[index] = updatedRoute;
      notifyListeners();
    }
  }

  Future<void> purchaseTicket(SmartRoute route, double fare) async {
    final ticket = TransportTicket(
      id: 0,
      routeId: route.id,
      routeName: route.routeName,
      fare: fare,
      purchaseDate: DateTime.now(),
      status: 'active',
    );
    int? newId = await _db.insertTicket(ticket);
    if (newId != null) {
      _tickets.add(ticket.copyWith(id: newId));
      notifyListeners();
    }
  }
}

extension SmartRouteExtension on SmartRoute {
  SmartRoute copyWith({
    int? id,
    String? routeName,
    String? startPoint,
    String? endPoint,
    String? vehicleNumber,
    String? departureTime,
    String? estimatedArrivalTime,
    int? crowdLevel,
  }) {
    return SmartRoute(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      crowdLevel: crowdLevel ?? this.crowdLevel,
    );
  }
}

extension TransportTicketExtension on TransportTicket {
  TransportTicket copyWith({
    int? id,
    int? routeId,
    String? routeName,
    double? fare,
    DateTime? purchaseDate,
    String? status,
  }) {
    return TransportTicket(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      fare: fare ?? this.fare,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
    );
  }
}