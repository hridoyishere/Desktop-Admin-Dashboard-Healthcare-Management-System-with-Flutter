import 'package:flutter/material.dart';
import '../data/demo_data.dart';
import '../models/employee.dart';
import '../widgets/data_table_widget.dart';
import '../dialogs/add_employee_dialog.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  EmployeeRole? _roleFilter;
  String _search = '';

  // Local list so newly added employees show instantly.
  // Replace with backend data later.
  final List<Employee> _localEmployees = List.of(DemoData.employees);

  List<Employee> get _filtered {
    return _localEmployees.where((e) {
      final matchesRole = _roleFilter == null || e.role == _roleFilter;
      final matchesSearch = _search.isEmpty ||
          e.name.toLowerCase().contains(_search.toLowerCase()) ||
          e.id!.toLowerCase().contains(_search.toLowerCase()) ||
          e.department.toLowerCase().contains(_search.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();
  }

  Future<void> _openAddEmployeeDialog() async {
    final created = await AddEmployeeDialog.show(context);
    if (!mounted) return;
    if (created != null) {
      setState(() => _localEmployees.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee ${created.name} added successfully'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoleSummary(),
        const SizedBox(height: 16),
        _buildToolbar(),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: DataTableWidget(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Department')),
                DataColumn(label: Text('Specialization')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Exp.')),
                DataColumn(label: Text('Status')),
              ],
              rows: employees.map((e) {
                return DataRow(cells: [
                  DataCell(Text(e.id ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(e.name,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(_roleChip(e.role)),
                  DataCell(Text(e.department)),
                  DataCell(Text(e.specialization)),
                  DataCell(Text(e.phone)),
                  DataCell(Text(e.email)),
                  DataCell(Text('${e.experience} yrs')),
                  DataCell(statusChip(
                    e.isActive ? 'Active' : 'Inactive',
                    e.isActive
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

  Widget _buildRoleSummary() {
    final counts = <EmployeeRole, int>{};
    for (final e in _localEmployees) {
      counts[e.role] = (counts[e.role] ?? 0) + 1;
    }
    final roles = EmployeeRole.values;
    return Row(
      children: roles.map((role) {
        final count = counts[role] ?? 0;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: role == roles.last ? 0 : 12),
            child: _roleCard(role, count),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        _filterButton(null, 'All', _localEmployees.length),
        const SizedBox(width: 8),
        ...EmployeeRole.values.map((role) {
          final count = _localEmployees.where((e) => e.role == role).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _filterButton(role, _roleName(role), count),
          );
        }),
        const Spacer(),
        SizedBox(
          width: 280,
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search employees...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _openAddEmployeeDialog,
          icon: const Icon(Icons.person_add_alt, size: 18),
          label: const Text('Add Employee'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _roleCard(EmployeeRole role, int count) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_roleIcon(role), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  _roleName(role),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(EmployeeRole? role, String label, int count) {
    final selected = _roleFilter == role;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _roleFilter = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
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
                color: selected ? Colors.white : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(EmployeeRole role) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _roleName(role),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _roleName(EmployeeRole role) {
    switch (role) {
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

  Color _roleColor(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.doctor:
        return const Color(0xFF2563EB);
      case EmployeeRole.nurse:
        return const Color(0xFF10B981);
      case EmployeeRole.technician:
        return const Color(0xFF8B5CF6);
      case EmployeeRole.admin:
        return const Color(0xFFF59E0B);
      case EmployeeRole.driver:
        return const Color(0xFFEF4444);
    }
  }

  IconData _roleIcon(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.doctor:
        return Icons.medical_services_rounded;
      case EmployeeRole.nurse:
        return Icons.local_hospital_rounded;
      case EmployeeRole.technician:
        return Icons.biotech_rounded;
      case EmployeeRole.admin:
        return Icons.manage_accounts_rounded;
      case EmployeeRole.driver:
        return Icons.local_shipping_rounded;
    }
  }
}
