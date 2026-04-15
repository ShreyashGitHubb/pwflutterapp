class CongestionForecast {
  final String locationId;
  final String locationName;
  final double currentDensity; // 0.0 - 1.0
  final double predictedDensity; // forecast for T+10
  final DateTime timestamp;

  CongestionForecast({
    required this.locationId,
    required this.locationName,
    required this.currentDensity,
    required this.predictedDensity,
    required this.timestamp,
  });

  bool get isHotspot => predictedDensity > 0.7;
  bool get isIncreasing => predictedDensity > currentDensity;

  factory CongestionForecast.mock(String name, double curr, double pred) {
    return CongestionForecast(
      locationId: name.toLowerCase().replaceAll(' ', '_'),
      locationName: name,
      currentDensity: curr,
      predictedDensity: pred,
      timestamp: DateTime.now(),
    );
  }
}
