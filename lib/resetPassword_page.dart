import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  void handleResetPassword() {
    // Validate new password and security code
    if (passwordController.text.isEmpty || codeController.text.isEmpty) {
      // Show error Snackbar for empty fields
      showSnackbar('New Password and Security Code are required');
    } else {
      // Continue with the reset password logic
      performResetPassword();
    }
  }

  // Future<void> performResetPassword() async {
  //   final String apiUrl = 'http://mentspac.com/api/reset-password';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       body: {
  //         'new_password': passwordController.text,
  //         'security_code': codeController.text,
  //       },
  //     );

  //     if (response.statusCode == 400) {
  //       showSnackbar('Invalid Code.');
  //     }

  //     if (response.statusCode == 200) {
  //       // Handle success, show toast or navigate to a success page
  //       print('Password reset successful');
  //       showSnackbarSuccess('Password reset successful.');
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => LoginPage(),
  //         ),
  //       );
  //     } else {
  //       // Handle failure, show error toast or message
  //       print('Failed to reset password');
  //     }
  //   } catch (error) {
  //     // Handle generic error, show error toast or message
  //     print('An error occurred: $error');
  //   }
  // }

  Future<void> performResetPassword() async {
    final String apiUrl = 'http://mentspac.com/api/reset-password';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'new_password': passwordController.text,
          'security_code': codeController.text,
        },
      );

      if (response.statusCode == 200) {
        // Handle success, show toast or navigate to a success page
        print('Password reset successful');
        showSnackbarSuccess('Password reset successful.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        // Handle failure, show error toast or message
        final dynamic responseBody = response.body;

        if (responseBody is String) {
          // If the response body is a string, try to decode it as JSON
          try {
            final Map<String, dynamic> errorData = json.decode(responseBody);

            if (errorData.containsKey('error')) {
              showSnackbar(errorData['error']);
            } else {
              showSnackbar('Failed to reset password');
            }
          } catch (e) {
            // If decoding as JSON fails, treat it as a plain string
            showSnackbar(responseBody);
          }
        } else {
          showSnackbar('Failed to reset password');
        }
      }
    } catch (error) {
      // Handle generic error, show error toast or message
      print('An error occurred: $error');
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Your New Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Your Security Code',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      handleResetPassword();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      minimumSize: MaterialStateProperty.all<Size>(
                          Size(double.infinity, 48)),
                    ),
                    child: Text(
                      'Update Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
