import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import '../server/models/game.dart';
import '../server/models/picture.dart';
import '../server/services/game.service.dart';
import 'congratulations_screen.dart';

class GameGuessingFindit extends StatefulWidget {
  const GameGuessingFindit({super.key});

  @override
  State<GameGuessingFindit> createState() => _GameGuessingFinditState();
}

class _GameGuessingFinditState extends State<GameGuessingFindit> {
  final _gameService = GetIt.instance<GameService>();

  bool _isLoading = true;
  bool _isCheckingLocation = false;
  double _totalScore = 0;
  double? _lastScore;
  int _currentIndex = 0;
  Game? _game;
  List<Picture> _pictures = [];
  LatLng? _userLocation;
  GoogleMapController? _mapController;
  String error = "";
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getDailyGame();
  }

  Future<void> _getDailyGame() async {
    try {
      setState(() {
        _isLoading = true;
        error = "";
      });

      final result = await _gameService.getDailyGame();
      setState(() {
        _game = result.game;
        _pictures = result.pictures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Could not get daily game: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double _calculateScore(double distanceMeters) {
    if (distanceMeters <= 10) return 5000;
    if (distanceMeters >= 500) return 0;
    return 5000 * (1 - ((distanceMeters - 10) / 490));
  }

  Future<void> _checkUserLocation() async {
    setState(() {
      _isCheckingLocation = true;
      error = "";
    });

    try {
      await _checkPermissions();

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      double distanceKm = _calculateDistanceKm(
        position.latitude,
        position.longitude,
        _pictures[_currentIndex].latitude,
        _pictures[_currentIndex].longitude,
      );

      double distanceMeters = distanceKm * 1000;
      double score = _calculateScore(distanceMeters);

      final userLatLng = LatLng(position.latitude, position.longitude);
      final targetLatLng = LatLng(
        _pictures[_currentIndex].latitude,
        _pictures[_currentIndex].longitude,
      );

      setState(() {
        _userLocation = userLatLng;
        _lastScore = score;
        _totalScore += score;
        _markers = {
          Marker(
            markerId: const MarkerId("UserLocation"),
            position: userLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
          Marker(
            markerId: const MarkerId("TargetLocation"),
            position: targetLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
        _polylines = {
          Polyline(
            polylineId: const PolylineId("line"),
            color: Colors.red,
            width: 5,
            points: [userLatLng, targetLatLng],
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              userLatLng.latitude < targetLatLng.latitude
                  ? userLatLng.latitude
                  : targetLatLng.latitude,
              userLatLng.longitude < targetLatLng.longitude
                  ? userLatLng.longitude
                  : targetLatLng.longitude,
            ),
            northeast: LatLng(
              userLatLng.latitude > targetLatLng.latitude
                  ? userLatLng.latitude
                  : targetLatLng.latitude,
              userLatLng.longitude > targetLatLng.longitude
                  ? userLatLng.longitude
                  : targetLatLng.longitude,
            ),
          ),
          80,
        ),
      );
    } catch (e) {
      setState(() {
        error = "Error checking location: $e";
      });
    } finally {
      setState(() {
        _isCheckingLocation = false;
      });
    }
  }

  void _nextPicture() {
    if (_currentIndex < _pictures.length - 1) {
      setState(() {
        _currentIndex++;
        _userLocation = null;
        _lastScore = null;
        _markers.clear();
        _polylines.clear();
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CongratulationsScreen(totalScore: _totalScore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetLatLng =
        _pictures.isNotEmpty
            ? LatLng(
              _pictures[_currentIndex].latitude,
              _pictures[_currentIndex].longitude,
            )
            : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Findit Mode"),
        backgroundColor: Color.fromARGB(255, 194, 4, 48),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Score: ${_totalScore.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pictures.isEmpty
              ? const Center(child: Text('No pictures available.'))
              : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        _pictures[_currentIndex].storageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (_userLocation != null)
                    Expanded(
                      flex: 2,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _userLocation!,
                          zoom: 16,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated:
                            (controller) => _mapController = controller,
                      ),
                    ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_lastScore != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "You earned ${_lastScore!.toStringAsFixed(0)} points!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _isCheckingLocation ? null : _checkUserLocation,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Color.fromARGB(255, 255, 199, 42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child:
                              _isCheckingLocation
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text("I'm here! Check my location"),
                        ),
                        if (_lastScore != null)
                          ElevatedButton(
                            onPressed: _nextPicture,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Color.fromARGB(255, 255, 199, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text("Next"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
