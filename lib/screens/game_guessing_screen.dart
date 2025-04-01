import 'package:flutter/material.dart';
import 'guessing_screen.dart';
import 'test_map_screen.dart';
import 'congratulations_screen.dart';
import 'package:get_it/get_it.dart';
import '../server/models/game.dart';
import '../server/models/picture.dart';
import '../server/services/game.service.dart';

class GameGuessingScreen extends StatefulWidget {
  const GameGuessingScreen({super.key});

  @override
  State<GameGuessingScreen> createState() => _GameGuessingScreenState();
}

class _GameGuessingScreenState extends State<GameGuessingScreen> {
  bool _isModalOpen = false;
  bool _isLoading = true;
  double _totalScore = 0;
  int _currentIndex = 0;
  Game? _game;
  List<Picture> _pictures = [];
  final _gameService = GetIt.instance<GameService>();

  String error = "";

  @override
  void initState() {
    super.initState();
    _getDailyGame();
  }

  Future<void> _getDailyGame() async {
    try {
      setState(() {
        _isLoading = true;
        error = "";
      });

      final result = await _gameService.getDailyGame();
      setState(() {
        _game = result.game;
        _pictures = result.pictures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Could not get daily game: $e";
        _isLoading = false;
      });
    }
  }

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
              targetLat: _pictures[_currentIndex].latitude,
              targetLng: _pictures[_currentIndex].longitude,
              onScoreUpdate: _updateScore,
              onNextPicture: _nextPicture,
              isLastImage: _currentIndex == _pictures.length - 1,
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
    if (_currentIndex < _pictures.length - 1) {
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
        backgroundColor: Color.fromARGB(255, 194, 4, 48),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Total Score: ${_totalScore.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _pictures.isNotEmpty
              ? FloatingActionButton(
                onPressed: () => _showMapScreen(context),
                shape: const CircleBorder(),
                backgroundColor: Colors.deepOrange,
                child: const Icon(Icons.keyboard_arrow_up, size: 32),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(error, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_pictures.isEmpty) {
      return const Center(child: Text('No pictures available for this game'));
    }

    return IgnorePointer(
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
                child: Image.network(
                  _pictures[_currentIndex].storageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Error loading image'));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
