import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  // Replace with your actual model name and configurations
  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-pro-preview-0409',
  );

  /// 1. The Oracle Agent: Predicts congestion 10 minutes ahead.
  /// This is the "Higher Quality Intent" core of the app.
  Future<String> getOraclePrediction(Map<String, dynamic> stadiumData, String matchTimeline) async {
    final prompt = [
      Content.text('''
        You are the Oracle of FlowMind AI. 
        Context:
        - Stadium Telemetry: ${stadiumData.toString()}
        - Match Timeline Point: $matchTimeline
        
        Analyze incoming user flow velocity and predict congestion hotspots in the next 10 minutes. 
        Focus on:
        - Halftime spikes (users moving to concessions).
        - Goal-triggered bursts.
        - Match end exit surges.
        
        Return a specific, data-driven forecast (e.g., 'Gate 3 will be overcrowded in 8 minutes').
        Return the forecast in plain text for the user display.
      ''')
    ];

    try {
      final response = await model.generateContent(prompt);
      return response.text ?? 'Steady flow predicted.';
    } catch (e) {
      return 'Predicting future crowd patterns...';
    }
  }

  /// 2. The Pathmaker Agent: Calculates non-obvious routes.
  Future<String> getOptimalRoute(String destination, String predictedHotspots) async {
    final prompt = [
      Content.text('''
        You are the Pathmaker (Routing Agent).
        Destination: $destination
        Future Congestion Predictions: $predictedHotspots
        
        Using the T+10 congestion forecasts, identify the path with the lowest cumulative density. 
        Do not prioritize the shortest path. Prioritize "Flow Velocity".
        Return a clear routing suggestion (e.g., 'Take Level 2 corridor to avoid predicted surge at Gate B').
      ''')
    ];

    try {
      final response = await model.generateContent(prompt);
      return response.text ?? 'Calculating optimal flow route...';
    } catch (e) {
      return 'Recalculating routes based on flow...';
    }
  }

  /// 3. The Concierge Agent: Proactive personal nudges.
  Future<String> getConciergeNudge(String userId, String userDestination, String oracleInsight) async {
    final prompt = [
      Content.text('''
        You are the Concierge Agent for FlowMind.
        Current Destination Goal: $userDestination
        AI Intelligence (The Oracle): $oracleInsight
        
        Deliver a "Smart Card" nudge that is innovative and friction-less.
        Nudge Examples: 
        - "Leave now to avoid 12 min wait."
        - "Wait 5 mins. Halftime crowd will clear Concession B."
        
        Tone: Premium, expert, helpful. Be very concise.
      ''')
    ];

    try {
      final response = await model.generateContent(prompt);
      return response.text ?? '';
    } catch (e) {
      return '';
    }
  }
}
