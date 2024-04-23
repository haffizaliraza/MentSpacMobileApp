import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/api_config.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late String _username = '';
  late String _userImage = '';
  late String _firstName = '';
  late String _lastName = '';
  late String _gender = '';
  late String _dateJoined = '';
  late bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/api/userprofile'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> profileData = jsonDecode(response.body);
            final userProfile = profileData.isNotEmpty ? profileData[0] : null;
            if (userProfile != null) {
              setState(() {
                _username = userProfile['post_username'] ?? '';
                _userImage = userProfile['user_image'] ?? '';
                _firstName = userProfile['first_name'] ?? '';
                _lastName = userProfile['last_name'] ?? '';
                _gender = userProfile['gender'] ?? '';
                _dateJoined = userProfile['date_joined'] != null
                    ? DateFormat.yMMMMd()
                        .format(DateTime.parse(userProfile['date_joined']))
                    : '';
                _loading = false;
              });
            }
          } else {
            throw Exception('Failed to load user profile');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 200, // Specify a finite height for the container
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.indigo],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Image or Decorative Elements
                        Positioned.fill(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1708205251831-f19e9dd7edf5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcxMzM3NTc3MQ&ixlib=rb-4.0.3&q=80&w=1080',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // User Avatar
                        Positioned(
                          top: 100,
                          child: GestureDetector(
                            onTap: () {
                              // Add onTap functionality here
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _userImage.isNotEmpty
                                  ? NetworkImage(_userImage)
                                  : AssetImage('assets/placeholder_avatar.png')
                                      as ImageProvider,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        // User Name
                        Positioned(
                          bottom: 20,
                          child: Text(
                            _username.isNotEmpty ? _username : 'N/A',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // User Details
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetail('First Name', _firstName),
                          _buildDetail('Last Name', _lastName),
                          _buildDetail('Gender', _gender),
                          _buildDetail('Date Joined', _dateJoined),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
