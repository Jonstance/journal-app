import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherSnapshot {
  WeatherSnapshot({required this.summary, required this.temperature});

  final String summary;
  final String temperature;
}

abstract class WeatherService {
  Future<WeatherSnapshot?> fetchCurrentWeather();
}

class StubWeatherService implements WeatherService {
  @override
  Future<WeatherSnapshot?> fetchCurrentWeather() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return null;
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return StubWeatherService();
});
