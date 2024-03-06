import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mime/mime.dart';

class FileType {
  final String path;
  final int lastModified;
  final DateTime lastModifiedDate;
  final String name;
  final int size;
  final String type;
  final String webkitRelativePath;

  FileType({
    required this.path,
    required this.lastModified,
    required this.lastModifiedDate,
    required this.name,
    required this.size,
    required this.type,
    required this.webkitRelativePath,
  });
}

final TextEditingController postController = TextEditingController();
String? imagePreviewUrl;

class CreatePost extends StatefulWidget {
  final Function(Map<String, dynamic>) uploadFiles;

  CreatePost({required this.uploadFiles});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String post = "";
  String isImage = "image";
  bool isOpen = false;
  FileType files = FileType(
    path: "",
    lastModified: 0,
    lastModifiedDate: DateTime.now(),
    name: "",
    size: 0,
    type: "",
    webkitRelativePath: "",
  );
  dynamic previewUrl;
  String error = "";
  late String id;

  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    // Fetch the id using whatever logic you have
    // For now, assigning a placeholder value
    id = "some_id";
  }

  Future<void> validateFileType(FileType files) async {
    if (files.path.isEmpty) {
      setState(() {
        error = "Empty";
      });
      return;
    }

    const List<String> validImageTypes = [
      "image/jpeg",
      "image/png",
      "image/gif"
    ];
    const List<String> validVideoTypes = [
      "video/mp4",
      "video/mpeg",
      "video/webm"
    ];
    const List<String> validAudioTypes = [
      "audio/mpeg",
      "audio/ogg",
      "audio/wav"
    ];

    try {
      // Read file bytes
      List<int> fileBytes = await File(files.path).readAsBytes();

      if (validImageTypes.contains(files.type)) {
        setState(() {
          previewUrl = MemoryImage(Uint8List.fromList(fileBytes));
          imagePreviewUrl = null;
        });
      } else if (validVideoTypes.contains(files.type)) {
        // Handle video preview
      } else if (validAudioTypes.contains(files.type)) {
        // Handle audio preview
      } else {
        setState(() {
          error = "Invalid file type selected";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error reading file";
      });
    }
  }

  Future<void> validateFileTypeWeb(Uint8List bytes) async {
    const List<String> validImageTypes = [
      "image/jpeg",
      "image/png",
      "image/gif"
    ];
    const List<String> validVideoTypes = [
      "video/mp4",
      "video/mpeg",
      "video/webm"
    ];
    const List<String> validAudioTypes = [
      "audio/mpeg",
      "audio/ogg",
      "audio/wav"
    ];

    if (validImageTypes.contains(files.type)) {
      setState(() {
        previewUrl = MemoryImage(bytes);
        imagePreviewUrl = null;
      });
    } else if (validVideoTypes.contains(files.type)) {
      // Handle video preview
    } else if (validAudioTypes.contains(files.type)) {
      // Handle audio preview
    } else {
      setState(() {
        error = "Invalid file type selected";
      });
    }
  }

  Future<void> handleDrop() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        files = FileType(
          path: "", // Leave it empty for web
          lastModified: DateTime.now().millisecondsSinceEpoch,
          lastModifiedDate: DateTime.now(),
          name: result.files.single.name,
          size: result.files.single.size,
          type: lookupMimeType(result.files.single.name) ?? "",
          webkitRelativePath: "",
        );
        error = "";
        imagePreviewUrl = null;
      });

      Future.delayed(Duration(milliseconds: 50), () {
        validateFileType(files);
      });
    }
  }

  // void handleChange(String value) {
  //   postController.text = value;
  // }

  void handleChange(String value) {
    print('Before setState: $post');
    setState(() {
      post = value;
    });
    print('After setState: $post');
  }

  void handleImage() {
    setState(() {
      isOpen = !isOpen;
      isImage = "image";
      if (files.type.startsWith("video/") || files.type.startsWith("audio/")) {
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
          imagePreviewUrl = null;
        });
      }
    });
  }

  void handleVideo() {
    setState(() {
      isOpen = !isOpen;
      isImage = "video";
      if (files.type.startsWith("image/") || files.type.startsWith("audio/")) {
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
        });
      }
    });
  }

  void handleAudio() {
    setState(() {
      isOpen = !isOpen;
      isImage = "audio";
      if (files.type.startsWith("image/") || files.type.startsWith("video/")) {
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
        });
      }
    });
  }

  Future<void> handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      final formData = http.MultipartRequest(
        'POST',
        Uri.parse('http://mentspac.com:8000/api/posts'),
      );

      formData.fields.addAll({
        "post_content": post,
        "like": false.toString(),
      });

      // Add media file if selected
      if (files.path.isNotEmpty) {
        File file = File(files.path);
        List<int> fileBytes = await file.readAsBytes();
        String fieldName;

        if (isImage == "image") {
          fieldName = 'post_image';
        } else if (isImage == "video") {
          fieldName = 'post_video';
        } else if (isImage == "audio") {
          fieldName = 'post_audio';
        } else {
          // Handle other cases if needed
          return;
        }

        // Add the file as bytes to the form data
        formData.files.add(
          http.MultipartFile.fromBytes(fieldName, fileBytes,
              filename: files.name),
        );
      }

      // Set authorization header
      formData.headers['Authorization'] = 'Token $authToken';

      // Clear form fields after submitting
      setState(() {
        post = "";
        files = FileType(
          path: "",
          lastModified: 0,
          lastModifiedDate: DateTime.now(),
          name: "",
          size: 0,
          type: "",
          webkitRelativePath: "",
        );
        previewUrl = null;
        error = "";
        isOpen = false;
      });

      try {
        final response = await formData.send();
        if (response.statusCode == 201) {
          // Handle success, e.g., show a success message to the user
          print('Post created successfully');

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeFeeds(),
            ),
          );
          postController.clear();
        } else {
          // Handle error
          print('Error creating post. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // Handle error
        print('Error creating post: $error');
      }
    }
  }

  String handleText() {
    if (files.type.startsWith("image/")) {
      return "image";
    } else if (files.type.startsWith("video/")) {
      return "video";
    } else if (files.type.startsWith("audio/")) {
      return "audio";
    } else {
      return "file";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Column(
        children: [
          Form(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: postController,
                      onChanged: (value) => handleChange(value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "What's on your mind...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Text(error, style: TextStyle(color: Colors.red)),
                  if (isOpen)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: handleDrop,
                        child: Text("Pick File"),
                      ),
                    ),
                  if (previewUrl != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: previewUrl is MemoryImage
                          ? Image.memory(Uint8List.fromList(
                              (previewUrl as MemoryImage).bytes))
                          : previewUrl is String
                              ? Image.network(previewUrl)
                              : Container(),
                    ),
                  // Action Buttons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButtons(Icons.image, "Image", handleImage),
                      _buildActionButtons(Icons.videocam, "Video", handleVideo),
                      _buildActionButtons(
                          Icons.audiotrack, "Audio", handleAudio),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text("Post"),
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.blue,
                          // onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      IconData icon, String label, Function() onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
