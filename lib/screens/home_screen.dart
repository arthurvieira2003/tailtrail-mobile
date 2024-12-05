import 'package:flutter/material.dart';
import 'dart:async';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../models/location_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();
  bool _isTracking = false;
  StreamSubscription<LocationBatch>? _locationSubscription;
  LocationPoint? _lastLocation;
  String? _error;
  DateTime? _lastUpdateTime;

  void _toggleTracking() async {
    setState(() {
      _error = null;
    });

    if (!_isTracking) {
      final hasPermission = await _locationService.checkPermissions();
      if (!hasPermission) {
        setState(() {
          _error = 'Permissão de localização negada';
        });
        return;
      }
    }

    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _startTracking();
      } else {
        _stopTracking();
      }
    });
  }

  void _startTracking() {
    _locationSubscription =
        _locationService.getLocationStream().listen((locationBatch) async {
      setState(() {
        _lastLocation = locationBatch.locations.last;
        _lastUpdateTime = locationBatch.timestamp;
      });
      try {
        await _apiService.sendLocationBatch(locationBatch);
      } catch (e) {
        setState(() {
          _error = 'Erro ao enviar localização: $e';
        });
      }
    });
  }

  void _stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tail Trail'),
        elevation: 2,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            if (_lastLocation != null) _buildLocationInfo(),
            const SizedBox(height: 24),
            _buildTrackingButton(),
            if (_error != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isTracking ? Icons.gps_fixed : Icons.gps_off,
              size: 48,
              color: _isTracking ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isTracking ? 'Rastreamento Ativo' : 'Rastreamento Inativo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _isTracking
                        ? 'Enviando sua localização...'
                        : 'Clique para iniciar o rastreamento',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última Localização',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Latitude: ${_lastLocation?.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${_lastLocation?.longitude.toStringAsFixed(6)}'),
            Text('Atualizado em: ${_lastUpdateTime?.toLocal()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingButton() {
    return ElevatedButton.icon(
      onPressed: _toggleTracking,
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      label: Text(_isTracking ? 'Parar Rastreamento' : 'Iniciar Rastreamento'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        _error!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}
