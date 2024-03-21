import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/about_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'dart:convert';
import 'package:my_flutter_app/groupCard_page.dart';
// import 'package:my_flutter_app/group_page.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllGroups extends StatefulWidget {
  @override
  _AllGroupsState createState() => _AllGroupsState();
}

class _AllGroupsState extends State<AllGroups> {
  bool isLoading = true;
  List<dynamic> categoryGroupData = [];
  List<dynamic> data = [];
  bool filteredData = false;
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
    fetchCategoryGroups();
  }

  Future<void> fetchCategoryGroups() async {
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
            Uri.parse('http://localhost:8000/api/user/categories/groups'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> responseBody = json.decode(response.body);

            if (responseBody is List) {
              setState(() {
                isLoading = false;
                categoryGroupData = responseBody;
                print('here is the groups $categoryGroupData');
              });
            } else {
              print('Invalid response format for categoryGroupData');
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

  void filterGroup() async {
    if (searchExist()) {
      setState(() {
        filteredData = true;
        isLoading = true; // Set loading to true while fetching data
      });

      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? tokenString = prefs.getString('token');

        if (tokenString != null) {
          final Map<String, dynamic> tokenMap = json.decode(tokenString);
          final String? authToken = tokenMap['auth_token'];

          if (authToken != null) {
            final url = 'http://localhost:8000/api/groups?search=$searchTerm';
            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Token $authToken',
                'Content-Type': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              setState(() {
                isLoading = false;
                data = json.decode(response.body);
              });
            } else {
              print('Error fetching groups: ${response.statusCode}');
            }
          } else {
            print('Authentication Token is null');
          }
        } else {
          print('Token string is null');
        }
      } catch (error) {
        print('Error fetching groups: $error');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        filteredData = false;
        data = [];
      });
    }
  }

  bool searchExist() {
    return searchTerm.trim() != '';
  }

  void signUserOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    // Print statements for debugging
    print('Token removed from local storage');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    // Print statement for debugging
    print('Navigation to login screen executed');
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Groups'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100, // Adjust the height as needed
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                ),
                child: Text(
                  'MentSpac',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
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
            //   title: Text('GroupFeed'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => GroupScreen()),
            //     );
            //   },
            // ),
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
              title: Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersList()),
                );
              },
            ),
            ListTile(
              title: Text('Mentspac'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
            // ListTile(
            //   title: Text('Groups'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => AllGroups()),
            //     );
            //   },
            // ),
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
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'All Groups (${!filteredData ? categoryGroupData.length : data.length})',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchTerm = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: ' Search',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical:
                                        10.0), // Adjust the vertical padding as needed
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: filterGroup,
                            child: Icon(Icons.search),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    if (categoryGroupData.isNotEmpty &&
                        data.isEmpty &&
                        !filteredData)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Recommended Groups',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 32,
                                mainAxisSpacing: 32,
                              ),
                              itemCount: categoryGroupData.length,
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemBuilder: (context, index) {
                                print('index data ${index}');
                                return GroupCard(
                                  item: categoryGroupData[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    if (filteredData && data.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Search Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 32,
                              mainAxisSpacing: 32,
                            ),
                            itemCount: data.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GroupCard(
                                item: data[index],
                              );
                            },
                          ),
                        ],
                      ),
                    if (!filteredData &&
                        data.isEmpty &&
                        categoryGroupData.isEmpty)
                      Text(
                        'No Group Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AllGroups(),
  ));
}
