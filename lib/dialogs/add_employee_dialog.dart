import 'package:flutter/material.dart';
import '../models/employee.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  /// Show the dialog. Returns the created Employee or null if cancelled.
  static Future<Employee?> show(BuildContext context) {
    return showDialog<Employee>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddEmployeeDialog(),
    );
  }

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();

  EmployeeRole _role = EmployeeRole.doctor;
  bool _isActive = true;

  final List<String> _departments = const [
    'Cardiology',
    'Neurology',
    'Dermatology',
    'Orthopedics',
    'Pediatrics',
    'Emergency',
    'ICU',
    'Radiology',
    'Administration',
    'Ambulance Services',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final employee = Employee(
      id: 'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: _nameController.text.trim(),
      role: _role,
      department: _departmentController.text.trim(),
      specialization: _specializationController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      isActive: _isActive,
      experience: int.tryParse(_experienceController.text) ?? 0,
    );

    // TODO: Send to backend via API call here
    // await api.createEmployee(employee);

    Navigator.of(context).pop(employee);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Role *'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EmployeeRole.values.map((role) {
                          return _roleChip(role);
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _label('Full Name *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('e.g. Dr. Sarah Wilson'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Department *'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _departmentController.text.isEmpty
                                      ? null
                                      : _departmentController.text,
                                  decoration: _inputDecoration('Select'),
                                  items: _departments
                                      .map((d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      _departmentController.text = v ?? '',
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Specialization'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _specializationController,
                                  decoration: _inputDecoration(
                                      'e.g. Cardiologist'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Phone *'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration:
                                      _inputDecoration('+1 555-0100'),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Phone required'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Experience (years)'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _experienceController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('0'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label('Email *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('name@hospital.com'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          final regex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(v.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Account Status',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    'Active employees can log in',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (v) =>
                                  setState(() => _isActive = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_add_alt_rounded,
                color: Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Employee',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Register a new staff member',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              foregroundColor: const Color(0xFF374151),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Save Employee'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(EmployeeRole role) {
    final selected = _role == role;
    final color = _roleColor(role);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_roleIcon(role),
                size: 16, color: selected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              _roleName(role),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? color : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleName(EmployeeRole r) {
    switch (r) {
      case EmployeeRole.doctor:
        return 'Doctor';
      case EmployeeRole.nurse:
        return 'Nurse';
      case EmployeeRole.technician:
        return 'Technician';
      case EmployeeRole.admin:
        return 'Admin';
      case EmployeeRole.driver:
        return 'Driver';
    }
  }

  Color _roleColor(EmployeeRole r) {
    switch (r) {
      case EmployeeRole.doctor:
        return const Color(0xFF2563EB);
      case EmployeeRole.nurse:
        return const Color(0xFFEC4899);
      case EmployeeRole.technician:
        return const Color(0xFF8B5CF6);
      case EmployeeRole.admin:
        return const Color(0xFF6B7280);
      case EmployeeRole.driver:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _roleIcon(EmployeeRole r) {
    switch (r) {
      case EmployeeRole.doctor:
        return Icons.medical_services_rounded;
      case EmployeeRole.nurse:
        return Icons.health_and_safety_rounded;
      case EmployeeRole.technician:
        return Icons.build_rounded;
      case EmployeeRole.admin:
        return Icons.admin_panel_settings_rounded;
      case EmployeeRole.driver:
        return Icons.local_shipping_rounded;
    }
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151)));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}