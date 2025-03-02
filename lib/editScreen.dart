import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  TransactionItem item;
  
  EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.item.title;
    amountController.text = widget.item.amount.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(label: const Text('ชื่อรายการ')),
              autofocus: true,
              controller: titleController,
              validator: (String? value) {
                if(value!.isEmpty){
                  print('value: $value');
                  return "กรุณาป้อนชื่อรายการ";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(label: const Text('จำนวนเงิน')),
              keyboardType: TextInputType.number,
              controller: amountController,
              validator: (String? value) {
                try{
                  double amount = double.parse(value!);
                  if(amount <= 0){
                    return "กรุณาป้อนจำนวนเงินที่มากกว่า 0";
                  }
                  
                } catch(e){
                  return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if(formKey.currentState!.validate()){
                  // ทำการเพิ่มข้อมูล
                  var provider = Provider.of<TransactionProvider>(context, listen: false);
                  
                  TransactionItem item = TransactionItem(
                    keyID: widget.item.keyID,
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    date: widget.item.date
                  );

                  provider.updateTransaction(item);

                  // ปิดหน้าจอ
                  Navigator.pop(context);
                }
              },
              child: const Text('แก้ไขข้อมูล'),
            ),
        ],),
      ),
    );
  }
}