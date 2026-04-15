import 'package:flutter_riverpod/flutter_riverpod.dart';

final queueServiceProvider = Provider((ref) => QueueService());

class QueueSlot {
  final String locationId;
  final DateTime slotTime;
  final String queueToken;

  QueueSlot({
    required this.locationId,
    required this.slotTime,
    required this.queueToken,
  });
}

class QueueService {
  /// Simulates joining a virtual queue.
  /// In production, this would hit a Cloud Function that manages slots.
  Future<QueueSlot> joinQueue(String locationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return QueueSlot(
      locationId: locationId,
      slotTime: DateTime.now().add(const Duration(minutes: 15)),
      queueToken: 'FLW-${locationId.substring(0,2).toUpperCase()}-${DateTime.now().millisecond}',
    );
  }

  /// Calculates the best slot based on Oracle's prediction.
  DateTime suggestBestSlot(double predictedDensity) {
    if (predictedDensity > 0.8) {
      return DateTime.now().add(const Duration(minutes: 20)); // Delay movement
    } else {
      return DateTime.now().add(const Duration(minutes: 5)); // Move soon
    }
  }
}
