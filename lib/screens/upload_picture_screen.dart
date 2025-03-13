import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/player.provider.dart';
import '../server/services/picture.service.dart';

class UploadPictureScreen extends StatefulWidget {
  const UploadPictureScreen({ Key? key }) : super(key: key);

  @override
  _UploadPictureScreenState createState() => _UploadPictureScreenState();
}

class _UploadPictureScreenState extends State<UploadPictureScreen> {
  final pictureService = GetIt.instance<PictureService>();

  Future<void> takePicture() async {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentPlayer == null) return;

    bool isEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isEnabled) {
      throw Exception('Location services are disabled.');
    } else {
      setState(() {
        locationMessage = "Checking permissions";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}