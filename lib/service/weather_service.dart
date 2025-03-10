import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'http://146.190.89.97:8989';
  String? _token;

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loginApi'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'AISITS-Mobile/1.0',
        },
        body: {
          'email': 'admin@rams.co.id',
          'password': 'labRams200!!',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  Future<WeatherData> getWeatherData() async {
    try {
      if (_token == null) {
        await login();
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/getDataCuacaJson'),
        headers: {
          'Authorization': 'Bearer $_token',
          'User-Agent': 'AISITS-Mobile/1.0',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 401) {
        _token = null;
        await login();
        return getWeatherData();
      } else {
        throw Exception('Weather data fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Weather data error: $e');
    }
  }
}