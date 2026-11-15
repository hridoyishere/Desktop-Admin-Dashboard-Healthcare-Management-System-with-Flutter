

enum BookingType { doctor, ambulance }

enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final BookingType type;
  final String patientName;
  final String details; // doctor name or ambulance id
  final String date;
  final String time;
  final BookingStatus status;
  final double amount;

  Booking({
    required this.id,
    required this.type,
    required this.patientName,
    required this.details,
    required this.date,
    required this.time,
    required this.status,
    required this.amount,
  });
}