import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import 'dart:async';

class LocationService {
  Timer? _timer;
  StreamController<LocationBatch>? _controller;
  List<LocationPoint> _locationBuffer = [];

  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    return true;
  }

  Stream<LocationBatch> getLocationStream() {
    _controller = StreamController<LocationBatch>();
    _locationBuffer = [];

    _timer = Timer.periodic(const Duration(seconds: 6), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        _locationBuffer.add(LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ));

        if (_locationBuffer.length >= 5 && _controller?.isClosed == false) {
          _controller?.add(LocationBatch(
            locations: List.from(_locationBuffer),
            timestamp: DateTime.now(),
          ));
          _locationBuffer.clear();
        }
      } catch (e) {
        _controller?.addError(e);
      }
    });

    _controller?.onCancel = () {
      _timer?.cancel();
      _controller?.close();
      _locationBuffer.clear();
    };

    return _controller!.stream;
  }
}
