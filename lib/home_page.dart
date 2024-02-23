import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: LandingPage(),
  ));
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meta tags and styles go here (not necessary in Flutter)
              // ...

              // Header
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/header-smartphone.png', // Replace with the actual image path
                      width: double.infinity,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Connect, Share, Engage A problem shared is half solved.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'We all have a choice in every decision we make daily. Mentspac is about being able to fully be yourself without having to be judged or pressured. Every decision you make should should be heard. We are here to listen and each and every voice and opinions matters. Be brave, be strong for each other and each step you take is a progress that changes lives forever.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Download IOS'),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          // primary: Colors.white,
                          ),
                      child: Text(
                        'Download Android',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              // Features
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Image.asset(
                    //   'assets/features-icon-1.svg', // Replace with the actual image path
                    //   width: double.infinity,
                    // ),
                    buildFeatureCard(
                        'Platform Integration',
                        'You sales force can use the app on any smartphone platform without compatibility issues',
                        'assets/features-icon-1.svg'),
                    buildFeatureCard(
                        'Easy On Resources',
                        'Works smoothly even on older generation hardware due to our optimization efforts',
                        'assets/features-icon-2.svg'),
                    buildFeatureCard(
                        'Great Performance',
                        'Optimized code and innovative technology insure no delays and ultra-fast responsiveness',
                        'assets/features-icon-3.svg'),
                    buildFeatureCard(
                        'Multiple Languages',
                        'Choose from one of the 40 languages that come pre-installed and start selling smarter',
                        'assets/features-icon-4.svg'),
                    buildFeatureCard(
                        'Free Updates',
                        "Don't worry about future costs, pay once and receive all future updates at no extra cost",
                        'assets/features-icon-5.svg'),
                    buildFeatureCard(
                        'Community Support',
                        'Register the app and get access to knowledge and ideas from the Pavo online community',
                        'assets/features-icon-6.svg'),
                  ],
                ),
              ),

              // Details Section 1
              Container(
                padding: EdgeInsets.all(16),
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
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Based on our team\'s extensive experience in developing line of business applications and constructive customer feedback we reached a new level of revenue.',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We enjoy helping small and medium sized tech businesses take a shot at established Fortune 500 companies',
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
                padding: EdgeInsets.all(16),
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
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildListItem(
                                  'Features that will help you and your marketers'),
                              buildListItem(
                                  'Smooth learning curve due to the knowledge base'),
                              buildListItem(
                                  'Ready out-of-the-box with minor setup settings'),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Lightbox'),
                              ),
                              SizedBox(width: 8),
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

              // Details Lightbox
              // (You can create a modal or navigate to a new screen for the lightbox content)

              // Details Section 3
              Container(
                padding: EdgeInsets.all(16),
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
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Get a glimpse of what this app can do for your marketing automation and understand why current users are so excited when using Pavo together with their teams.',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
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
                padding: EdgeInsets.all(16),
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
                padding: EdgeInsets.all(16),
                color: Colors.grey,
                child: Column(
                  children: [
                    Text(
                      'What do users think about Pavo',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    // You can use a Flutter carousel/slider package for this section
                    // Example: https://pub.dev/packages/carousel_slider
                    // (Make sure to replace the image paths accordingly)
                    // ...
                  ],
                ),
              ),

              // Pricing Section
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pricing options for all budgets',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Our pricing plans are setup in such a way that any user can start enjoying Pavo without worrying so much about costs. They are flexible and work for any type of industry',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 16),
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
                SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(String text) {
    return Row(
      children: [
        Icon(Icons.arrow_right),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget buildCounter(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}
