import 'package:account/model/transactionItem.dart';
import 'package:account/provider/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'formScreen.dart';
import 'package:account/editScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            return TransactionProvider();
          })
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    TransactionProvider provider =
        Provider.of<TransactionProvider>(context, listen: false);
    provider.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FormScreen();
                }));
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (context, TransactionProvider provider, Widget? child) {
            int itemCount = provider.transactions.length;
            if (itemCount == 0) {
              return Center(
                child: Text(
                  'ไม่มีรายการ',
                  style: TextStyle(fontSize: 50),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, int index) {
                    TransactionItem data = provider.transactions[index];
                    return Dismissible(
                      key: Key(data.keyID.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        provider.deleteTransaction(data);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: ListTile(
                            title: Text(data.title),
                            subtitle: Text(
                                'วันที่บันทึกข้อมูล: ${data.date?.toIso8601String()}',
                                style: TextStyle(fontSize: 10)),
                            leading: CircleAvatar(
                              child: FittedBox(
                                child: Text(data.amount.toString()),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('ยืนยันการลบ'),
                                      content:
                                          Text('คุณต้องการลบรายการใช่หรือไม่?'),
                                      actions: [
                                        TextButton(
                                          child: Text('ยกเลิก'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('ลบรายการ'),
                                          onPressed: () {
                                            provider.deleteTransaction(data);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EditScreen(item: data);
                              }));
                            }),
                      ),
                    );
                  });
            }
          },
        ));
  }
}
