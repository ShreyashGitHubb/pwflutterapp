import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/intelligence_hub.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(intelligenceHubProvider);
    final hub = ref.read(intelligenceHubProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, state.matchTimeline),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAutoPilotToggle(context, state, hub),
                  const SizedBox(height: 16),
                  if (state.activeNudge.isNotEmpty) ...[
                    _buildNudgeCard(context, ref, state.activeNudge),
                    const SizedBox(height: 24),
                  ],
                  if (state.activeQueueSlot != null) ...[
                    _buildQueueCard(context, state.activeQueueSlot!),
                    const SizedBox(height: 24),
                  ],
                  _buildPulseCard(context, state),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Future Hotspots',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Chip(
                        label: Text('T + 10m', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: Color(0xFF00F0FF),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInsightList(state.forecasts, hub),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPilotToggle(BuildContext context, IntelligenceState state, IntelligenceHub hub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: state.autoPilotEnabled ? const Color(0xFF00F0FF).withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: state.autoPilotEnabled ? const Color(0xFF00F0FF) : Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: state.autoPilotEnabled ? const Color(0xFF00F0FF) : Colors.white38),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI AUTO-PILOT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    state.autoPilotEnabled ? 'Crowd Management Active' : 'Manual Navigation',
                    style: TextStyle(fontSize: 10, color: state.autoPilotEnabled ? const Color(0xFF00F0FF) : Colors.white38),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: state.autoPilotEnabled,
            onChanged: (val) => hub.toggleAutoPilot(),
            activeColor: const Color(0xFF00F0FF),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context, dynamic slot) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('INVISIBLE QUEUE SLOT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Location: ${slot.locationId.toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Validated for: ${DateFormat('jm').format(slot.slotTime)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              'TOKEN: ${slot.queueToken}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, family: 'Courier'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String timeline) {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stadium Pulse',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            Text(
              timeline,
              style: const TextStyle(fontSize: 12, color: Color(0xFF00F0FF), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNudgeCard(BuildContext context, WidgetRef ref, String nudge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nudge,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(intelligenceHubProvider.notifier).clearNudge(),
            icon: const Icon(Icons.close, color: Colors.black),
          )
        ],
      ),
    );
  }

  Widget _buildPulseCard(BuildContext context, IntelligenceState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171F33),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORACLE INSIGHT', style: TextStyle(color: Color(0xFF00F0FF), letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            state.currentInsight,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('LIVE FLOW', 'OPTIMAL', Colors.greenAccent),
              _buildMiniMetric('NEXT WAVE', '8 MINS', const Color(0xFF00F0FF)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildInsightList(List forecasts, IntelligenceHub hub) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: forecasts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final f = forecasts[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF171F33).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: f.predictedDensity,
                  backgroundColor: Colors.white10,
                  color: f.isHotspot ? Colors.redAccent : const Color(0xFF00F0FF),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.locationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Predicted Density: ${(f.predictedDensity * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              if (f.isHotspot)
                TextButton(
                  onPressed: () => hub.joinQueueManual(f.locationId),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('JOIN QUEUE', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
}
