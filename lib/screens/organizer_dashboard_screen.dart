import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/intelligence_hub.dart';

class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(intelligenceHubProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentinel Command Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStatus(context, state),
            const SizedBox(height: 32),
            Text('SENTINEL SUGGESTIONS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF00F0FF), letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildDeploymentSuggerstions(state),
            const SizedBox(height: 32),
            Text('PREDICTED LOAD (T+10m)', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildLoadChart(state),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatus(BuildContext context, IntelligenceState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Total Fans', '42.8k', Icons.groups),
          _buildStat('At Capacity', '2/12', Icons.door_front_door, color: Colors.orangeAccent),
          _buildStat('Safety Flow', 'Optimal', Icons.shield_outlined, color: Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, {Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.5), size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    );
  }

  Widget _buildDeploymentSuggerstions(IntelligenceState state) {
    // Simulated Sentinel logic
    final hotspots = state.forecasts.where((f) => f.isHotspot).toList();
    
    if (hotspots.isEmpty) {
      return const Card(
        color: Color(0xFF171F33),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No critical hotspots predicted. Staff positions maintained.', style: TextStyle(color: Colors.white60)),
        ),
      );
    }

    return Column(
      children: hotspots.map((h) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.move_up, color: Colors.redAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reassign to ${h.locationName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Predicted 90% load in 8m. Suggest moving 4 staff from North Gate.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('DEPLOY', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLoadChart(IntelligenceState state) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: state.forecasts.map((f) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 20,
                height: 140 * f.predictedDensity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      f.isHotspot ? Colors.redAccent : const Color(0xFF00F0FF),
                      f.isHotspot ? Colors.redAccent.withOpacity(0.3) : const Color(0xFF00F0FF).withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(f.locationId.substring(0, min(3, f.locationId.length)).toUpperCase(), style: const TextStyle(fontSize: 8, color: Colors.white38)),
            ],
          );
        }).toList(),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
