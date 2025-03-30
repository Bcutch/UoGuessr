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
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Color.fromARGB(255, 255, 199, 42),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('UoGuesser')),
          backgroundColor: Color.fromARGB(255, 194, 4, 48),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Home-Page-Background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  onPressed: () => context.go('/game_guessing_findit'),
                  child: Text('Find it mode'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('TODO: Leaderboard'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('TODO: Your Profile'),
                ),
                ElevatedButton(onPressed: () {}, child: Text('TODO: Friends')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
