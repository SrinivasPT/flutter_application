import 'package:flutter/foundation.dart';

class Alert {
  final int id;
  final String title;
  final String imageName;
  final DateTime timestamp;
  final String patientId;
  final String patientName;
  final String patientGender;
  final String patientDateOfBirth;
  final String filePath;

  Alert({
    required this.id,
    required this.title,
    required this.imageName,
    required this.timestamp,
    required this.patientId,
    required this.patientName,
    required this.patientGender,
    required this.patientDateOfBirth,
    required this.filePath,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? 0, // Provide default value if null
      title: json['title'] ?? 'Unknown Alert', // Provide default value if null
      imageName: json['imageName'] ?? 'No Image',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(), // Handle null timestamp
      patientId: json['patientId'] ?? 'Unknown',
      patientName: json['patientName'] ?? 'Unknown Patient',
      patientGender: json['patientGender'] ?? 'Not Specified',
      patientDateOfBirth: json['patientDateOfBirth'] ?? 'Unknown',
      filePath: json['filePath'] ?? '',
    );
  }
}
