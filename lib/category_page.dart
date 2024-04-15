import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/about_page.dart';
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/dummyScreen.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/side_bar.dart';
import 'package:my_flutter_app/sidebar.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/api_config.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<int> selectedCategory = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/categories'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            print('in success of fetch all categoris');

            final List<dynamic> responseBody = json.decode(response.body);

            if (responseBody.isNotEmpty) {
              final List<Map<String, dynamic>> data = responseBody
                  .map((category) => category as Map<String, dynamic>)
                  .toList();

              setState(() {
                categories = data;
                isLoading = false;
              });

              fetchUserSelectedCategories();
            } else {
              print('Empty response body');
            }
          } else {
            print('Error fetching categories');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching categories: $error');
      isLoading = false;
    }
  }

  Future<void> fetchUserSelectedCategories() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/user/categories'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);
            final List<int> userSelectedCategories =
                (responseData['catogery_ids'] as List<dynamic>).cast<int>();

            setState(() {
              selectedCategory = userSelectedCategories;
            });
          } else {
            print(
                'Error fetching user-selected categories: ${response.statusCode}');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching user-selected categories: $error');
    }
  }

  Future<void> submitCategory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('${ApiConfig.baseUrl}/api/user/categories'),
          );

          // Set authorization header
          request.headers['Authorization'] = 'Token $authToken';

          for (int i = 0; i < selectedCategory.length; i++) {
            request.fields['categories[$i]'] = selectedCategory[i].toString();
          }

          final response = await request.send();
          final responseData = await response.stream.bytesToString();
          print('Response data: $responseData');

          if (response.statusCode == 201) {
            // Extract category IDs from response keys
            final Map<String, dynamic> parsedResponse =
                json.decode(responseData);
            final List<int> categoryIds = [];
            parsedResponse.forEach((key, value) {
              if (key.startsWith('categories[')) {
                final int categoryId = int.tryParse(value.toString()) ?? -1;
                if (categoryId != -1) {
                  categoryIds.add(categoryId);
                }
              }
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllGroups()),
            );
            if (categoryIds.isNotEmpty) {
              setState(() {
                selectedCategory = categoryIds;
              });

              showToast('Category updated successfully');
            } else {
              print('Error: No category IDs found in the response');
            }
          } else {
            print('Error submitting user categories: ${response.statusCode}');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error submitting user categories: $error');
    }
  }

  void showToast(String message) {
    // Implement your toast logic here (e.g., using the 'toast' package)
    print(message);
  }

  void handleClick(int id) {
    setState(() {
      if (selectedCategory.contains(id)) {
        selectedCategory.remove(id);
      } else {
        selectedCategory.add(id);
      }
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
        title: Text('Select Category'),
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

            // ListTile(
            //   title: Text('Category'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CategoryPage()),
            //     );
            //   },
            // ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersList()),
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
              title: Text('Chat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SideBar()),
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  categories.length > 0
                      ? Column(
                          children: [
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: categories.map((category) {
                                return GestureDetector(
                                  onTap: () => handleClick(category['id']),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(5),
                                      color: selectedCategory
                                              .contains(category['id'])
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    child: Text(
                                      category['name'],
                                      style: TextStyle(
                                        color: selectedCategory
                                                .contains(category['id'])
                                            ? Colors.white
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: submitCategory,
                              child: Text('Done'),
                            ),
                          ],
                        )
                      : Text(
                          'No Category Found',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
