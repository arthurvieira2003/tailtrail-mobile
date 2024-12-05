class LocationPoint {
  final double latitude;
  final double longitude;

  LocationPoint({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class LocationBatch {
  final List<LocationPoint> locations;
  final DateTime timestamp;

  LocationBatch({
    required this.locations,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }
}
