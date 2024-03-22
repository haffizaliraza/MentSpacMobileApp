import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/group_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GroupCard extends StatefulWidget {
  final dynamic item;

  GroupCard({required this.item});

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    String convertIsoToDate(String isoDate) {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }

    void handleNavigate(String id) {
      print('hre is id: $id');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupScreen(groupId: id),
        ),
      );
    }

    Future<void> handleJoinGroup(int id) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? tokenString = prefs.getString('token');

        if (tokenString != null) {
          final Map<String, dynamic> tokenMap = json.decode(tokenString);
          final String? authToken = tokenMap['auth_token'];

          if (authToken != null) {
            final response = await http.post(
              Uri.parse('http://localhost:8000/api/groups/join/$id'),
              headers: {
                'Authorization': 'Token $authToken',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 201) {
              setState(() {
                widget.item['is_joined'] = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Group joined successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              print('Error joining group. Status code: ${response.statusCode}');
            }
          } else {
            print('Authentication Token is null');
          }
        } else {
          print('Token string is null');
        }
      } catch (error) {
        print('Error joining group: $error');
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 64, vertical: 1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    widget.item['group_icon'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: IconButton(
                //     icon: Icon(Icons.favorite_border),
                //     onPressed: () {
                //       // Handle favorite action
                //     },
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item['group_name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        convertIsoToDate(widget.item['date_created']),
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.item['group_desc'],
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.item['is_joined']
                          ? handleNavigate(widget.item['id'].toString())
                          : handleJoinGroup(widget.item['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.item['is_joined']
                          ? Color(0xFF177CDA) // View Group button color
                          : Colors.blue, // Join Group button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Text(
                        widget.item['is_joined'] ? 'View Group' : 'Join Group',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
