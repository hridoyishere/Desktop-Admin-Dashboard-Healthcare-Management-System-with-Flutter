enum EmployeeRole { doctor, nurse, technician, admin, driver }

class Employee {
  final String id;
  final String name;
  final EmployeeRole role;
  final String department;
  final String specialization;
  final String phone;
  final String email;
  final bool isActive;
  final int experience;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.specialization,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.experience,
  });
}