import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../screens/requests_screen.dart';
import '../server/models/friendship.dart';
import '../server/services/player.service.dart';
import '../providers/player.provider.dart';
import '../server/services/friendship.service.dart';
import '../server/models/player.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // bool isLoading = true;

  String error = "";
  final friendshipService = GetIt.instance<FriendshipService>();
  final playerService = GetIt.instance<PlayerService>();
  List<Player> ? friendsList;
  List<Player> ? requestsList;
  bool requestPage = false;
  PlayerProvider? playerProvider;

  @override
  void initState() {
    super.initState();
    // isLoading = true;
    getFriends();
    getRequests();
  }

  Future<PlayerProvider> getPlayer() async {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentPlayer == null) {
      throw Exception('You must be logged in to use this feature!');
    }
    return playerProvider;
  }

  void getFriends() async {
    Player none = Player(id: "-1", name: "No Friends found", createdAt: DateTime.now());

    try {
      playerProvider = await getPlayer();
    } catch (e) {
      setState(() {
        error = "Error: $e";
      });
      none = Player(id: "-1", name: "Profile Error", createdAt: DateTime.now());

      friendsList = [none];
      return;
    }

    if(playerProvider!.currentPlayer == null) {
      none = Player(id: "-1", name: "Profile Error", createdAt: DateTime.now());

      friendsList = [none];
      return;
    }

    List<Player> ? friends;
    
    try {
      friends = await friendshipService.getFriendProfiles(playerProvider!.currentPlayer!.id);
    } catch (e) {
      setState(() {
        error = "Error: $e";
      });

      friendsList = [none];
      return;
    }

    if (friends.isEmpty) {
      friendsList = [none];
      return;
    } else {
      friendsList = friends;
      return;
    }
  }

  void getRequests() async {
    Player none = Player(id: "-1", name: "No Friend Requests found", createdAt: DateTime.now());

    if(playerProvider == null) {
      Player none = Player(id: "-1", name: "Profile Error", createdAt: DateTime.now());
      requestsList = [none];

      // setState(() {
      //   isLoading = false;
      // });
      return;
    }

    if(playerProvider!.currentPlayer == null) {
      Player none = Player(id: "-1", name: "Profile Error", createdAt: DateTime.now());
      requestsList = [none];

      // setState(() {
      //   isLoading = false;
      // });
      return;
    }

    List<Friendship> ? friendships;

    try {
      friendships = await friendshipService.getFriendships(playerProvider!.currentPlayer!.id);
    } catch (e) {
      setState(() {
        error = "Error: $e";
      });

      requestsList = [none];
      // setState(() {
      //   isLoading = false;
      // });
      return;
    }

    if (friendships.isEmpty) {
      requestsList = [none];
      // setState(() {
      //   isLoading = false;
      // });
      return;
    }

    requestsList = [];
    Player ? checkPlayer;

    for (var friend in friendships) {
      if (friend.isPending) {
        if (friend.toPlayerId == playerProvider!.currentPlayer!.id) {
          try {
            checkPlayer = await playerService.getPlayerProfileById(friend.fromPlayerId);
          } catch(e) {
            checkPlayer = Player(id: "-2", name: "UnknownPlayer", createdAt: DateTime.now());
          }
          requestsList!.add(checkPlayer);
        }
      }
    }

    // setState(() {
    //   isLoading = false;
    // });
    return;
  }

  void refresh() {
    setState(() {
      getFriends();
    });
  }

  void refreshRequests() {
    setState(() {
      getRequests();
    });
  }

  void goToRequestScreen() {
    setState(() {
      requestPage = true;
    });
  }

  void goToFriendScreen() {
    setState(() {
      requestPage = false;
    });
  }

  void goToHomeScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends!"),
        backgroundColor: Colors.deepOrange,
      ),
      body: 
      // isLoading ? Text("LOADING")
      //   : 
      !requestPage ? FrendsPage(refresh: refresh, requestPage: goToRequestScreen, friendsList: friendsList!) :
        RequestsScreen(goBack: goToFriendScreen, requests: requestsList!, refresh: refreshRequests)
    );
  }
}

class FrendsPage extends StatefulWidget {
  const FrendsPage({super.key, required this.refresh, required this.requestPage, required this.friendsList});

  final VoidCallback refresh;
  final VoidCallback requestPage;
  final List<Player> friendsList;

  @override
  State<FrendsPage> createState() => _FrendsPageState();
}

class _FrendsPageState extends State<FrendsPage> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 1/15,
              child: Expanded(
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        onPressed: () => {widget.refresh()},
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        child: Text("Refresh"),
                      ),
                    ),
                    Flexible(
                      child: Container(

                      )
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: ()=>{widget.requestPage()},
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        child: Text("Pending Requests"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.friendsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  color: Colors.amber,
                  child: Center(
                    child: Text(widget.friendsList[index].name),
                  ),
                );
              }
            ),
            
          ],
        ),
      ),
    );
  }
}