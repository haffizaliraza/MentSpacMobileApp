import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StreamsListPage extends StatefulWidget {
  @override
  _StreamsListPageState createState() => _StreamsListPageState();
}

class _StreamsListPageState extends State<StreamsListPage> {
  List<dynamic> _streamData = [];
  List<dynamic> _groupsData = [];
  bool _isLoading = true;
  int? _currentUserID;

  @override
  void initState() {
    super.initState();
    _fetchData();
    getCurrentUserId();
    fetchGroups();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('http://localhost:8000/api/go-live'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> responseBody = json.decode(response.body);

            if (responseBody.isNotEmpty) {
              setState(() {
                _streamData = responseBody;
                _isLoading = false;
              });
            } else {
              print('Empty response body');
            }
          } else {
            print('Error fetching live streams: ${response.statusCode}');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching live streams: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('token');

    if (userDataString != null) {
      Map<String, dynamic> userData = json.decode(userDataString);
      int? userId = userData['id'];

      if (userId != null) {
        setState(() {
          _currentUserID = userId;
        });
      }
    }
  }

  Future<void> fetchGroups() async {
    try {
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
            final List<dynamic> groupsData = json.decode(response.body);

            if (groupsData.isNotEmpty) {
              setState(() {
                _groupsData = groupsData;
              });
            } else {
              print('Empty groups response body');
            }
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
    }
  }

  void _openCreateStreamModal(BuildContext context) {
    String? selectedGroup;
    TextEditingController headingController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    bool isPrivate = false; // Add boolean for checkbox

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Create New Stream'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: headingController,
                    decoration: InputDecoration(labelText: 'Heading'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: isPrivate,
                        onChanged: (bool? value) {
                          setState(() {
                            isPrivate = value!;
                          });
                        },
                      ),
                      Text('Private Stream'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Select Group'),
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    decoration: InputDecoration(labelText: 'Groups'),
                    items: _groupsData.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['group_name'],
                        child: Text(group['group_name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroup = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Add logic to handle create stream here
                  Navigator.of(context).pop();
                },
                child: Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Streams'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _openCreateStreamModal(context);
            },
            child: Text('Start Live'),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _streamData.isNotEmpty
                    ? ListView.builder(
                        itemCount: _streamData.length,
                        itemBuilder: (context, index) {
                          if (_streamData[index]['streamer'] !=
                              _currentUserID) {
                            return StreamCard(
                              heading: _streamData[index]['heading'],
                              description: _streamData[index]['description'],
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      )
                    : Center(
                        child: Text('No live streams found'),
                      ),
          ),
        ],
      ),
    );
  }
}

class StreamCard extends StatelessWidget {
  final String heading;
  final String description;

  const StreamCard({
    required this.heading,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(heading),
        subtitle: Text(description),
        onTap: () {
          // Add your onTap logic here
        },
      ),
    );
  }
}
