class TransportTicket {
  final int id;
  final int routeId;
  final String routeName;
  final double fare;
  final DateTime purchaseDate;
  final String status;
  final int quantity;
  final int userId; // เพิ่ม userId

  TransportTicket({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.fare,
    required this.purchaseDate,
    required this.status,
    required this.quantity,
    required this.userId,
  });
}