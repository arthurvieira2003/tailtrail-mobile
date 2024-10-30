import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import 'dart:async';

class LocationService {
  Timer? _timer;
  StreamController<LocationModel>? _controller;

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

  Stream<LocationModel> getLocationStream() {
    _controller = StreamController<LocationModel>();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (_controller?.isClosed == false) {
          _controller?.add(LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          ));
        }
      } catch (e) {
        _controller?.addError(e);
      }
    });

    _controller?.onCancel = () {
      _timer?.cancel();
      _controller?.close();
    };

    return _controller!.stream;
  }
}
