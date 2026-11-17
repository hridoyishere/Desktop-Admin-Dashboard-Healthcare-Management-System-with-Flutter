
enum EmployeeRole {
  doctor,
  nurse,
  technician,
  admin,
  driver,
}

class Employee {
  final String? id;
  final String name;
  final EmployeeRole role;
  final String department;
  final String specialization;
  final String phone;
  final String email;
  final bool isActive;
  final String address;
  final String workingHours;
  final double rating;
  final String about;
  final int experience;
  final String imagePath;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.specialization,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.address,
    required this.workingHours,
    required this.rating,
    required this.about,
    required this.experience,
    required this.imagePath,
  });
}
