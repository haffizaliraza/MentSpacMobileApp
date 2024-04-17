import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api_config.dart';

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
            Uri.parse('${ApiConfig.baseUrl}/api/chats'),
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
    if (users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add People'),
        ),
        body: Center(
          child: Text('No users available'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add People'),
        ),
        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            dynamic user = users[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Card(
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: user['user_image'] != null &&
                            user['user_image'].isNotEmpty
                        ? NetworkImage(user['user_image'])
                        : AssetImage('assets/testimonial-2.jpg')
                            as ImageProvider<Object>,
                  ),
                  title: Text(
                    user['post_username'] ?? 'No Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      addUserToChat(user['id']);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 183, 228, 245),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
