import 'package:flutter/material.dart';
import 'guessing_screen.dart';
import 'test_map_screen.dart';

class GameGuessingScreen extends StatelessWidget {
  const GameGuessingScreen({super.key});

  void _showMapScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows for a larger height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Rounded corners
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85, // Adjust height
        child: const TestMapScreen(),
      ),
    );
  }

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
        onPressed: () => _showMapScreen(context), // Show sliding map
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.keyboard_arrow_up, size: 32), // ^-shaped button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
