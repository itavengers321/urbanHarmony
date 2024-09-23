import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/screens/Contact_Us.dart';
import '../widgets/custom_drawer.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});
  static const String routeName = '/AboutUsPage';

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  late String displayName;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
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
      drawer: CustNavigationDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'About Us',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                'Who We Are',
                style: TextStyle(
                  color: Colors.black, // Changed to black
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),

              // Description Paragraph
              Text(
                'We are a passionate team of innovators dedicated to bringing quality products and services to our customers. Our mission is to deliver excellence in every project we undertake. With years of experience, we strive to lead in our industry and make a positive impact in the community.',
                style: TextStyle(
                  color: Colors.black, // Changed to black
                  fontSize: 18.0,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.0),

              // First Image and Description
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/images/about3.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Our team is composed of skilled professionals who work tirelessly to meet and exceed expectations. We believe in collaboration, creativity, and innovation.',
                      style: TextStyle(
                        color: Colors.black, // Changed to black
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // Second Image and Description
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'We are committed to sustainability and ethical practices, ensuring that our operations benefit both the environment and society as a whole.',
                      style: TextStyle(
                        color: Colors.black, // Changed to black
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image(image: AssetImage('assets/images/about2.jpg',))
                      
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // Team Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  'assets/images/about1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20.0),

              // Conclusion Paragraph
              Text(
                'Join us on our journey as we continue to innovate, grow, and contribute to a better future. Together, we can make a difference!',
                style: TextStyle(
                  color: Colors.black, // Changed to black
                  fontSize: 18.0,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.0),

              // Call to Action (Optional)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ContactUsPage(), // Pass the correct designerUuid
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
