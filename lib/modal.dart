import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPeopleScreen extends StatelessWidget {
  final List<dynamic> users;
  final int currentUserID;
  final VoidCallback refreshUI;

  const AddPeopleScreen({
    Key? key,
    required this.users,
    required this.currentUserID,
    required this.refreshUI,
  }) : super(key: key);

  Future<void> addUserToChat(dynamic userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.post(
            Uri.parse('http://localhost:8000/api/chats'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'members': [
                userId,
                currentUserID
              ], // Assuming 1 is the current user's ID
              'type': 'DM',
            }),
          );

          if (response.statusCode == 200) {
            // Call refreshUI to update the UI
            refreshUI();
          } else {
            throw Exception('Failed to add user to chat');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error adding user to chat: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add People'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          dynamic user = users[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25, // Adjust avatar size
              backgroundImage:
                  user['user_image'] != null && user['user_image'].isNotEmpty
                      ? NetworkImage(user['user_image'])
                      : AssetImage(
                          'assets/testimonial-2.jpg',
                        ) as ImageProvider, // Provide a default image asset
            ),
            title: Text(
              user['post_username'] ?? 'No Name',
              style: TextStyle(fontSize: 18),
            ),
            trailing: IconButton(
              onPressed: () {
                addUserToChat(user['id']);
                Navigator.pop(context); // Close the screen after adding user
              },
              icon: Icon(Icons.add),
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
