import 'package:account/model/transactionItem.dart';
import 'package:flutter/foundation.dart';
import 'package:account/database/transactionDB.dart';

class TransactionProvider with ChangeNotifier{

  List<TransactionItem> transactions = [];


  List<TransactionItem> getTransaction() {
    return transactions;
  }

  void initData() async{
    var db = TransactionDB(dbName: 'transactions.db');
    transactions = await db.loadAllData();
    notifyListeners();
  }

  void addTransaction(TransactionItem transaction) async {
    var db = TransactionDB(dbName: 'transactions.db');
    
    await db.insertDatabase(transaction);
    transactions = await db.loadAllData();
    notifyListeners();
  }

  deleteTransaction(TransactionItem transaction) async{
    var db = TransactionDB(dbName: 'transactions.db');
    // delete from database
    await db.deleteData(transaction);
    transactions = await db.loadAllData();
    notifyListeners();
  }

  void updateTransaction(TransactionItem transaction) async{
    var db = TransactionDB(dbName: 'transactions.db');
    // update database
    await db.updateData(transaction);
    transactions = await db.loadAllData();
    notifyListeners();
  }

}
