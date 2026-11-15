import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyMessage;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage = 'No records found',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: rows.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(emptyMessage,
                    style: const TextStyle(color: Colors.grey)),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF9FAFB)),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontSize: 13,
                  ),
                  dataTextStyle: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13,
                  ),
                  columns: columns,
                  rows: rows,
                ),
              ),
            ),
    );
  }
}

Widget statusChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}