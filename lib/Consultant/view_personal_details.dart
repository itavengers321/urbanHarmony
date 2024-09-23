import 'dart:convert';
import 'dart:typed_data'; // For decoding Base64 string to bytes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/Consultant/consultant.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart'; // For Realtime Database

class ViewPersonaldetailsConsultant extends StatefulWidget {
  const ViewPersonaldetailsConsultant({super.key});
  static const String routeName = '/ViewPersonaldetailsConsultant';

  @override
  _ViewPersonaldetailsConsultantState createState() => _ViewPersonaldetailsConsultantState();
}

class _ViewPersonaldetailsConsultantState extends State<ViewPersonaldetailsConsultant> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? personal; // To store the personal details
  String? personalKey; // Store personal key
  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchDetails(); // Fetch personal details when the page loads

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

  // Function to fetch personal details from Realtime Database
  Future<void> fetchDetails() async {
    final ref = databaseReference.child('users'); // Assuming 'users' is the node
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final personalData = snapshot.value as Map<dynamic, dynamic>;

      personalData.forEach((key, value) {
        if (value["uuid"] == uuid) {
          setState(() {
            personal = {
              "displayName": value["displayName"],
              "email": value["email"],
              "mobile": value["mobile"],
              "city": value["city"],
              "address": value["address"],
            };
            personalKey = key; // Store the personal key
          });
        }
      });
    } else {
      print("No Personal Details found");
    }
  }

  // Function to navigate to the edit screen
  void navigateToEditPersonal() {
    if (personal != null && personalKey != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Editpersonal(personal: personal!, personalKey: personalKey!),
        ),
      ).then((value) {
        if (value == true) {
          fetchDetails(); // Refresh the personal details after editing
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'Personal Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: personal == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${personal!["displayName"]}', style: TextStyle(fontSize: 18)),
                        Text('Email: ${personal!["email"]}', style: TextStyle(fontSize: 18)),
                        Text('Mobile No: ${personal!["mobile"]}', style: TextStyle(fontSize: 18)),
                        Text('City: ${personal!["city"]}', style: TextStyle(fontSize: 18)),
                        Text('Address: ${personal!["address"]}', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: navigateToEditPersonal,
                            child: Text("Edit Details", style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                            ),
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

// Edit Personal Screen
class Editpersonal extends StatefulWidget {
  final Map<String, dynamic> personal;
  final String personalKey; 

  const Editpersonal({super.key, required this.personal, required this.personalKey});

  @override
  _EditPersonalState createState() => _EditPersonalState();
}

class _EditPersonalState extends State<Editpersonal> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namecontroller.text = widget.personal["displayName"];
    mobileController.text = widget.personal["mobile"];
    addressController.text = widget.personal["address"];
  }

  Future<void> updatePersonal() async {
    Map<String, dynamic> updatedPersonal = {
      "displayName": namecontroller.text,
      "mobile": mobileController.text,
      "address": addressController.text,
    };

    // Update the existing personal details using the correct reference
    await FirebaseDatabase.instance
        .ref('users/${widget.personalKey}') // Use personalKey instead of key
        .update(updatedPersonal);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ManageConsultantPage()), // Replace with your main page widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Personal Details'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.6), // Whitish
              Colors.lightBlue.withOpacity(0.6), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: namecontroller,
              style: TextStyle(color: Colors.black), // Adjust text color as needed
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.black), // Adjust label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Border when focused
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: mobileController,
              style: TextStyle(color: Colors.black), // Adjust text color as needed
              decoration: InputDecoration(
                labelText: "Mobile No",
                labelStyle: TextStyle(color: Colors.black), // Adjust label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Border when focused
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              style: TextStyle(color: Colors.black), // Adjust text color as needed
              decoration: InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(color: Colors.black), // Adjust label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Silverish border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Border when focused
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: updatePersonal,
                child: Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800], // Dark button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  textStyle: TextStyle(color: Colors.white), // Whitish text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
