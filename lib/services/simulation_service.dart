import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/congestion_forecast.dart';

final simulationServiceProvider = Provider((ref) => SimulationService());

class SimulationService {
  final _random = Random();

  /// Simulates a stream of congestion forecasts.
  /// In a real app, this would come from a combination of Firebase and The Oracle Agent.
  Stream<List<CongestionForecast>> getSimulationStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      
      yield [
        CongestionForecast.mock(
          'Gate 3 (East)', 
          0.3 + _random.nextDouble() * 0.2, 
          0.7 + _random.nextDouble() * 0.3, // Predicted spike
        ),
        CongestionForecast.mock(
          'Gate 1 (West)', 
          0.1 + _random.nextDouble() * 0.1, 
          0.1 + _random.nextDouble() * 0.1, // Clear
        ),
        CongestionForecast.mock(
          'Stadium Bar B', 
          0.4 + _random.nextDouble() * 0.3, 
          0.9, // Near capacity
        ),
        CongestionForecast.mock(
          'Exit Tunnel 4', 
          0.0, 
          0.2, 
        ),
      ];
    }
  }

  /// Simulates real-time match events that trigger AI reasoning.
  Stream<String> getMatchEvents() async* {
    final events = [
      'Match Start',
      'Goal Scored (Home Team)',
      '10 Minutes to Halftime',
      'Halftime Start',
      'Second Half Kickoff',
      '80th Minute - Early Exits starting',
      'Full Time',
    ];

    for (var event in events) {
      await Future.delayed(const Duration(seconds: 30));
      yield event;
    }
  }
}
