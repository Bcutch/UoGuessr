import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/player.provider.dart';
import '../server/services/picture.service.dart';

class TestUploadScreen extends StatefulWidget {
  const TestUploadScreen({super.key});

  @override
  State<TestUploadScreen> createState() => _TestUploadScreenState();
}

class _TestUploadScreenState extends State<TestUploadScreen> {
  final _imagePicker = ImagePicker();
  final pictureService = GetIt.instance<PictureService>();

  Future<void> _pickAndUploadImage() async {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentPlayer == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      // For testing, use random coordinates in Guelph
      final random = Random();
      final latitude = 43.5449 + (random.nextDouble() - 0.5) * 0.1;
      final longitude = -80.2482 + (random.nextDouble() - 0.5) * 0.1;

      final picture = await pictureService.uploadPicture(
        file: File(pickedFile.path),
        playerId: playerProvider.currentPlayer!.id,
        latitude: latitude,
        longitude: longitude,
        title: 'Test image ${DateTime.now()}',
      );

      // Add picture to provider's state
      playerProvider.addPicture(picture);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        if (playerProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Test Upload'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => playerProvider.refreshPictures(),
                tooltip: 'Refresh Pictures',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Logged in as: ${playerProvider.currentPlayer?.name ?? "Not logged in"}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child:
                    playerProvider.pictures.isEmpty
                        ? const Center(child: Text('No pictures uploaded yet'))
                        : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: playerProvider.pictures.length,
                          itemBuilder: (context, index) {
                            final picture = playerProvider.pictures[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    picture.storageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      color: Colors.black54,
                                      child: Text(
                                        'Lat: ${picture.latitude.toStringAsFixed(4)}\nLng: ${picture.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _pickAndUploadImage,
            tooltip: 'Upload Image',
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }
}
