import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'resetPassword_page.dart';
import 'package:my_flutter_app/api_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  // Future<void> handleForgetPassword() async {
  //   final String apiUrl = '${ApiConfig.baseUrl}/api/forgot-password';

  //   // Validate email
  //   if (emailController.text.isEmpty) {
  //     showSnackbar('Email is Required');
  //     return;
  //   }

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       body: {'email': emailController.text},
  //     );

  //     if (response.statusCode == 400) {
  //       showSnackbar('User not found. Please check your email.');
  //     }

  //     if (response.statusCode == 200) {
  //       showSnackbarSuccess('Email sent successfully to your account.');
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ResetPasswordPage(),
  //         ),
  //       );
  //     } else {
  //       showSnackbar('Failed to send password reset email');
  //     }
  //   } catch (error) {
  //     showSnackbar('An error occurred. Please try again later.');
  //   }
  // }

  Future<void> handleForgetPassword() async {
    final String apiUrl = '${ApiConfig.baseUrl}/api/forgot-password';

    // Validate email
    if (emailController.text.isEmpty) {
      showSnackbar('Email is Required');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'email': emailController.text},
      );

      if (response.statusCode == 200) {
        showSnackbarSuccess('Email sent successfully to your account.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(),
          ),
        );
      } else {
        // Handle failure, show error Snackbar with the message from the API response
        final dynamic responseBody = response.body;

        if (responseBody is String) {
          // If the response body is a string, try to decode it as JSON
          try {
            final Map<String, dynamic> errorData = json.decode(responseBody);

            if (errorData.containsKey('error')) {
              showSnackbar(errorData['error']);
            } else {
              showSnackbar('Failed to send password reset email');
            }
          } catch (e) {
            // If decoding as JSON fails, treat it as a plain string
            showSnackbar(responseBody);
          }
        } else {
          showSnackbar('Failed to send password reset email');
        }
      }
    } catch (error) {
      // Handle generic error, show error Snackbar
      showSnackbar('An error occurred. Please try again later.');
    }
  }

  // Method to show a Snackbar with the given message
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackbarSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reusing the design of the login text field
            buildInputField(
              'Your Email',
              'Enter your email',
              Icons.email,
              emailController,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your forgot password logic here
                handleForgetPassword();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                minimumSize:
                    MaterialStateProperty.all<Size>(Size(double.infinity, 48)),
              ),
              child: Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared widget for text input field
  Widget buildInputField(
    String label,
    String hintText,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: hintText,
              labelStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            ),
          ),
        ),
      ],
    );
  }
}
