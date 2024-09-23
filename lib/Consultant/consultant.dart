import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import '../models/user_profile.dart';
import '../widgets/beveled_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageConsultantPage extends StatefulWidget {
  const ManageConsultantPage({super.key});
  static const String routeName = '/ManageConsultantPage';

  @override
  State<ManageConsultantPage> createState() => _ManageConsultantPageState();
}

class _ManageConsultantPageState extends State<ManageConsultantPage> {
  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();
  final String email = 'itavengers@aptechgdn.net'; // Your email address

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        uuid = user.uid.toString();
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(uuid);
    connectedRef.keepSynced(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Designer Portal',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
              ],
            ),

            // About Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Urban Harmony',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'At Urban Harmony, we believe in transforming interiors into beautiful, functional spaces. Our designers create rooms that reflect your personal taste, lifestyle, and needs, blending modern aesthetics with comfort and elegance.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 30),

                  // Services Section
                  Text(
                    'Explore Our Designer Portal Features:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Grid of Features
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _featureCard(Icons.palette, 'Design Gallery'),
                      _featureCard(Icons.assignment, 'Project Planner'),
                      _featureCard(Icons.auto_awesome, 'Virtual Try-On'),
                      _featureCard(Icons.store, 'Shop Decor'),
                    ],
                  ),
                ],
              ),
            ),

            // Email Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Have a project in mind?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Feel free to reach out to us at:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _launchEmail(email),
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create feature cards
  Widget _featureCard(IconData icon, String title) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch the email client
  void _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('Subject: Inquiry about interior design services'),
    );
    await launchUrl(launchUri);
  }
}
