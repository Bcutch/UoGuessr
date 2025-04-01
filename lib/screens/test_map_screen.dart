import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:uoguesser/server/services/game_instance.service.dart';
import 'package:get_it/get_it.dart';

class TestMapScreen extends StatefulWidget {
  final double targetLat;
  final double targetLng;
  final Function(int) onScoreUpdate;
  final VoidCallback onNextPicture;
  final bool isLastImage; // New parameter to track if it's the last image
  final String instanceId;
  final String pictureId;

  const TestMapScreen({
    super.key,
    required this.targetLat,
    required this.targetLng,
    required this.onScoreUpdate,
    required this.onNextPicture,
    required this.isLastImage,
    required this.instanceId,
    required this.pictureId,
  });

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  late GoogleMapController mapController;
  LatLng _userGuess = const LatLng(43.53289277070203, -80.22622330298434);
  int? _score;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isScoreCalculated = false;
  final _gameInstanceService = GetIt.instance<GameInstanceService>();

  LatLng get _target => LatLng(widget.targetLat, widget.targetLng);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _userGuess = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("Guess"),
          position: position,
          draggable: true,
          onDragEnd: (pos) => _userGuess = pos,
        ),
      );
    });
  }

  void _showLineFromGuess() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          visible: true,
          points: [_userGuess, _target],
          width: 5,
          color: Colors.red,
          geodesic: true,
        ),
      );
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void getDistanceScore() {
    _showLineFromGuess();
    final distanceKm = calculateDistance(
      _userGuess.latitude,
      _userGuess.longitude,
      _target.latitude,
      _target.longitude,
    );

    final distanceMeters = distanceKm * 1000; // Convert to meters

    setState(() {
      const maxScore = 5000;
      const minScore = 0;
      const maxDistance = 20000.0; // 20km

      if (distanceMeters >= maxDistance) {
        _score = minScore;
      } else {
        _score = (maxScore * (1 - distanceMeters / maxDistance)).round();
      }
      _isScoreCalculated = true;
    });

    widget.onScoreUpdate(_score!);
    if (widget.instanceId.isNotEmpty) {
      _submitGuess(_userGuess.latitude, _userGuess.longitude, distanceMeters);
    }
  }

  Future<void> _submitGuess(double latitude, double longitude, double distanceMeters) async {
    await _gameInstanceService.submitGuess(
      widget.instanceId,
      widget.pictureId,
      latitude,
      longitude,
      distanceMeters
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _score == null ? 'Score: 0' : 'Score: ${_score!.toStringAsFixed(2)}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _target, zoom: 17),
              markers: _markers,
              polylines: _polylines,
              onTap: _onMapTapped,
            ),
          ),
          ElevatedButton(
            onPressed:
                _isScoreCalculated ? widget.onNextPicture : getDistanceScore,
            child: Text(
              _isScoreCalculated
                  ? (widget.isLastImage ? "Finish Game" : "Show Next Picture")
                  : "Submit Guess",
            ),
          ),
        ],
      ),
    );
  }
}
