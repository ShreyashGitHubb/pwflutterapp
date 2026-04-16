import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import 'simulation_service.dart';
import 'queue_service.dart';
import '../models/congestion_forecast.dart';

final intelligenceHubProvider = StateNotifierProvider<IntelligenceHub, IntelligenceState>((ref) {
  return IntelligenceHub(
    ref.watch(aiServiceProvider),
    ref.watch(simulationServiceProvider),
    ref.watch(queueServiceProvider),
  );
});

class IntelligenceState {
  final List<CongestionForecast> forecasts;
  final String currentInsight;
  final String matchTimeline;
  final String activeNudge;
  final bool autoPilotEnabled;
  final QueueSlot? activeQueueSlot;

  IntelligenceState({
    required this.forecasts,
    required this.currentInsight,
    required this.matchTimeline,
    required this.activeNudge,
    required this.autoPilotEnabled,
    this.activeQueueSlot,
  });

  IntelligenceState copyWith({
    List<CongestionForecast>? forecasts,
    String? currentInsight,
    String? matchTimeline,
    String? activeNudge,
    bool? autoPilotEnabled,
    Object? activeQueueSlot = _sentinel,
  }) {
    return IntelligenceState(
      forecasts: forecasts ?? this.forecasts,
      currentInsight: currentInsight ?? this.currentInsight,
      matchTimeline: matchTimeline ?? this.matchTimeline,
      activeNudge: activeNudge ?? this.activeNudge,
      autoPilotEnabled: autoPilotEnabled ?? this.autoPilotEnabled,
      activeQueueSlot: activeQueueSlot == _sentinel ? this.activeQueueSlot : (activeQueueSlot as QueueSlot?),
    );
  }

  static const _sentinel = Object();
}

class IntelligenceHub extends StateNotifier<IntelligenceState> {
  final AIService _ai;
  final SimulationService _sim;
  final QueueService _queue;

  IntelligenceHub(this._ai, this._sim, this._queue) 
    : super(IntelligenceState(
        forecasts: [], 
        currentInsight: 'Synchronizing with Stadium Pulse...', 
        matchTimeline: 'PRE-MATCH',
        activeNudge: '',
        autoPilotEnabled: false,
      )) {
    _init();
  }

  void _init() {
    _sim.getSimulationStream().listen((data) async {
      state = state.copyWith(forecasts: data);
      
      final insight = await _ai.getOraclePrediction(
        {'gates': data.map((e) => e.locationName).toList()}, 
        state.matchTimeline
      );
      
      state = state.copyWith(currentInsight: insight);
      
      // Auto-Pilot Logic: If enabled, automatically handle future hotspots
      if (state.autoPilotEnabled && data.any((f) => f.isHotspot)) {
        final hotspot = data.firstWhere((f) => f.isHotspot);
        if (state.activeQueueSlot == null) {
          _autoJoinQueue(hotspot.locationId);
        }
      }

      // Concierge Nudge logic
      if (data.any((f) => f.isHotspot)) {
        final nudge = await _ai.getConciergeNudge(
          'user_alpha', 
          'Main Concourse', 
          insight
        );
        state = state.copyWith(activeNudge: nudge);
      }
    });

    _sim.getMatchEvents().listen((event) {
      state = state.copyWith(matchTimeline: event);
    });
  }

  void toggleAutoPilot() {
    state = state.copyWith(autoPilotEnabled: !state.autoPilotEnabled);
    if (state.autoPilotEnabled) {
      state = state.copyWith(activeNudge: 'Auto-Pilot Active: Optimizing your movement windows.');
    }
  }

  Future<void> joinQueueManual(String locationId) async {
    final slot = await _queue.joinQueue(locationId);
    state = state.copyWith(activeQueueSlot: slot);
  }

  Future<void> _autoJoinQueue(String locationId) async {
    final slot = await _queue.joinQueue(locationId);
    state = state.copyWith(
      activeQueueSlot: slot,
      activeNudge: 'Auto-Pilot: Virtually joined queue for $locationId. Slot: ${slot.slotTime.hour}:${slot.slotTime.minute}',
    );
  }

  void clearNudge() {
    state = state.copyWith(activeNudge: '');
  }
}
