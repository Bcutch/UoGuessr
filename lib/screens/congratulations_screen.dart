import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  final double totalScore;

  const CongratulationsScreen({super.key, required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Over"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Congratulations!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Total Score: ${totalScore.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main menu (not implemented yet)
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Return to Main Menu", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
