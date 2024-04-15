import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatBody extends StatefulWidget {
  final Map<String, dynamic> currentChattingMember;
  final String roomId;

  const ChatBody({
    Key? key,
    required this.currentChattingMember,
    required this.roomId,
  }) : super(key: key);

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _chatHistory = [];
  List<dynamic> userChat = [];
  int currentUserID = 1;
  bool _isLoading = true;
  String _errorMessage = '';
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    connectToSocket();
    fetchUserChat();
  }

  void connectToSocket() {
    channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws/users/$currentUserID/chat/'));
    channel.stream.listen((message) {
      print('Received message: $message');
      try {
        Map<String, dynamic> parsedMessage = jsonDecode(message);
        // Check if the message contains required fields
        if (parsedMessage.containsKey('action') &&
            parsedMessage.containsKey('message') &&
            parsedMessage.containsKey('roomId') &&
            parsedMessage.containsKey('user')) {
          setState(() {
            // Add the validated message to the chat history
            userChat.add(parsedMessage);
          });
        } else {
          print('Received message does not have all required fields');
        }
      } catch (e) {
        print('Error decoding message: $e');
      }
    });
  }

  void sendMessage(String message) {
    channel.sink.add(jsonEncode({
      "action": "message",
      'message': message,
      "roomId": widget.roomId,
      "user": currentUserID
    })); // Send message as JSON
  }

  Future<void> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('token');

    if (userDataString != null) {
      Map<String, dynamic> userData = json.decode(userDataString);
      int? userId = userData['id'];

      if (userId != null) {
        setState(() {
          currentUserID = userId;
        });
        print('current user id is here $currentUserID');
      }
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) {
      return '';
    }
    DateTime dateTime = DateTime.parse(timestamp);
    String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return formattedDate;
  }

  Future<void> fetchUserChat() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse(
                'http://localhost:8000/api/chats/${widget.roomId}/messages?limit=20&offset=0'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            final List<dynamic> results = responseData['results'];
            setState(() {
              userChat = results;
              _isLoading = false;
            });
          } else {
            throw Exception('Failed to fetch chat users');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching chat users: $error');
      setState(() {
        _errorMessage = 'Failed to fetch chat messages.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.currentChattingMember['user_image'] != null &&
                          widget.currentChattingMember['user_image'].isNotEmpty
                      ? NetworkImage(widget.currentChattingMember['user_image'])
                      : AssetImage('assets/testimonial-2.jpg')
                          as ImageProvider, // Cast to ImageProvider
            ),
            SizedBox(
              width: 8,
            ),
            Text(widget.currentChattingMember['post_username']),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: userChat.length,
                        itemBuilder: (context, index) {
                          final message = userChat[index];
                          final isSentByCurrentUser =
                              message['user'] == currentUserID;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            child: Align(
                              alignment: isSentByCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSentByCurrentUser
                                      ? Colors.blue
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message['message'] ?? '',
                                      style: TextStyle(
                                        color: isSentByCurrentUser
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(message['timestamp']) ??
                                          '',
                                      style: TextStyle(
                                        color: isSentByCurrentUser
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          FloatingActionButton(
                            onPressed: () {
                              sendMessage(_messageController.text.trim());
                              _messageController.clear();
                            },
                            child: Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
