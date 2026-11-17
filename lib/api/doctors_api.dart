
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class DoctorApi {
  // Flutter Linux Desktop
  static const String baseUrl = 'http://localhost:5000/api';

  // Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000/api';

  Future<Map<String, dynamic>> createDoctor(Employee doctor) async {
    final uri = Uri.parse('$baseUrl/doctors');

    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'name': doctor.name,
      'specialization': doctor.specialization,
      'email': doctor.email,
      'phone': doctor.phone,
      'address': doctor.address,
      'workingHours': doctor.workingHours,
      'rating': doctor.rating.toString(),
      'experience': doctor.experience.toString(),
      'about': doctor.about,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        doctor.imagePath,
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(streamedResponse);

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 && data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Failed to create doctor',
    );
  }
}
