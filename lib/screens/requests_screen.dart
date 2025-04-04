import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:uoguesser/server/services/friendship.service.dart';
import 'package:uoguesser/server/services/player.service.dart';
import '../server/models/player.dart';
import '../providers/player.provider.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.goBack, required this.requests, required this.refresh});

  final List<Player> requests;
  final VoidCallback goBack;
  final VoidCallback refresh;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  final playerService = GetIt.instance<PlayerService>();
  final friendshipService = GetIt.instance<FriendshipService>();

  Future<PlayerProvider> getPlayer() async {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentPlayer == null) {
      throw Exception('You must be logged in to use this feature!');
    }
    return playerProvider;
  }

  void sendFriendRequest() async {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: EdgeInsets.only(top: 10),
          title: Text(
            "Send Friend Request to Player",
            style: TextStyle(fontSize: 24),
          ),
          content: Container(
            height: 400,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Request by Player Name"),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter Player Name Here",
                        labelText: "NAME"
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Submit",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );

    PlayerProvider ? me;

    try {
      me = await getPlayer();
    } catch (e) {
      throw Exception("$e");
    }

    String myId = me.currentPlayer!.id;

    Player ? them;

    try {
      them = await playerService.getPlayerByUsername(_controller.text);
    } catch (e) {
      throw Exception("$e");
    }

    String requestId = them.id;

    try {
      await friendshipService.sendFriendRequest(myId, requestId);
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
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
                        onPressed: ()=>{widget.goBack()},
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        child: Text("Back to Friends"),
                      ),
                      
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            sendFriendRequest();
                          } catch (e) {
                            AlertDialog(
                              content: Text("$e"),
                            );
                          }
                        },
                        child: Icon(Icons.add),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Text("Requests:"),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.requests.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  color: Colors.amber,
                  child: Center(
                    child: Text(widget.requests[index].name),
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