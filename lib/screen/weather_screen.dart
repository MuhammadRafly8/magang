import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import '../service/weather_service.dart';
import '../screen/map_screen.dart';  
import 'package:provider/provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final WeatherService _weatherService;
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weatherService = Provider.of<WeatherService>(context, listen: false);
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final data = await _weatherService.getWeatherData();
      if (!mounted) return;
      
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = 'Error fetching weather data: ${e.toString()}';
        _isLoading = false;
        _weatherData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        },
        child: const Icon(Icons.map),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeatherData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(child: Text('No weather data available'));
    }

    return RefreshIndicator(
      onRefresh: _fetchWeatherData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weatherData!.location,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${_weatherData!.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'Updated: ${_weatherData!.timestamp.toString().substring(0, 19)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.water_drop, 'Humidity', 
              '${_weatherData!.humidity.toStringAsFixed(1)}%'),
            const Divider(),
            _buildDetailRow(Icons.air, 'Wind Speed', 
              '${_weatherData!.windSpeed.toStringAsFixed(1)} km/h'),
            const Divider(),
            _buildDetailRow(Icons.compass_calibration, 'Wind Direction', 
              _weatherData!.windDirection),
            const Divider(),
            _buildDetailRow(Icons.compress, 'Pressure', 
              '${_weatherData!.pressure.toStringAsFixed(1)} hPa'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}