
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../models/employee.dart';
import '../api/doctors_api.dart';

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

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

  final DoctorApi _api = DoctorApi();

  // Controllers
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _ratingController = TextEditingController(text: '5.0');
  final _aboutController = TextEditingController();

  EmployeeRole _role = EmployeeRole.doctor;

  bool _isActive = true;
  bool _isSubmitting = false;

  String? _selectedImagePath;

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
    _addressController.dispose();
    _workingHoursController.dispose();
    _ratingController.dispose();
    _aboutController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // IMAGE PICKER
  // --------------------------------------------------

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null) return;

      final path = result.files.single.path;

      if (path == null) return;

      if (!mounted) return;

      setState(() {
        _selectedImagePath = path;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selection failed: $error'),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  // --------------------------------------------------
  // SUBMIT DOCTOR
  // --------------------------------------------------

  Future<void> _submit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    // Current backend endpoint supports doctors only.
    if (_role != EmployeeRole.doctor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Currently, only doctors can be registered.'),
        ),
      );
      return;
    }

    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a doctor image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rating = double.tryParse(_ratingController.text.trim());
    final experience = int.tryParse(_experienceController.text.trim());

    if (rating == null || rating < 0 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating must be between 0 and 5.'),
        ),
      );
      return;
    }

    if (experience == null || experience < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid experience in years.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create Employee model
      final employee = Employee(
        id: null,
        name: _nameController.text.trim(),
        role: _role,
        department: _departmentController.text.trim(),
        specialization: _specializationController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        isActive: _isActive,
        address: _addressController.text.trim(),
        workingHours: _workingHoursController.text.trim(),
        rating: rating,
        about: _aboutController.text.trim(),
        experience: experience,
        imagePath: _selectedImagePath!,
      );

      // Send Employee model to backend
      final response = await _api.createDoctor(employee);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor registered successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        Navigator.of(context).pop(employee);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 620,
          maxHeight: 780,
        ),
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
                      // ROLE
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

                      // NAME
                      _label('Full Name *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          'e.g. Dr. Sarah Wilson',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Name is required'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // DEPARTMENT AND SPECIALIZATION
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
                                  isExpanded: true,
                                  decoration: _inputDecoration('Select'),
                                  items: _departments.map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    _departmentController.text = v ?? '';
                                  },
                                  validator: (v) =>
                                      v == null || v.isEmpty
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
                                _label('Specialization *'),
                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _specializationController,
                                  decoration: _inputDecoration(
                                    'e.g. Cardiologist',
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // PHONE AND EXPERIENCE
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
                                  decoration: _inputDecoration(
                                    '+880 1712345678',
                                  ),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
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
                                _label('Experience (years) *'),
                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _experienceController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration('10'),
                                  validator: (v) {
                                    final value = int.tryParse(v ?? '');

                                    if (value == null || value < 0) {
                                      return 'Enter valid years';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // EMAIL
                      _label('Email *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          'name@hospital.com',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }

                          final regex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );

                          if (!regex.hasMatch(v.trim())) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ADDRESS
                      _label('Address *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration(
                          'Hospital address',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Address is required'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // WORKING HOURS
                      _label('Working Hours *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _workingHoursController,
                        decoration: _inputDecoration(
                          'Mon - Fri: 9 AM - 5 PM',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Working hours required'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // RATING
                      _label('Rating (0 - 5) *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _ratingController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration('4.8'),
                        validator: (v) {
                          final value = double.tryParse(v ?? '');

                          if (value == null ||
                              value < 0 ||
                              value > 5) {
                            return 'Rating must be between 0 and 5';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ABOUT
                      _label('About Doctor *'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _aboutController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          'Write about the doctor...',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'About is required'
                                : null,
                      ),

                      const SizedBox(height: 20),

                      // IMAGE UPLOADER
                      _buildImageUploader(),

                      const SizedBox(height: 20),

                      // ACCOUNT STATUS
                      _buildAccountStatus(),
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

  // --------------------------------------------------
  // IMAGE UPLOADER UI
  // --------------------------------------------------

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Doctor Profile Image *'),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: _selectedImagePath == null
              ? _buildImagePlaceholder()
              : _buildSelectedImage(),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: Color(0xFF8B5CF6),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Upload Doctor Image',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Select an image from your device',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),

        const SizedBox(height: 14),

        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : _pickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Choose Image'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedImage() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_selectedImagePath!),
            width: 95,
            height: 95,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 95,
                height: 95,
                color: const Color(0xFFE5E7EB),
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Image selected',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF059669),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _selectedImagePath!.split(Platform.pathSeparator).last,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _pickImage,
                    icon: const Icon(Icons.edit, size: 15),
                    label: const Text('Change'),
                  ),

                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _removeImage,
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // ACCOUNT STATUS
  // --------------------------------------------------

  Widget _buildAccountStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  'Active employees can log in',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: _isActive,
            activeColor: const Color(0xFF10B981),
            onChanged: _isSubmitting
                ? null
                : (v) => setState(() => _isActive = v),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
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
            child: const Icon(
              Icons.person_add_alt_rounded,
              color: Color(0xFF8B5CF6),
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Employee',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  'Register a new staff member',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // FOOTER
  // --------------------------------------------------

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
              side: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
              foregroundColor: const Color(0xFF374151),
            ),
            child: const Text('Cancel'),
          ),

          const SizedBox(width: 12),

          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 18),
            label: Text(
              _isSubmitting ? 'Uploading...' : 'Save Employee',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ROLE CHIP
  // --------------------------------------------------

  Widget _roleChip(EmployeeRole role) {
    final selected = _role == role;
    final color = _roleColor(role);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _isSubmitting
          ? null
          : () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color
                : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _roleIcon(role),
              size: 16,
              color: selected ? color : Colors.grey,
            ),

            const SizedBox(width: 6),

            Text(
              _roleName(role),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? color
                    : const Color(0xFF374151),
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

  // --------------------------------------------------
  // COMMON WIDGETS
  // --------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9CA3AF),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
    );
  }
}
