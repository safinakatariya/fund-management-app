import 'package:flutter/material.dart';

class FundScreen extends StatefulWidget {
  @override
  State<FundScreen> createState() => _FundScreenState();
}

class _FundScreenState extends State<FundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fund', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.teal.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Fund Amount:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            DataTable(
              columnSpacing: 100,
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.teal.shade200),
              dataRowColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Colors.teal.shade100
                      : Colors.white),
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('Total Fund',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('This Month Fund',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Add more DataColumn widgets for more columns
              ],
              rows: const <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text('Null')),
                    DataCell(Text('Null')),
                    // Add more DataCell widgets for more cells
                  ],
                ),
                // Add more DataRow widgets for more rows
              ],
            ),
          ],
        ),
      ),
    );
  }
}
