import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/player.provider.dart';
import '../server/services/picture.service.dart';

class TestUploadScreen extends StatefulWidget {
  const TestUploadScreen({Key? key}) : super(key: key);

  @override
  _TestUploadScreenState createState() => _TestUploadScreenState();
}

class _TestUploadScreenState extends State<TestUploadScreen> {
  final pictureService = GetIt.instance<PictureService>();
  String playerName = "TestName"; 
  LatLng? location;
  File? pictureFile;
  bool isTaken = false;
  bool isNull = false;
  String error = "";

  Future<PlayerProvider> getPlayer() async {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentPlayer == null) {
      throw Exception('You must be logged in to use this feature!');
    }
    return playerProvider;
  }

  Future<bool> checkPermissions() async {
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
    return true;
  }

  Future<void> takePicture() async {
    try {
      await checkPermissions();
    } catch (e) {
      setState(() {
        error = "Could not get location: $e";
        isTaken = true;
        isNull = true;
      });
      return;
    }

    final picture = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picture == null) {
      setState(() {
        error = "Picture not found. Please try again.";
        isTaken = true;
        isNull = true;
      });
      return;
    }

    pictureFile = File(picture.path);

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );

      setState(() {
        location = LatLng(position.latitude, position.longitude);
        error = "";
        isTaken = true;
        isNull = false;
      });
    } catch (e) {
      setState(() {
        error = "Could not get location: $e";
        isTaken = true;
        isNull = true;
      });
    }
  }

  Future<void> uploadPicture() async {
    PlayerProvider? playerProvider;
    try {
      playerProvider = await getPlayer();
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isNull = true;
      });
      return;
    }

    try {
      // Uncomment when integrating backend
      // await pictureService.uploadPicture(
      //   file: pictureFile!,
      //   playerId: playerProvider.currentPlayer!.id,
      //   latitude: location!.latitude,
      //   longitude: location!.longitude,
      //   title: '${playerProvider.currentPlayer!.name} ${DateTime.now()}',
      // );

      setState(() {
        error = "Photo uploaded successfully!";
        isTaken = true;
        isNull = true;
      });
    } catch (e) {
      setState(() {
        error = "Could not upload photo: $e";
        isTaken = true;
        isNull = true;
      });
    }
  }

  void cancel() {
    setState(() {
      error = "";
      pictureFile = null;
      isTaken = false;
      isNull = false;
      location = null;
    });
  }

  void goToHomeScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload a Picture"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Add a picture to the game!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                if (!isTaken) ...[
                  ElevatedButton.icon(
                    onPressed: takePicture,
                    icon: const Icon(Icons.camera),
                    label: const Text("Take Photo"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ] else ...[
                  pictureFile != null
                      ? SizedBox(
                          height: 400,
                          width: 300,
                          child: Image.file(pictureFile!),
                        )
                      : const Text("No picture available"),
                  
                  const SizedBox(height: 10),

                  if (isNull)
                    Text(
                      error,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),

                  const SizedBox(height: 20),

                  if (!isNull)
                    ElevatedButton(
                      onPressed: uploadPicture,
                      child: const Text("Upload"),
                    )
                  else
                    ElevatedButton(
                      onPressed: cancel,
                      child: const Text("Go Back"),
                    ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: cancel,
                    child: const Text("Cancel"),
                  ),
                ],

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: goToHomeScreen,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text("Back to Home"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
