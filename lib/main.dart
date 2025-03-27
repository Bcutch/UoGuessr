import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uoguesser/screens/game_guessing_screen.dart';
import 'server/services/service.locator.dart';
import 'providers/player.provider.dart';
import 'screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'screens/upload_picture_screen.dart';
import 'screens/game_guessing_findit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup service locator
  await setupServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'game_guessing_screen',
          builder: (BuildContext context, GoRouterState state) {
            return const GameGuessingScreen();
          },
        ),
        GoRoute(path: 'upload_picture_screen',
        builder: (BuildContext context, GoRouterState state) {
            return const TestUploadScreen();
          },
        ),
        GoRoute(path: 'game_guessing_findit',
        builder: (BuildContext context, GoRouterState state) {
            return const GameGuessingFindit();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
