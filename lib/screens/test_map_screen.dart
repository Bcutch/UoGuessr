import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;

class TestMapScreen extends StatefulWidget {
  const TestMapScreen({super.key});

  @override
  State<TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<TestMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(43.53289277070203, -80.22622330298434);
  LatLng _userGuess = LatLng(43.53289277070203, -80.22622330298434);
  LatLng _target = LatLng(43.5335, -80.2255); // New target location
  double? _score;
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("Guess"),
          position: _center,
          draggable: true,
          onDragEnd: _getUserGuess,
        ),
      );
    });
  }

  // Move the marker when user taps on the map
  void _onMapTapped(LatLng position) {
    setState(() {
      _userGuess = position;
      _markers.removeWhere((m) => m.markerId.value == "Guess");
      _markers.add(
        Marker(
          markerId: MarkerId("Guess"),
          position: position,
          draggable: true,
          onDragEnd: _getUserGuess,
        ),
      );
    });
  }

  // Add line from guess to target
  void _showLineFromGuess() {
    setState(() {
      _markers.add(Marker(markerId: MarkerId("Target"), position: _target));
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          visible: true,
          points: [_userGuess, _target],
          width: 5,
          color: Colors.red,
          geodesic: true,
        ),
      );
    });
  }

  // Update user guess
  void _getUserGuess(LatLng position) {
    setState(() {
      _userGuess = position;
    });
  }

  // Calculate distance (in km)
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Calculate the score based on distance
void getDistanceScore() {
  final distanceKm = calculateDistance(
    _userGuess.latitude,
    _userGuess.longitude,
    _target.latitude,
    _target.longitude,
  );

  final distanceMeters = distanceKm * 1000; // Convert to meters

  setState(() {
    if (distanceMeters <= 10) {
      _score = 5000;
    } else if (distanceMeters >= 250) {
      _score = 0;
    } else {
      _score = 5000 * (1 - ((distanceMeters - 10) / 240));
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_score == null ? 'Score: 0' : 'Score: ${_score!.toStringAsFixed(2)}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 17,
                ),
                markers: _markers,
                polylines: _polylines,
                onTap: _onMapTapped, // Allow tapping to place guess
              ),
            ),
            SizedBox(height: 20),
            Text("Guess Location: ${_userGuess.latitude}, ${_userGuess.longitude}"),
            ElevatedButton(onPressed: getDistanceScore, child: Text("Submit Guess")),
            ElevatedButton(
              onPressed: _showLineFromGuess,
              child: Text("Show line to Target"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.keyboard_arrow_down, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
