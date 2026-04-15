import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/map_service.dart';
import '../services/intelligence_hub.dart';
import 'dart:ui';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController _controller;
  bool _showFuture = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 17,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(intelligenceHubProvider);
    final mapService = ref.watch(mapServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _controller = controller;
              _controller.setMapStyle(mapService.darkMapStyle);
            },
            circles: _showFuture 
                ? mapService.getFutureHeatBlooms(
                    state.forecasts.map((f) => {
                      'id': f.locationId,
                      'lat': 37.775 + (state.forecasts.indexOf(f) * 0.0005), // Mock spread
                      'lng': -122.419,
                      'intensity': f.predictedDensity,
                    }).toList(),
                  )
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          _buildMapControls(),
          if (state.activeNudge.isNotEmpty) _buildGlassHUD(state.activeNudge),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF171F33).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleBtn('Live Flow', !_showFuture),
                  _buildToggleBtn('10m Forecast', _showFuture),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showFuture = label.contains('Forecast')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00F0FF).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF00F0FF) : Colors.white60,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHUD(String nudge) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00F0FF).withOpacity(0.3),
                  const Color(0xFF00F0FF).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'AUTO-PILOT ADVISORY',
                        style: TextStyle(
                          color: Color(0xFF00F0FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nudge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => ref.read(intelligenceHubProvider.notifier).clearNudge(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
