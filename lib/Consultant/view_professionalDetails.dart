import 'dart:convert';
import 'dart:typed_data'; // For decoding Base64 string to bytes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/Consultant/consultant.dart';
import 'package:flutter_project_2208e/Consultant/create_professional_details.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart'; // For Realtime Database

class ViewProfessionaldetails extends StatefulWidget {
  const ViewProfessionaldetails({super.key});
  static const String routeName = '/ViewProfessionaldetails';
  
  @override
  _ViewProfessionaldetailsState createState() => _ViewProfessionaldetailsState();
}

class _ViewProfessionaldetailsState extends State<ViewProfessionaldetails> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? prof; // To store the product with price 600
  String? profKey; // Store product key for the single product
  late String displayName;
  late String uuid;
  bool hasDetails = true; // Flag to check if details exist
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchDetails(); // Fetch the product when the page loads

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

  // Function to fetch the product from Realtime Database
  Future<void> fetchDetails() async {
    final ref = databaseReference.child('profDetailsDesigner');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final profData = snapshot.value as Map<dynamic, dynamic>;
      bool detailsFound = false;

      profData.forEach((key, value) {
        if (value["DesignerUuid"] == uuid) {
          setState(() {
            prof = {
              "fullName": value["fullName"],
              "YearsOfExp": value["YearsOfExp"],
              "specializationController": value["specializationController"],
              "ImageBase64": value["ImageBase64"],
            };
            profKey = key; // Store the product key
            detailsFound = true; // Details found
          });
        }
      });

      if (!detailsFound) {
        setState(() {
          hasDetails = false; // No details found
        });
      }
    } else {
      setState(() {
        hasDetails = false; // No details found
      });
      print("No Professional Details found");
    }
  }

  // Function to navigate to the edit screen
  void navigateToEditProf() {
    if (prof != null && profKey != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProf(prof: prof!, profKey: profKey!),
        ),
      ).then((value) {
        if (value == true) {
          fetchDetails(); // Refresh the product after editing
        }
      });
    }
  }

  // Function to navigate to the add professional details page
  void navigateToAddProf() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => create_profileConsultant()),
    ).then((value) {
      if (value == true) {
        fetchDetails(); // Refresh the page after adding details
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Professional Profile Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: hasDetails
          ? (prof == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  base64Decode(prof!["ImageBase64"]),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Text(
                                prof!["fullName"],
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Years Of Experience: ${prof!["YearsOfExp"]} Years',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Specialization: ${prof!["specializationController"]}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: navigateToEditProf,
                                      child: Text(
                                        "Edit Details",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No Professional Details Found',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: navigateToAddProf,
                    child: Text(
                      "Add Professional Details",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 67, 132),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Edit Product Screen
class EditProf extends StatefulWidget {
  final Map<String, dynamic> prof;
  final String profKey;

  const EditProf({super.key, required this.prof, required this.profKey});

  @override
  _EditProfState createState() => _EditProfState();
}

class _EditProfState extends State<EditProf> {
  TextEditingController fullNamecontroller = TextEditingController();
  TextEditingController YearsOfExpController = TextEditingController();
  TextEditingController specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fullNamecontroller.text = widget.prof["fullName"];
    YearsOfExpController.text = widget.prof["YearsOfExp"];
    specializationController.text = widget.prof["specializationController"];
  }

  Future<void> updateProf() async {
    Map<String, dynamic> updatedProf = {
      "fullName": fullNamecontroller.text,
      "YearsOfExp": YearsOfExpController.text,
      "specializationController": specializationController.text,
      "ImageBase64": widget.prof["ImageBase64"], // Keep the same image
    };

    // Update the existing product using the correct reference
    await FirebaseDatabase.instance
        .ref('profDetailsDesigner/${widget.profKey}') // Use productKey instead of key
        .update(updatedProf);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ManageConsultantPage()), // Replace MainPage with your actual main page widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Professional Details'),
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
              controller: fullNamecontroller,
              style: TextStyle(color: Colors.black), // Adjust text color as needed
              decoration: InputDecoration(
                labelText: "Full Name",
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
              controller: YearsOfExpController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Years Of Experience",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: specializationController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Specialization",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: updateProf,
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
