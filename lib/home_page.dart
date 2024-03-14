import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'about_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          backgroundColor: Colors.teal[100],
          title: Text(
            'MentSpac',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 100,
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
                title: Text('Groups'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllGroups()),
                  );
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  signUserOut(context);
                },
              ),
            ],
          ),
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
                          // const SizedBox(height: 8),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     buildListItem(
                          //       'Features that will help you and your marketers',
                          //     ),
                          //     buildListItem(
                          //       'Smooth learning curve due to the knowledge base',
                          //     ),
                          //     buildListItem(
                          //       'Ready out-of-the-box with minor setup settings',
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 8),
                          Text(
                            'Features that will help you and your marketers',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smooth learning curve due to the knowledge base',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ready out-of-the-box with minor setup settings',
                            style: TextStyle(fontSize: 16),
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCounter('Happy Users', 231),
                    buildCounter('Issues Solved', 385),
                    buildCounter('Good Reviews', 159),
                    // buildCounter('Case Studies', 127),
                    // buildCounter('Orders Received', 211),
                  ],
                ),
              ),

              // Slider Section
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey[500],
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
                    // Add the carousel/slider here
                    TestimonialsCarousel(),
                  ],
                ),
              ),

              // Pricing Section
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blueGrey[500],
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
                    PricingCard(
                      title: 'STANDARD',
                      price: '\$29',
                      frequency: 'monthly',
                      description:
                          'This basic package covers the marketing needs of small startups',
                    ),
                    const SizedBox(height: 16),
                    PricingCard(
                      title: 'ADVANCED',
                      price: '\$39',
                      frequency: 'monthly',
                      description:
                          'This is a more advanced package suited for medium companies',
                    ),
                    const SizedBox(height: 16),
                    PricingCard(
                      title: 'COMPLETE',
                      price: '\$49',
                      frequency: 'monthly',
                      description:
                          'This is a comprehensive package designed for big organizations',
                    ),
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
  Widget buildFeatureCard(String title, String description, String svgPath) {
    return Card(
      child: Column(
        children: [
          SvgPicture.asset(
            svgPath, // Check if this path is correct
            height: 50,
            color: Color.fromARGB(255, 205, 31, 221),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
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

class TestimonialsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: [
        // Add your testimonial items here
        buildTestimonialCard(
            'Jude Thorn - Designer',
            "It's been so fun to work with Pavo, I've managed to integrate it properly into my business flow and it's great",
            'testimonial-1.jpg'),
        buildTestimonialCard(
            'Roy Smith - Developer',
            "We were so focused on launching as many campaigns as possible that we've forgotten to target our loyal customers",
            'testimonial-2.jpg'),
        buildTestimonialCard(
            'Marsha Singer - Marketer',
            "I've been searching for a tool like Pavo for so long. I love the reports it generates and the amazing high accuracy",
            'testimonial-3.jpg'),
      ],
    );
  }

  Widget buildTestimonialCard(
      String title, String description, String imagePath) {
    return Container(
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            stops: [0.1, 0.9],
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget PricingCard({
  required String title,
  required String price,
  required String frequency,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          frequency,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          child: Text('Download'),
        ),
      ],
    ),
  );
}
