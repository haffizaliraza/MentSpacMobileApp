import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

typedef void UpdateCallback(bool success);

class UserCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final UpdateCallback updateCallback;

  UserCard({required this.item, required this.updateCallback});

  @override
  Widget build(BuildContext context) {
    final userImage = item['user_image'] ?? item['image_url'];
    final postUsername = item['post_username'];
    final showAddress = item['show_address'];
    final city = item['city'];
    final isBlocked = item['is_blocked'];
    final isFollowed = item['is_followed'];
    final userId = item['id'];

    Future<void> toggleBlockUser(int userId, bool block) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? tokenString = prefs.getString('token');

        if (tokenString != null) {
          final Map<String, dynamic> tokenMap = json.decode(tokenString);
          final String? authToken = tokenMap['auth_token'];

          if (authToken != null) {
            final response = await http.post(
              Uri.parse('http://localhost:8000/api/users/block/${userId}'),
              headers: {
                'Authorization': 'Token $authToken',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'user_id': userId,
                'action': block ? 'block' : 'unblock',
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(block
                      ? 'User blocked successfully'
                      : 'User unblocked successfully'),
                  duration: Duration(seconds: 2),
                ),
              );

              updateCallback(true);
            } else {
              print(
                  'Error toggling block user. Status code: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          }
        }
      } catch (error) {
        print('Error toggling block user: $error');
      }
    }

    Future<void> toggleFollowUser(int userId, bool follow) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? tokenString = prefs.getString('token');

        if (tokenString != null) {
          final Map<String, dynamic> tokenMap = json.decode(tokenString);
          final String? authToken = tokenMap['auth_token'];

          if (authToken != null) {
            final response = await http.post(
              Uri.parse('http://localhost:8000/api/users/follow/${userId}'),
              headers: {
                'Authorization': 'Token $authToken',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'user_id': userId,
                'action': follow ? 'follow' : 'unfollow',
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(follow
                      ? 'User followed successfully'
                      : 'User unfollowed successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
              updateCallback(true);
            } else {
              print('Error toggling follow user: ${response.statusCode}');
            }
          }
        }
      } catch (error) {
        print('Error toggling follow user: $error');
      }
    }

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 2,
                  ),
                ),
                child: userImage != ''
                    ? Image.network(
                        userImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$postUsername${showAddress && city != null ? ' (From $city)' : ''}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await toggleBlockUser(userId, !isBlocked);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isBlocked ? 'Unblock' : 'Block',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await toggleFollowUser(userId, !isFollowed);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isFollowed ? 'Unfollow' : 'Follow',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
