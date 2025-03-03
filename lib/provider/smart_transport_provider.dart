import 'package:flutter/material.dart';
import 'package:smart_transport/model/smart_route.dart';
import 'package:smart_transport/model/transport_ticket.dart';
import 'package:smart_transport/model/user.dart';
import 'package:smart_transport/screens/route_database.dart';

class SmartTransportProvider with ChangeNotifier {
  List<SmartRoute> _routes = [];
  List<TransportTicket> _tickets = [];
  List<User> _users = [];
  User? _currentUser;
  late RouteDatabase _db;
  bool _isLoading = false;

  SmartTransportProvider() {
    _db = RouteDatabase(dbName: 'smart_transport.db');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUsers();
      fetchRoutes();
      fetchTickets();
    });
  }

  List<SmartRoute> get routes => _routes;
  List<TransportTicket> get tickets => _currentUser != null
      ? _tickets.where((ticket) => ticket.userId == _currentUser!.id).toList()
      : _tickets;
  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void setCurrentUser(User user) {
    // ตรวจสอบว่า user อยู่ใน _users หรือไม่
    if (!_users.any((u) => u.id == user.id)) {
      _users.add(user);
    }
    _currentUser = _users.firstWhere((u) => u.id == user.id);
    notifyListeners();
  }

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
    _tickets = await _db.loadAllTickets(userId: _currentUser?.id);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    _users = await _db.loadAllUsers();
    if (_users.isNotEmpty) {
      if (_currentUser == null) {
        _currentUser = _users.first;
      } else {
        // ตรวจสอบว่า _currentUser ยังอยู่ใน _users หรือไม่
        _currentUser = _users.firstWhere(
          (u) => u.id == _currentUser!.id,
          orElse: () => _users.first,
        );
      }
    } else {
      _currentUser = null; // ถ้าไม่มีผู้ใช้เลย
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRoute(SmartRoute route) async {
    if (_currentUser == null || _currentUser!.role != 'admin') {
      throw Exception('เฉพาะผู้ดูแลระบบเท่านั้นที่สามารถเพิ่มเส้นทางได้');
    }
    int? newId = await _db.insertRoute(route);
    if (newId != null) {
      _routes.add(route.copyWith(id: newId));
      notifyListeners();
    }
  }

  Future<void> removeRoute(SmartRoute route) async {
    if (_currentUser == null || _currentUser!.role != 'admin') {
      throw Exception('เฉพาะผู้ดูแลระบบเท่านั้นที่สามารถลบเส้นทางได้');
    }
    await _db.deleteRoute(route);
    _routes.removeWhere((r) => r.id == route.id);
    notifyListeners();
  }

  Future<void> updateRoute(SmartRoute updatedRoute) async {
    if (_currentUser == null || _currentUser!.role != 'admin') {
      throw Exception('เฉพาะผู้ดูแลระบบเท่านั้นที่สามารถแก้ไขเส้นทางได้');
    }
    await _db.updateRoute(updatedRoute);
    final index = _routes.indexWhere((r) => r.id == updatedRoute.id);
    if (index != -1) {
      _routes[index] = updatedRoute;
      notifyListeners();
    }
  }

  Future<void> purchaseTicket(SmartRoute route, double fare, int quantity) async {
    if (_currentUser == null) throw Exception('กรุณาเลือกผู้ใช้ก่อนซื้อตั๋ว');
    final ticket = TransportTicket(
      id: 0,
      routeId: route.id,
      routeName: route.routeName,
      fare: fare,
      purchaseDate: DateTime.now(),
      status: 'active',
      quantity: quantity,
      userId: _currentUser!.id,
    );
    int? newId = await _db.insertTicket(ticket);
    if (newId != null) {
      _tickets.add(ticket.copyWith(id: newId));
      notifyListeners();
    }
  }

  Future<void> cancelTicket(TransportTicket ticket) async {
    await _db.deleteTicket(ticket);
    _tickets.removeWhere((t) => t.id == ticket.id);
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    int? newId = await _db.insertUser(user);
    if (newId != null) {
      _users.add(user.copyWith(id: newId));
      if (_currentUser == null) _currentUser = _users.first;
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
    double? fare,
  }) {
    return SmartRoute(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      fare: fare ?? this.fare,
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
    int? quantity,
    int? userId,
  }) {
    return TransportTicket(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      fare: fare ?? this.fare,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
    );
  }
}

extension UserExtension on User {
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}