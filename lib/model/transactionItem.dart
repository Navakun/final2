class TransactionItem {
  int? keyID;
  String title;
  double amount;
  DateTime? date;

  TransactionItem({this.keyID, required this.title, required this.amount, this.date});
}