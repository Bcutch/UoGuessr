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
  const TestUploadScreen({ Key? key }) : super(key: key);

  @override
  _TestUploadScreenState createState() => _TestUploadScreenState();
}

class _TestUploadScreenState extends State<TestUploadScreen> {
  final pictureService = GetIt.instance<PictureService>();
  String playerName = "TestName";                         //<-- TO BE REMOVED
  LatLng ? location;
  File ? pictureFile;
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

    if (!isEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission= await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){

      permission= await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied){
      throw Exception('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever){
      throw Exception('Location permissions are denied forever');
    }
    return true;
  }

  Future takePicture() async {
    try{
      checkPermissions();
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
      Position? position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings( 
          accuracy: LocationAccuracy.best,
        ),
      );

      setState(() {
        location = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        error = "Could not get location: $e";
        isTaken = true;
        isNull = true;
      });
      return;
    }

    setState(() {
      error = "";
      isTaken = true;
      isNull = false;
    });
  }

  Future uploadPicture() async {
    PlayerProvider ? playerProvider;

    try {
      playerProvider = await getPlayer();
    } catch (e) {
      throw Exception(e);
    }

    try {
      // await pictureService.uploadPicture(
      //   file: pictureFile!,
      //   playerId: playerProvider.currentPlayer!.id,
      //   latitude: location!.latitude,
      //   longitude: location!.longitude,
      //   title: '$playerName ${DateTime.now()}', //<-- TO BE CHANGED
      // );
      setState(() {
        error = "Photo uploaded!";
        isTaken = true;
        isNull = true;
      });
    } catch (e) {
      setState(() {
        error = "Could not upload photo: $e";
        isTaken = true;
        isNull = true;
      });
      return;
    }
  }

  void cancel() {
    setState(() {
      error = "";
      pictureFile = null;
      isTaken = false;
      isNull = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isTaken) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(20)),
          Text(
            "Add a picture to the game!",
            style: TextStyle(fontSize: 30),
          ),
          Container(
            padding: EdgeInsets.all(10),
          ),
          FloatingActionButton.extended(
            onPressed: () => takePicture(),
            label: Text("Take photo"),
            icon: Icon(Icons.camera),
          )
      ],);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(20)),
          Text("Add a picture to the game!"),
          Container(
            padding: EdgeInsets.all(10),
          ),

          pictureFile != null ? 
          SizedBox(
            height: 400,
            width: 300,
            child: Image.file(pictureFile!),
          ) : 
          Text(""),
      
          !isNull ? 
          Text("") : 
          Text(
            error,
            style: TextStyle(fontSize: 12),  
          ),
      
          Container(
            padding: EdgeInsets.all(10),
          ),
      
          !isNull ? 
          FloatingActionButton(
            onPressed: () => uploadPicture(),
            child: Text("Upload"),
          ) :
          FloatingActionButton(
            onPressed: () => cancel(),
            child: Text("Go back"),
          ),
      
          !isNull ? FloatingActionButton(
            onPressed: () => cancel(),
            child: Text("Cancel"),
          ) : Text("")
      ],);
    }
  }
}