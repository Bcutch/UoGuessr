import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uoguesser/server/models/player.dart';
import 'package:uoguesser/server/services/player.service.dart';
import 'package:uoguesser/server/services/friendship.service.dart';
import 'package:uoguesser/providers/player.provider.dart';

class ProfilePage extends StatefulWidget {
  final String? playerId;
  final PlayerService? playerService;
  final FriendshipService? friendshipService;

  const ProfilePage({
    Key? key,
    this.playerId,
    this.playerService,
    this.friendshipService,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<Player>? playerFuture;
  late Future<List<Player>> _friendsFuture;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final playerFuture = playerProvider.playerFuture;
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
    final playerService = widget.playerService ?? playerProvider.playerService;
    final friendshipService =
        widget.friendshipService ?? playerProvider.friendshipService;

    if (playerId == null || playerService == null || friendshipService == null)
      return;

    playerFuture = playerService.getPlayerProfileById(playerId);
    _friendsFuture = friendshipService.getFriendProfiles(playerId);
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

  void _showAddFriendDialog(
    Player player,
    PlayerService playerService,
    FriendshipService friendshipService,
  ) {
    String username = '';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Friend'),
            content: TextField(
              onChanged: (value) => username = value,
              decoration: const InputDecoration(
                labelText: 'Friend\'s Username',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final friend = await playerService.getPlayerByUsername(
                      username,
                    );
                    await friendshipService.sendFriendRequest(
                      player.id,
                      friend.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend request sent!')),
                    );
                    setState(
                      () =>
                          _friendsFuture = friendshipService.getFriendProfiles(
                            player.id,
                          ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add friend: $e')),
                    );
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final playerService = widget.playerService ?? playerProvider.playerService;
    final friendshipService =
        widget.friendshipService ?? playerProvider.friendshipService;
    print(playerProvider.currentPlayer?.name);
    if (playerProvider.currentPlayer?.name == null ||
        playerProvider.currentPlayer?.name == "") {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: Color.fromARGB(255, 194, 4, 48),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
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
                    backgroundColor: Color.fromARGB(255, 255, 199, 42),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Player>(
        future: playerFuture,
        builder: (context, snapshot) {
          print('Connection state: ${snapshot.connectionState}');
          print('Has error: ${snapshot.hasError}');
          print('Has data: ${snapshot.hasData}');
          print('Data: ${snapshot.data}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Still loading player data...'));
          }

          final player = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Username: ${player.name}"),
                const SizedBox(height: 8),
                Text("High Score: ${player.highScore ?? 'N/A'}"),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Friends:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => _showAddFriendDialog(
                            player,
                            playerService,
                            friendshipService,
                          ),
                      child: const Text('Add Friend'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<Player>>(
                    future: _friendsFuture,
                    builder: (context, friendSnapshot) {
                      if (friendSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (friendSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${friendSnapshot.error}'),
                        );
                      } else if (!friendSnapshot.hasData ||
                          friendSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No friends yet'));
                      }

                      final friends = friendSnapshot.data!;
                      return ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(friends[index].name));
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
