import 'package:flutter/material.dart';

class DummyScreen extends StatefulWidget {
  @override
  _DummyScreenState createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: 10, // Dummy count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child:
                        Text((index + 1).toString()), // Display index as text
                  ),
                  title: Text('User ${(index + 1)}'), // Dummy user name
                  subtitle:
                      Text('This is user ${(index + 1)}'), // Dummy subtitle
                  onTap: () {
                    // Handle onTap event if needed
                  },
                );
              },
            ),
    );
  }
}
