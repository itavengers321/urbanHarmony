import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb check

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  int totalUsers = 0;
  int totalOrders = 0;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchTotalUsers();
    fetchTotalOrders();
    fetchAllOrders();
  }

  Future<void> fetchTotalUsers() async {
    DatabaseReference ref = databaseReference.child("users");
    ref.orderByChild("type").equalTo("user").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        totalUsers = data != null ? data.length : 0;
      });
    });
  }

  Future<void> fetchTotalOrders() async {
    DatabaseReference ref = databaseReference.child("orders");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        totalOrders = data != null ? data.length : 0;
      });
    });
  }

  Future<void> fetchAllOrders() async {
    DatabaseReference ref = databaseReference.child("orders");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        orders = data.entries.map((entry) {
          return {
            'contacName': entry.value['contacName'],
            'city': entry.value['city'],
            'email': entry.value['email'],
            'mobile': entry.value['mobile'],
            'orderDate': entry.value['orderDate'],
            'status': 'Pending', // Set status as "Pending"
          };
        }).toList();
      } else {
        orders = [];
      }
      setState(() {});
    });
  }

  Future<void> generatePDFReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('User Reports',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Total Users: $totalUsers', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Total Orders: $totalOrders', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Text('Orders:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              context: context,
              data: _generateTableData(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: pw.TextStyle(),
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } else {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/report.pdf');
      await file.writeAsBytes(await pdf.save());
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    }
  }

  List<List<String>> _generateTableData() {
    List<List<String>> tableData = [
      ['Customer Name', 'City', 'Email', 'Mobile', 'Order Date', 'Status'],
    ];

    for (var order in orders) {
      tableData.add([
        order['contacName'] ?? '',
        order['city'] ?? '',
        order['email'] ?? '',
        order['mobile'] ?? '',
        order['orderDate'] ?? '',
        order['status'] ?? 'Pending', // Default to "Pending"
      ]);
    }
    return tableData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard('Total Users', '$totalUsers', Icons.people, Colors.blue),
            SizedBox(height: 20),
            _buildReportCard('Total Orders', '$totalOrders', Icons.shopping_cart, Colors.orange),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: generatePDFReport,
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Generate PDF Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  count,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
