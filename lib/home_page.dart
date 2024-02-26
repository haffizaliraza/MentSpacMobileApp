import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

void main() {
  runApp(const MaterialApp(
    home: LandingPage(),
  ));
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  // Function to sign the user out
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Set your desired color
          title: Text(
            'MentSpac',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                signUserOut(context);
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/header-smartphone.png', // Replace with the actual image path
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connect, Share, Engage A problem shared is half solved.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We all have a choice in every decision we make daily. Mentspac is about being able to fully be yourself without having to be judged or pressured. Every decision you make should be heard. We are here to listen and each and every voice and opinion matters. Be brave, be strong for each other and each step you take is a progress that changes lives forever.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Download IOS'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(),
                      child: Text(
                        'Download Android',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Features Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    buildFeatureCard(
                      'Platform Integration',
                      'Your sales force can use the app on any smartphone platform without compatibility issues',
                      'assets/features-icon-1.svg',
                    ),
                    buildFeatureCard(
                      'Easy On Resources',
                      'Works smoothly even on older generation hardware due to our optimization efforts',
                      'assets/features-icon-2.svg',
                    ),
                    buildFeatureCard(
                      'Great Performance',
                      'Optimized code and innovative technology ensure no delays and ultra-fast responsiveness',
                      'assets/features-icon-3.svg',
                    ),
                    buildFeatureCard(
                      'Multiple Languages',
                      'Choose from one of the 40 languages that come pre-installed and start selling smarter',
                      'assets/features-icon-4.svg',
                    ),
                    buildFeatureCard(
                      'Free Updates',
                      "Don't worry about future costs, pay once and receive all future updates at no extra cost",
                      'assets/features-icon-5.svg',
                    ),
                    buildFeatureCard(
                      'Community Support',
                      'Register the app and get access to knowledge and ideas from the Pavo online community',
                      'assets/features-icon-6.svg',
                    ),
                  ],
                ),
              ),

              // Details Section 1
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Results driven ground breaking technology',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on our team\'s extensive experience in developing line of business applications and constructive customer feedback, we reached a new level of revenue.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We enjoy helping small and medium-sized tech businesses take a shot at established Fortune 500 companies',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/details-1.jpg', // Replace with the actual image path
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),

              // Details Section 2
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/details-2.jpg', // Replace with the actual image path
                        width: double.infinity,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instant results for the marketing department',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildListItem(
                                'Features that will help you and your marketers',
                              ),
                              buildListItem(
                                'Smooth learning curve due to the knowledge base',
                              ),
                              buildListItem(
                                'Ready out-of-the-box with minor setup settings',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Lightbox'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {},
                                child: Text('Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details Section 3
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platform integration and lifetime free updates',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get a glimpse of what this app can do for your marketing automation and understand why current users are so excited when using Pavo together with their teams.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We will promptly answer any questions and honor your requests based on the service level agreement',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/details-3.jpg', // Replace with the actual image path
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),

              // Counter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCounter('Happy Users', 231),
                    buildCounter('Issues Solved', 385),
                    buildCounter('Good Reviews', 159),
                    buildCounter('Case Studies', 127),
                    buildCounter('Orders Received', 211),
                  ],
                ),
              ),

              // Slider Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey,
                child: Column(
                  children: [
                    Text(
                      'What do users think about Pavo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // You can use a Flutter carousel/slider package for this section
                    // Example: https://pub.dev/packages/carousel_slider
                    // (Make sure to replace the image paths accordingly)
                    // ...
                  ],
                ),
              ),

              // Pricing Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pricing options for all budgets',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our pricing plans are set up in such a way that any user can start enjoying Pavo without worrying so much about costs. They are flexible and work for any type of industry',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Pricing cards go here
                    // ...
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build feature card
  Widget buildFeatureCard(String title, String description, String imagePath) {
    return Card(
      child: Column(
        children: [
          Image.asset(
            imagePath, // Replace with the actual image path
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build list item
  Widget buildListItem(String text) {
    return Row(
      children: [
        Icon(Icons.arrow_right),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // Function to build counter
  Widget buildCounter(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}
