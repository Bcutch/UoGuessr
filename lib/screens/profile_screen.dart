import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/providers/player.provider.dart';

class ProfilePage extends StatefulWidget {
  final String? playerId;

  const ProfilePage({Key? key, this.playerId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<Player>? playerFuture;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playerProvider.currentPlayer != null) {
        setState(() {
          _loadData();
        });
      }
    });
  }

  void _loadData() {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final playerId = widget.playerId ?? playerProvider.currentPlayer?.id;
    final playerService = playerProvider.playerService;

    if (playerId == null || playerService == null) return;

    playerFuture = playerService.getPlayerProfileById(playerId);
  }

  Future<void> _login(String username, String password) async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    try {
      setState(() => _isLoggingIn = true);
      await playerProvider.loginOrRegister(username, password);
      setState(() {
        _loadData();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }

  void _logout() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    await playerProvider.logout();
    setState(() {
      playerFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (playerProvider.currentPlayer?.name == null ||
        playerProvider.currentPlayer!.name.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Color.fromARGB(255, 194, 4, 48),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Home-Page-Background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(30, 250, 30, 250),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5.0),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Username',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      _isLoggingIn
                          ? null
                          : () => _login(
                            _usernameController.text.trim(),
                            _passwordController.text,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 199, 42),
                    foregroundColor: Colors.black,
                  ),
                  child:
                      _isLoggingIn
                          ? const CircularProgressIndicator()
                          : const Text('Login / Register'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Color.fromARGB(255, 194, 4, 48),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Player>(
        future: playerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Still loading player data...'));
          }

          final player = snapshot.data!;

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    player.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      'assets/images/profilePic.png',
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "High Score: ${player.highScore ?? 'N/A'}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recent Uploads:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<PlayerProvider>(
                    builder: (context, playerProvider, child) {
                      final pictures = playerProvider.pictures;

                      if (pictures.isEmpty) {
                        return const Center(
                          child: Text('No uploaded pictures yet.'),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemCount: pictures.length,
                        itemBuilder: (context, index) {
                          final picture = pictures[index];
                          return Image.network(
                            picture.storageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
