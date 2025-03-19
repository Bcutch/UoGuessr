import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenScreenState();
}

class _HomeScreenScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('UoGuesser'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => context.go('/game_guessing_screen'),
                child: Text('Daily Game'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/upload_picture_screen'), 
                child: Text('Take Picture'),
              ),
              ElevatedButton(
                onPressed: () {}, 
                child: Text('TODO: find it mode'),
              ),
              ElevatedButton(
                onPressed: () {}, 
                child: Text('TODO: Leaderboard'),
              ),
              ElevatedButton(
                onPressed: () {}, 
                child: Text('TODO: Your Profile'),
              ),
              ElevatedButton(
                onPressed: () {}, 
                child: Text('TODO: Friends'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}