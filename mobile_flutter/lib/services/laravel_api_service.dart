import 'dart:convert';
import 'package:dio/dio.dart';

class LaravelApiService {
  final Dio _dio = Dio();
  // Assume Laravel is running locally for now
  final String baseUrl = 'http://127.0.0.1:8001/api'; 
  
  // Real implementation will fetch from Laravel API
  // Here we mock the response for demonstration
  // Real implementation fetching from Laravel API
  Future<Map<String, dynamic>> fetchSensorData() async {
    try {
      final response = await _dio.get('$baseUrl/pineapple/latest');
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'weight': double.tryParse(data['weight'].toString()) ?? 0.0,
          'voc': double.tryParse(data['gas_value'].toString()) ?? 0.0,
          'temperature': double.tryParse(data['temperature'].toString()) ?? 0.0,
          'humidity': 68.0, // Backend might not have humidity in log yet
          'ai_status': data['status'] ?? 'UNKNOWN',
          'confidence_score': double.tryParse(data['confidence_score'].toString()) ?? 0.0,
        };
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
    
    // Fallback if error
    return {
      'weight': 1.28 + (0.05 * (DateTime.now().second % 5)),
      'voc': 42.0 + (DateTime.now().second % 10),
      'temperature': 24.2 + (0.1 * (DateTime.now().second % 3)),
      'humidity': 68.0 + (1.0 * (DateTime.now().second % 4)),
    };
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      final response = await _dio.get('$baseUrl/pineapple/history');
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data;
        return dataList.map((data) => {
          'grade': data['status'] == 'RIPE' ? 'Grade A' : (data['status'] == 'RAW' ? 'Grade B' : 'Reject'),
          'status_raw': data['status'],
          'time': data['created_at'] ?? 'Just now',
          'confidence_score': double.tryParse(data['confidence_score'].toString()) ?? 0.0,
        }).toList();
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> triggerScan() async {
    // 1. Flutter says "loading"
    // 2. Flutter sends request to Laravel.
    // 3. Laravel commands ESP32 to take photo.
    // 4. Laravel sends photo to Python ViT AI.
    // 5. Python returns AI result to Laravel.
    // 6. Laravel saves to DB and returns to Flutter.
    
    // Simulating this entire complex workflow latency
    await Future.delayed(const Duration(seconds: 3)); 
    
    return {
      'status': 'success',
      'ai_status': 'Grade A Target / Ripe',
      'confidence_score': 98.4,
      'grade': 'Grade A',
      'weight': '1.28kg'
    };
  }
}
