import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/booking.dart';
import '../widgets/data_table_widget.dart';
import '../dialogs/add_booking_dialog.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _filter = 'all';

  // Local list so newly added bookings show instantly in the UI.
  // Replace with data fetched from backend later.
  final List<Booking> _localBookings = List.of(DemoData.bookings);

  List<Booking> get _filtered {
    if (_filter == 'doctor') {
      return _localBookings.where((b) => b.type == BookingType.doctor).toList();
    }
    if (_filter == 'ambulance') {
      return _localBookings
          .where((b) => b.type == BookingType.ambulance)
          .toList();
    }
    return _localBookings;
  }

  Future<void> _openAddBookingDialog() async {
    final created = await AddBookingDialog.show(context);
    if (!mounted) return;
    if (created != null) {
      setState(() => _localBookings.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${created.id} created successfully'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filtered;
    final doctorCount =
        _localBookings.where((b) => b.type == BookingType.doctor).length;
    final ambulanceCount =
        _localBookings.where((b) => b.type == BookingType.ambulance).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(doctorCount, ambulanceCount),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: DataTableWidget(
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
                  DataCell(_typeChip(b.type)),
                  DataCell(Text(b.patientName)),
                  DataCell(Text(b.details)),
                  DataCell(Text(b.date)),
                  DataCell(Text(b.time)),
                  DataCell(Text('\$${b.amount.toStringAsFixed(2)}')),
                  DataCell(_statusChip(b.status)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(int doctorCount, int ambulanceCount) {
    return Row(
      children: [
        _filterChip(
            'All', 'all', _localBookings.length, const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        _filterChip(
            'Doctor Bookings', 'doctor', doctorCount, const Color(0xFF10B981)),
        const SizedBox(width: 10),
        _filterChip('Ambulance Bookings', 'ambulance', ambulanceCount,
            const Color(0xFFF59E0B)),
        const Spacer(),
        FilledButton.icon(
          onPressed: _openAddBookingDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Booking'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value, int count, Color color) {
    final selected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(BookingType type) {
    final isDoctor = type == BookingType.doctor;
    final color = isDoctor ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDoctor ? 'Doctor' : 'Ambulance',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    final (label, color) = switch (status) {
      BookingStatus.pending => ('Pending', const Color(0xFFF59E0B)),
      BookingStatus.confirmed => ('Confirmed', const Color(0xFF2563EB)),
      BookingStatus.completed => ('Completed', const Color(0xFF10B981)),
      BookingStatus.cancelled => ('Cancelled', const Color(0xFFEF4444)),
    };
    return statusChip(label, color);
  }
}
