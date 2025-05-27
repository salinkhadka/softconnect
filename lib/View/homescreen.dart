import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Role')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('1')),
              DataCell(Text('Alice')),
              DataCell(Text('Developer')),
            ]),
            DataRow(cells: [
              DataCell(Text('2')),
              DataCell(Text('Bob')),
              DataCell(Text('Designer')),
            ]),
            DataRow(cells: [
              DataCell(Text('3')),
              DataCell(Text('Charlie')),
              DataCell(Text('Manager')),
            ]),
          ],
        ),
      ),
    );
  }
}
