import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/notificationPost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api_config.dart';
import 'package:my_flutter_app/api_config.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/notification'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            setState(() {
              notifications = json.decode(response.body);
              isLoading = false;
            });
          } else {
            throw Exception('Failed to load notifications');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      // Handle error
    }
  }

  void navigateToPost(int postId) async {
    final postUrl = '${ApiConfig.baseUrl}/api/posts/$postId';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NotificationPost(postUrl: postUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text('No notifications found'),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final message = notification['message'];
                    final postContent = notification['post']['post_content'];
                    final combinedMessage = '$message "$postContent"';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: notification['sender']['user_image'] !=
                                null
                            ? NetworkImage(
                                notification['sender']['user_image'] as String)
                            : AssetImage('assets/default_avatar.png')
                                as ImageProvider<Object>,
                      ),
                      title: Text(
                          notification['sender']['post_username'] as String),
                      subtitle: Text(combinedMessage),
                      onTap: () {
                        final postId = notification['post']['id'];
                        navigateToPost(postId);
                      },
                    );
                  },
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationPage(),
  ));
}
