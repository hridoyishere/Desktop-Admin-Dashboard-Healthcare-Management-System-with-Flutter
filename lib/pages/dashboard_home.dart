import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/booking.dart';
import '../models/employee.dart';
import '../widgets/stat_card.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = DemoData.bookings;
    final employees = DemoData.employees;
    final doctorBookings =
        bookings.where((b) => b.type == BookingType.doctor).length;
    final ambulanceBookings =
        bookings.where((b) => b.type == BookingType.ambulance).length;
    final totalRevenue =
        bookings.fold<double>(0, (sum, b) => sum + b.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Bookings',
                  value: '${bookings.length}',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF2563EB),
                  subtitle: 'All time',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Doctor Bookings',
                  value: '$doctorBookings',
                  icon: Icons.medical_services_rounded,
                  color: const Color(0xFF10B981),
                  subtitle: 'Consultations',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Ambulance Bookings',
                  value: '$ambulanceBookings',
                  icon: Icons.local_shipping_rounded,
                  color: const Color(0xFFF59E0B),
                  subtitle: 'Emergency service',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Total Revenue',
                  value: '\$${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF8B5CF6),
                  subtitle: 'From bookings',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _recentBookings(bookings),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _staffBreakdown(employees),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentBookings(List<Booking> bookings) {
    final recent = bookings.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...recent.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: b.type == BookingType.doctor
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        b.type == BookingType.doctor
                            ? Icons.medical_services
                            : Icons.local_shipping,
                        size: 20,
                        color: b.type == BookingType.doctor
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.patientName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(b.details,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('\$${b.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _staffBreakdown(List<Employee> employees) {
    final counts = <EmployeeRole, int>{};
    for (final e in employees) {
      counts[e.role] = (counts[e.role] ?? 0) + 1;
    }
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...counts.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _roleName(e.key),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${e.value}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _roleName(EmployeeRole r) {
    switch (r) {
      case EmployeeRole.doctor:
        return 'Doctors';
      case EmployeeRole.nurse:
        return 'Nurses';
      case EmployeeRole.technician:
        return 'Technicians';
      case EmployeeRole.admin:
        return 'Admin Staff';
      case EmployeeRole.driver:
        return 'Drivers';
    }
  }
}