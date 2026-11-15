import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/booking.dart';

class AddBookingDialog extends StatefulWidget {
  const AddBookingDialog({super.key});

  /// Show the dialog. Returns the created Booking or null if cancelled.
  static Future<Booking?> show(BuildContext context) {
    return showDialog<Booking>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddBookingDialog(),
    );
  }

  @override
  State<AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends State<AddBookingDialog> {
  final _formKey = GlobalKey<FormState>();

  final _patientController = TextEditingController();
  final _detailsController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  BookingType _type = BookingType.doctor;
  BookingStatus _status = BookingStatus.pending;

  final List<String> _doctorOptions = const [
    'Dr. Sarah Wilson - Cardiology',
    'Dr. James Chen - Neurology',
    'Dr. Emily Stone - Dermatology',
    'Dr. Robert Kim - Orthopedics',
  ];
  final List<String> _ambulanceOptions = const [
    'AMB-108 - Transfer',
    'AMB-204 - Emergency',
    'AMB-311 - Emergency',
  ];
  String? _selectedDoctor;
  String? _selectedAmbulance;

  @override
  void dispose() {
    _patientController.dispose();
    _detailsController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text =
          '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final details = _type == BookingType.doctor
        ? (_selectedDoctor ?? '')
        : (_selectedAmbulance ?? '');

    final booking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      type: _type,
      patientName: _patientController.text.trim(),
      details: details,
      date: _dateController.text.isEmpty
          ? DateTime.now().toIso8601String().substring(0, 10)
          : _dateController.text,
      time: _timeController.text.isEmpty ? 'TBD' : _timeController.text,
      status: _status,
      amount: double.tryParse(_amountController.text) ?? 0,
    );

    // TODO: Send to backend via API call here
    // await api.createBooking(booking);

    Navigator.of(context).pop(booking);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
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
                      _label('Booking Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _typeChip(
                              label: 'Doctor Booking',
                              icon: Icons.medical_services_rounded,
                              color: const Color(0xFF10B981),
                              value: BookingType.doctor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _typeChip(
                              label: 'Ambulance Booking',
                              icon: Icons.local_shipping_rounded,
                              color: const Color(0xFFF59E0B),
                              value: BookingType.ambulance,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label('Patient Name *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _patientController,
                        decoration: _inputDecoration('e.g. John Doe'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Patient name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_type == BookingType.doctor) ...[
                        _label('Doctor *'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedDoctor,
                          decoration: _inputDecoration('Select a doctor'),
                          items: _doctorOptions
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d,
                                        style:
                                            const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDoctor = v),
                          validator: (v) =>
                              v == null ? 'Please select a doctor' : null,
                        ),
                      ] else ...[
                        _label('Ambulance *'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedAmbulance,
                          decoration: _inputDecoration('Select an ambulance'),
                          items: _ambulanceOptions
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d,
                                        style:
                                            const TextStyle(fontSize: 13)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAmbulance = v),
                          validator: (v) =>
                              v == null ? 'Please select an ambulance' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Date'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  onTap: _pickDate,
                                  decoration: _inputDecoration('YYYY-MM-DD')
                                      .copyWith(
                                    suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Time'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _timeController,
                                  readOnly: true,
                                  onTap: _pickTime,
                                  decoration: _inputDecoration('hh:mm AM/PM')
                                      .copyWith(
                                    suffixIcon: const Icon(
                                        Icons.access_time_rounded,
                                        size: 18),
                                  ),
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
                                _label('Amount (\$)'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  decoration: _inputDecoration('0.00'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Status'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<BookingStatus>(
                                  value: _status,
                                  decoration:
                                      _inputDecoration('Select status'),
                                  items: const [
                                    DropdownMenuItem(
                                      value: BookingStatus.pending,
                                      child: Text('Pending',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    DropdownMenuItem(
                                      value: BookingStatus.confirmed,
                                      child: Text('Confirmed',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    DropdownMenuItem(
                                      value: BookingStatus.completed,
                                      child: Text('Completed',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                    DropdownMenuItem(
                                      value: BookingStatus.cancelled,
                                      child: Text('Cancelled',
                                          style: TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _status = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label('Notes / Additional Details'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _detailsController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                            'Any symptoms, address or special instructions...'),
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
              color: const Color(0xFF2563EB).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_available_rounded,
                color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Booking',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('Fill in the details below',
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
            label: const Text('Save Booking'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required Color color,
    required BookingType value,
  }) {
    final selected = _type == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() {
        _type = value;
        _selectedDoctor = null;
        _selectedAmbulance = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
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