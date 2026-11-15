import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/booking.dart';
import '../widgets/data_table_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filter = 'all';

  List<Booking> get _filtered {
    // History shows completed & cancelled bookings
    final history = DemoData.bookings.where((b) =>
        b.status == BookingStatus.completed ||
        b.status == BookingStatus.cancelled);
    if (_filter == 'doctor') {
      return history.where((b) => b.type == BookingType.doctor).toList();
    }
    if (_filter == 'ambulance') {
      return history.where((b) => b.type == BookingType.ambulance).toList();
    }
    return history.toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filtered;
    final all = DemoData.bookings.where((b) =>
        b.status == BookingStatus.completed ||
        b.status == BookingStatus.cancelled);
    final doctorCount =
        all.where((b) => b.type == BookingType.doctor).length;
    final ambulanceCount =
        all.where((b) => b.type == BookingType.ambulance).length;
    final totalAmount =
        bookings.fold<double>(0, (s, b) => s + b.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHistorySummary(doctorCount, ambulanceCount, totalAmount),
        const SizedBox(height: 16),
        _buildFilterBar(doctorCount, ambulanceCount),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: DataTableWidget(
              emptyMessage: 'No completed or cancelled bookings in history',
              columns: const [
                DataColumn(label: Text('Booking ID')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Patient')),
                DataColumn(label: Text('Details')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: bookings.map((b) {
                return DataRow(cells: [
                  DataCell(Text(b.id,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(statusChip(
                    b.type == BookingType.doctor ? 'Doctor' : 'Ambulance',
                    b.type == BookingType.doctor
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  )),
                  DataCell(Text(b.patientName)),
                  DataCell(Text(b.details)),
                  DataCell(Text(b.date)),
                  DataCell(Text(b.time)),
                  DataCell(Text('\$${b.amount.toStringAsFixed(2)}')),
                  DataCell(statusChip(
                    b.status == BookingStatus.completed
                        ? 'Completed'
                        : 'Cancelled',
                    b.status == BookingStatus.completed
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySummary(
      int doctorCount, int ambulanceCount, double totalAmount) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Doctor History',
            '$doctorCount records',
            Icons.medical_services_rounded,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryCard(
            'Ambulance History',
            '$ambulanceCount records',
            Icons.local_shipping_rounded,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryCard(
            'Total History Revenue',
            '\$${totalAmount.toStringAsFixed(2)}',
            Icons.receipt_long_rounded,
            const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int doctorCount, int ambulanceCount) {
    return Row(
      children: [
        _filterChip('All History', 'all', doctorCount + ambulanceCount,
            const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        _filterChip('Doctor History', 'doctor', doctorCount,
            const Color(0xFF10B981)),
        const SizedBox(width: 10),
        _filterChip('Ambulance History', 'ambulance', ambulanceCount,
            const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _filterChip(
      String label, String value, int count, Color color) {
    final isSelected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}