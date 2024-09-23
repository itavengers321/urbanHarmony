import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_drawer.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});
  static const String routeName = '/ContactUsPage';

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
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
          'Contact Us',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Information
              Text(
                'Urban Harmony',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.0),

              // Email
              GestureDetector(
                onTap: () => _launchEmail('itavengers@aptechgdn.net'),
                child: Text(
                  'Email: itavengers@aptechgdn.net',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.lightBlue.withOpacity(0.6),
                  ),
                ),
              ),
              SizedBox(height: 10.0),

              // Contact Number
              Text(
                'Contact No: +92 348 0680203',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),

              // Address
              Text(
                'Address: Aptech Garden,\nKarachi, Sindh, 74700',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.0),

              
            ],
          ),
        ),
      ),
      );
  }
}


void _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('Subject: Inquiry about interior design services'),
    );
    await launchUrl(launchUri);
  }
