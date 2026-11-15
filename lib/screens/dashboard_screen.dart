import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../pages/dashboard_home.dart';
import '../pages/booking_page.dart';
import '../pages/history_page.dart';
import '../pages/employee_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = ['Dashboard', 'Bookings', 'History', 'Employees'];

  void _onMenuSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 1:
        return const BookingPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const EmployeePage();
      default:
        return const DashboardHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onSelected: _onMenuSelected,
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          _iconButton(Icons.notifications_outlined, badge: true),
          const SizedBox(width: 12),
          _iconButton(Icons.settings_outlined),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF2563EB),
            child: Text(
              'AD',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin User',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Administrator',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
        ),
        if (badge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}