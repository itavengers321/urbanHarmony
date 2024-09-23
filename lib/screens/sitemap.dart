import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/screens/Contact_Us.dart';
import '../widgets/custom_drawer.dart';
import 'login_page.dart'; // Ensure to import your login page

class SitemapPage extends StatefulWidget {
  const SitemapPage({super.key});
  static const String routeName = '/sitemapPage';

  @override
  State<SitemapPage> createState() => _SitemapPageState();
}

class _SitemapPageState extends State<SitemapPage> {
  late String displayName;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName.toString();
    } else {
      displayName = "Unknown User";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen image using BoxFit.contain
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/siteMap.png'), // Update with your image path
                fit: BoxFit.contain, // Change to BoxFit.contain
              ),
            ),
          ),
          // Content overlay
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 20.0),
                  child: Text(
                    '    Site Map   \nUrban Harmony',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              // Additional content can be added here
            ],
          ),
          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, PageRoutes.lognPage);
              },
              child: Icon(Icons.login),
              backgroundColor: Colors.blue, // Customize color as needed
            ),
          ),
        ],
      ),
    );
  }
}
