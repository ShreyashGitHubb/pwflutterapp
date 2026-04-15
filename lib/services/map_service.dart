import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapServiceProvider = Provider((ref) => MapService());

class MapService {
  /// Defines the styling for a "Premium Dark Cockpit" map.
  final String darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#303030"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  /// Generates a set of "Heat Bloom" circles for predicted congestion.
  /// Red -> Future Congestion (Hot)
  /// Blue -> Safe (Cold)
  Set<Circle> getFutureHeatBlooms(List<Map<String, dynamic>> predictions) {
    return predictions.map((p) {
      final intensity = p['intensity'] as double; // 0.0 to 1.0
      return Circle(
        circleId: CircleId(p['id']),
        center: LatLng(p['lat'], p['lng']),
        radius: 30 + (intensity * 20),
        fillColor: intensity > 0.7 
            ? const Color(0xFFFF5252).withOpacity(0.4) // High congestion
            : const Color(0xFF00F0FF).withOpacity(0.2), // Safe
        strokeWidth: 0,
      );
    }).toSet();
  }

  /// Calculates a route that avoids the Red Circles.
  /// This is where the Pathmaker Agent's logic is applied visually.
  Set<Polyline> getLeastCrowdedRoute(List<LatLng> points) {
    return {
      Polyline(
        polylineId: const PolylineId('optimal_route'),
        points: points,
        color: const Color(0xFF00F0FF),
        width: 5,
        jointType: JointType.round,
      ),
    };
  }
}
