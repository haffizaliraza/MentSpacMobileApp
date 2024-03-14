import 'package:flutter/material.dart';

class GroupScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final singleGroupState;

    return Scaffold(
      body: singleGroupState.when(
        // loading: () => CustomLoader(),
        data: (data) => SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 800.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        data.groupName,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Image.network(
                        data.groupIcon,
                        // alt: data.groupOwner,
                        height: 450.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            );
                          }
                        },
                      ),
                      // SizedBox(height: 16.0),
                      // CustomButton(onPressed: () => print('See more activities...'), text: 'See more activities...'),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                // PostScreen(),
              ],
            ),
          ),
        ),
        error: (_, __) => Text('Error loading group details'),
      ),
    );
  }
}
