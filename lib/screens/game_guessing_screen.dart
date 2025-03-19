import 'package:flutter/material.dart';
import 'guessing_screen.dart';
import 'test_map_screen.dart';
import 'congratulations_screen.dart';

class GameGuessingScreen extends StatefulWidget {
  const GameGuessingScreen({super.key});

  @override
  State<GameGuessingScreen> createState() => _GameGuessingScreenState();
}

class _GameGuessingScreenState extends State<GameGuessingScreen> {
  bool _isModalOpen = false;
  double _totalScore = 0;
  int _currentIndex = 0;

  final List<String> _imagePaths = [
    'assets/images/University-of-Guelph1.jpg',
    'assets/images/University-of-Guelph2.jpg',
    'assets/images/University-of-Guelph3.jpg',
    'assets/images/University-of-Guelph4.jpg',
    'assets/images/University-of-Guelph5.jpg',
  ];

  final List<Map<String, dynamic>> _locations = [
    {'lat': 43.5335, 'lng': -80.2255},
    {'lat': 43.5308, 'lng': -80.2267},
    {'lat': 43.5341, 'lng': -80.2283},
    {'lat': 43.5315, 'lng': -80.2242},
    {'lat': 43.5327, 'lng': -80.2291},
  ];


  void _showMapScreen(BuildContext context) {
    setState(() {
      _isModalOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            setState(() {
              _isModalOpen = false;
            });
            return true;
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: TestMapScreen(
              targetLat: _locations[_currentIndex]['lat'],
              targetLng: _locations[_currentIndex]['lng'],
              onScoreUpdate: _updateScore,
              onNextPicture: _nextPicture,
              isLastImage: _currentIndex == _imagePaths.length - 1,
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _isModalOpen = false;
      });
    });
  }

  void _updateScore(double newScore) {
    setState(() {
      _totalScore += newScore;
    });
  }

  void _nextPicture() {
    if (_currentIndex < _imagePaths.length - 1) {
      setState(() {
        _currentIndex++;
      });
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guess the Location"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Total Score: ${_totalScore.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: IgnorePointer(
        ignoring: _isModalOpen,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Image.asset(
                    _imagePaths[_currentIndex],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMapScreen(context),
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.keyboard_arrow_up, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
