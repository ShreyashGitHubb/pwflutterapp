import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/intelligence_hub.dart';
import '../models/congestion_forecast.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intel = ref.watch(intelligenceHubProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(intel),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(intel),
                  const SizedBox(height: 32),
                  _buildSectionHeader('PREDICTIVE PULSE', 'T+10m Live Forecast'),
                  const SizedBox(height: 16),
                  _buildForecastList(intel.forecasts),
                  const SizedBox(height: 32),
                  _buildSectionHeader('INVISIBLE QUEUE', 'Virtual Slot Management'),
                  const SizedBox(height: 16),
                  _buildQueueStatus(intel),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(IntelligenceHubState intel) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E12),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF0A0E12)],
                ),
              ),
            ),
            _buildHeatBloomBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FLOWMIND AI', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Text(intel.simulation.currentEvent, style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatBloomBackground() {
    return Container(
      decoration: BoxDecoration(
        radialGradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            const Color(0xFF00F0FF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(IntelligenceHubState intel) {
    return Row(
      children: [
        _buildStatCard('LIVE LOAD', '${intel.simulation.occupancy}%', Colors.blueAccent),
        const SizedBox(width: 16),
        _buildStatCard('FLOW RATE', '${intel.simulation.flowRate} p/m', Colors.cyanAccent),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        Text(subtitle, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildForecastList(List<CongestionForecast> forecasts) {
    return Column(
      children: forecasts.map((f) => _buildForecastItem(f)).toList(),
    );
  }

  Widget _buildForecastItem(CongestionForecast forecast) {
    final bool isHigh = forecast.riskLevel == 'CRITICAL';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isHigh ? Colors.redAccent : Colors.greenAccent).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isHigh ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: isHigh ? Colors.redAccent : Colors.greenAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(forecast.locationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(forecast.predictionReason, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${forecast.predictedOccupancy}%', style: TextStyle(color: isHigh ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('IN 10M', style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatus(IntelligenceHubState intel) {
    final slot = intel.activeQueueSlot;
    if (slot == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24)),
        child: const Center(child: Text('No active virtual queues', style: TextStyle(color: Colors.white24))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.1), Colors.blue.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slot.serviceId.toUpperCase(), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  const Text('Reserved Spot', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const Icon(Icons.qr_code_2, color: Colors.white, size: 40),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'PLEASE ARRIVE IN ${slot.estimatedWaitTime} MINS',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              'TOKEN: ${slot.queueToken}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
            ),
          )
        ],
      ),
    );
  }
}
