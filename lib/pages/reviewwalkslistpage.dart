import 'package:flutter/material.dart';
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/walk.dart';
import 'package:walkmapper/pages/currentwalkpage.dart';

class ReviewWalksListPage extends StatefulWidget {
  const ReviewWalksListPage({super.key});
  @override
  State<ReviewWalksListPage> createState() => _WalksListPageState();
}

class _WalksListPageState extends State<ReviewWalksListPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk Mapper'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body:
         SafeArea(
                minimum: EdgeInsets.fromLTRB(0, 50, 0, 75),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Select Walk to Review:",
                              style: TextStyle(fontSize: 28),
                            ),
                           
                          ],
                        ),
                      ],
                    ),
                   
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ListView.builder(
                              itemCount: boxWalk.length,
                              itemBuilder: (context, index) {
                                Walk walk = boxWalk.getAt(index);
                                return ListTile(tileColor: Colors.blue[100],
                                  iconColor: Colors.red[700],
                                  dense: true,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  leading: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        boxWalk.deleteAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_forever, size: 32),
                                  ),

                                  //title: Text(walk.walkTitle),
                                  //subtitle: const Text("Title"),
                                  trailing: Text(
                                    "Date: ${walk.walkStartTime.toLocal()}",
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }


}
