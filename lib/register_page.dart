import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/terms_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'terms_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Register(),
  ));
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isHealthcare = false;
  String validationError = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPswdController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser(BuildContext context) async {
    final String apiUrl = 'http://mentspac.com/api/auth/register';

    // Reset validation errors
    setState(() {
      validationError = '';
    });

    // Check if passwords match
    if (passwordController.text != confirmPswdController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return; // Stop the registration process if passwords don't match
    }

    // Validate required fields
    if (emailController.text.isEmpty || passwordController.text.isEmpty
        // firstNameController.text.isEmpty ||
        // lastNameController.text.isEmpty ||
        // addressController.text.isEmpty ||
        // cityController.text.isEmpty
        ) {
      setState(() {
        validationError = 'Email and Password Fields are Required';
        isLoading = false;
      });

      // Show validation error as a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': emailController.text,
          'password': passwordController.text,
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'address': addressController.text,
          'city': cityController.text,
        },
      );

      if (response.statusCode == 201) {
        print('Registration Successful');
        print('Response: ${response.body}');

        // Store user information in local storage
        final Map<String, dynamic> userData = jsonDecode(response.body);
        await storeUserData(userData);

        // Show success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        print('Registration Failed');
        print('Response: ${response.body}');

        // Handle error messages from the API response
        final dynamic responseBody = response.body;

        if (responseBody is String) {
          // If the response body is a string, try to decode it as JSON
          try {
            final Map<String, dynamic> errorData = json.decode(responseBody);

            if (errorData.containsKey('password')) {
              // Show password-related errors
              final List<String> passwordErrors =
                  List<String>.from(errorData['password']);
              passwordErrors.forEach((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            } else if (errorData.containsKey('error')) {
              // Show general error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorData['error']),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              showGenericErrorSnackbar(context);
            }
          } catch (e) {
            // If decoding as JSON fails, treat it as a plain string
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseBody),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          showGenericErrorSnackbar(context);
        }
      }
    } catch (error) {
      print('Error catch error: $error');
      showGenericErrorSnackbar(context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showGenericErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the entire user data as a JSON string
    prefs.setString('token', jsonEncode(userData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Create an account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  child: Column(
                    children: [
                      if (validationError.isNotEmpty)
                        Text(
                          validationError,
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 16),
                      buildInputField(
                        'Your Email',
                        'Email',
                        emailController,
                      ),
                      buildInputField(
                        'First Name',
                        'First name',
                        firstNameController,
                      ),
                      buildInputField(
                        'Last Name',
                        'Last name',
                        lastNameController,
                      ),
                      buildInputField(
                        'City',
                        'City',
                        cityController,
                      ),
                      buildInputField(
                        'Address',
                        'Address',
                        addressController,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isHealthcare,
                            onChanged: (value) {
                              setState(() {
                                isHealthcare = value!;
                              });
                            },
                          ),
                          Text("I am in the healthcare industry"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      buildInputField(
                        'Password',
                        '*********',
                        passwordController,
                        isPassword: true,
                      ),
                      buildInputField(
                        'Confirm Password',
                        '*********',
                        confirmPswdController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      buildTermsAndConditions(),
                      const SizedBox(height: 20),
                      buildElevatedButton(
                        'Create an Account',
                        () {
                          setState(() {
                            isLoading = true;
                          });
                          registerUser(context);
                        },
                      ),
                      const SizedBox(height: 20),
                      buildLoginLink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
    String label,
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
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
            obscureText: isPassword,
            decoration: InputDecoration(
              labelText: hintText,
              labelStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTermsAndConditions() {
    return GestureDetector(
      onTap: () {
        // Navigate to TermsAndConditions
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TermsAndConditions()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "By clicking Create an account, you agree to our ",
          style: const TextStyle(
            color: Colors.grey,
          ),
          children: [
            TextSpan(
              text: 'Terms and Conditions',
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        minimumSize: MaterialStateProperty.all<Size>(
          const Size(double.infinity, 48),
        ),
      ),
      child: isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
    );
  }

  Widget buildLoginLink() {
    return GestureDetector(
      onTap: () {
        // Navigate to LoginPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: const TextStyle(
            color: Colors.grey,
          ),
          children: [
            TextSpan(
              text: 'Login',
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
