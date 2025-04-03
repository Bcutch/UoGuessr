import 'package:flutter/material.dart';
import '../server/models/player.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.goBack, required this.requests, required this.refresh});

  final List<Player> requests;
  final VoidCallback goBack;
  final VoidCallback refresh;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

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