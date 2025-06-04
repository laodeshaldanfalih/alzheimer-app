
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  final String? id; // Document ID dari Firestore
  final Timestamp timestamp;
  final double heartRate;
  final double respiratoryRate; // Still in model
  final double temperature;     // Still in model
  final int systolic;
  final int diastolic;
  final double weight;
  final double height;
  final double waistCircumference;
  final double? bloodSugar; // BARU
  final String? symptoms;    // BARU

  HealthData({
    this.id,
    required this.timestamp,
    required this.heartRate,
    required this.respiratoryRate,
    required this.temperature,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.height,
    required this.waistCircumference,
    this.bloodSugar, // Opsional
    this.symptoms,   // Opsional
  });

  factory HealthData.fromMap(String id, Map<String, dynamic> map) {
    return HealthData(
      id: id,
      timestamp: map['timestamp'] as Timestamp,
      heartRate: (map['heartRate'] as num).toDouble(),
      respiratoryRate: (map['respiratoryRate'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      systolic: (map['systolic'] as num).toInt(),
      diastolic: (map['diastolic'] as num).toInt(),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      waistCircumference: (map['waistCircumference'] as num).toDouble(),
      bloodSugar: (map['bloodSugar'] as num?)?.toDouble(), // BARU
      symptoms: map['symptoms'] as String?,                // BARU
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'temperature': temperature,
      'systolic': systolic,
      'diastolic': diastolic,
      'weight': weight,
      'height': height,
      'waistCircumference': waistCircumference,
      'bloodSugar': bloodSugar, // BARU
      'symptoms': symptoms,     // BARU
    };
  }
}