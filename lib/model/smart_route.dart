class SmartRoute {
  final int id;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final String vehicleNumber;
  final String departureTime;
  final String estimatedArrivalTime;
  final double fare;

  SmartRoute({
    required this.id,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    required this.vehicleNumber,
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.fare,
  });
}