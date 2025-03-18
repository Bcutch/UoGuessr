import 'package:flutter/material.dart';
import 'guessing_screen.dart';
import 'test_map_screen.dart';

class GameGuessingScreen extends StatelessWidget {
  const GameGuessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guess the Location"),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 1.0,
          maxScale: 5.0,
          child: Image.asset(
            'assets/images/University-of-Guelph.jpg', // Change this to your actual image
            fit: BoxFit.contain,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TestMapScreen()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.keyboard_arrow_up, size: 32), // ^-shaped button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
