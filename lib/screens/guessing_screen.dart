import 'package:flutter/material.dart';

class GuessingScreen extends StatelessWidget {
  const GuessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Your Guess"),
      ),
      body: Center(
        child: Image.asset(
          'assets/images/google-maps-screenshot.png',
          fit: BoxFit.contain,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Goes back to the previous screen
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.keyboard_arrow_down, size: 32), // Inverted button (v shape)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
