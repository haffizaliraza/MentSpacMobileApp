import 'package:flutter/material.dart';
import 'package:my_flutter_app/about_page.dart';
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:my_flutter_app/dummyScreen.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/side_bar.dart';
import 'package:my_flutter_app/sidebar.dart';
import 'package:my_flutter_app/userCard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_app/api_config.dart';

class UsersList extends StatefulWidget {
  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> filteredData = [];
  String searchTerm = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void handleUpdateCallback(bool success) {
    if (success) {
      print('Update successful!');
      fetchUsers();
      // Add your UI update logic here if needed
    } else {
      print('Update failed.');
      // Add your error handling logic here if needed
    }
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/users'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );
          print('here is the response ${response}');

          if (response.statusCode == 200) {
            final List<dynamic> responseBody = json.decode(response.body);

            if (responseBody.isNotEmpty) {
              final List<Map<String, dynamic>> userData =
                  (responseBody as List<dynamic>)
                      .map((category) => category as Map<String, dynamic>)
                      .toList();

              setState(() {
                data = userData;
                filteredData = userData;
                isLoading = false;
              });
            } else {
              print('Empty response body');
            }
          } else {
            print('Error fetching user categories');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching user categories: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  bool filterUsersByName(Map<String, dynamic> user, String searchTerm) {
    final postUsername = user['post_username'];
    return postUsername.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void filterUser(String input) {
    setState(() {
      searchTerm = input;
      filteredData =
          data.where((user) => filterUsersByName(user, searchTerm)).toList();
    });
  }

  void signUserOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    // Print statements for debugging
    print('Token removed from local storage');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );

    // Print statement for debugging
    print('Navigation to login screen executed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users (${data.length})'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100, // Adjust the height as needed
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 183, 228, 245),
                ),
                child: Text(
                  'MentSpac',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Home Feed'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeFeeds()),
                );
              },
            ),
            ListTile(
              title: Text('Category'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage()),
                );
              },
            ),
            ListTile(
              title: Text('Chat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DummyScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Groups'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllGroups()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                signUserOut(context);
              },
            ),
          ],
        ),
      ),
      body: data.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: filterUser,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search...',
                    ),
                  ),
                ),
                Expanded(
                  child: filteredData.isEmpty
                      ? Center(
                          child: Text(
                            'No User Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            return UserCard(
                                item: filteredData[index],
                                updateCallback: handleUpdateCallback);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
