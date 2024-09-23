import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class ViewDesigner extends StatefulWidget {
  final String designerUuid;

  const ViewDesigner({super.key, required this.designerUuid});

  @override
  _ViewDesignerState createState() => _ViewDesignerState();
}

class _ViewDesignerState extends State<ViewDesigner> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? prof;
  String? profKey;
  Map<String, dynamic>? personal;
  String? personalKey;
  final List<Map<String, dynamic>> projectList = [];
  final List<Map<String, dynamic>> reviewList = [];
  final TextEditingController reviewController = TextEditingController();

  late String displayName;
  late String Useruuid;
  bool hasDetails = true;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchDetails();
    fetchProjects();
    fetchReviews();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        Useruuid = user.uid.toString();
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(Useruuid);
    connectedRef.keepSynced(true);
  }

  Future<void> fetchProjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("DesignersProjects");
    ref.orderByChild("ConsultantUuid").equalTo(widget.designerUuid).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      setState(() {
        projectList.clear();
        if (data != null) {
          data.forEach((key, value) {
            final project = Map<String, dynamic>.from(value);
            project['projectKey'] = key;
            projectList.add(project);
          });
        }
      });
    });
  }

  Future<void> fetchDetails() async {
    final refProfessional = databaseReference.child('profDetailsDesigner');
    final snapshotProfessional = await refProfessional.get();

    if (snapshotProfessional.exists) {
      final profData = snapshotProfessional.value as Map<dynamic, dynamic>;
      bool detailsFound = false;

      profData.forEach((key, value) {
        if (value["DesignerUuid"] == widget.designerUuid) {
          setState(() {
            prof = {
              "fullName": value["fullName"],
              "YearsOfExp": value["YearsOfExp"],
              "specializationController": value["specializationController"],
              "ImageBase64": value["ImageBase64"],
            };
            profKey = key; 
            detailsFound = true; 
          });
        }
      });

      final refPersonal = databaseReference.child('users');
      final snapshotPersonal = await refPersonal.get();
      final personalData = snapshotPersonal.value as Map<dynamic, dynamic>;

      personalData.forEach((key, value) {
        if (value["uuid"] == widget.designerUuid) {
          setState(() {
            personal = {
              "email": value["email"],
              "mobile": value["mobile"],
              "address": value["address"],
              "city": value["city"],
            };
            personalKey = key;
          });
        }
      });

      if (!detailsFound) {
        setState(() {
          hasDetails = false; 
        });
      }
    } else {
      setState(() {
        hasDetails = false; 
      });
      print("No Professional Details found");
    }
  }

  Future<void> fetchReviews() async {
    DatabaseReference ref = databaseReference.child("reviews");
    ref.orderByChild("designerUuid").equalTo(widget.designerUuid).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      setState(() {
        reviewList.clear();
        if (data != null) {
          data.forEach((key, value) {
            final review = Map<String, dynamic>.from(value);
            review['key'] = key; 
            reviewList.add(review);
          });
        }
      });
    });
  }

  Future<void> submitReview() async {
    if (reviewController.text.isNotEmpty) {
      final reviewData = {
        "review": reviewController.text,
        "uuid": Useruuid,
        "designerUuid": widget.designerUuid,
        "uName": displayName,
        "reply": "none",
      };

      await databaseReference.child("reviews").push().set(reviewData);
      reviewController.clear();
      fetchReviews(); // Refresh the reviews list after submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Designer's Profile",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8), // Whitish background
              Colors.lightBlue.withOpacity(0.8), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: hasDetails
            ? (prof == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Professional and personal details card
                          Card(
                            elevation: 4.0,
                            color: Colors.white.withOpacity(0.6), // Semi-transparent card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: prof != null && prof!["ImageBase64"] != null
                                          ? Image.memory(
                                              base64Decode(prof!["ImageBase64"]),
                                              height: 200,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: 200,
                                              width: 200,
                                              color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      prof?["fullName"] ?? "Unknown",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Years Of Experience: ${prof?["YearsOfExp"] ?? "N/A"} Years',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Specialization: ${prof?["specializationController"] ?? "N/A"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Email: ${personal?["email"] ?? "N/A"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Contact No: ${personal?["mobile"] ?? "N/A"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Address: ${personal?["address"] ?? "N/A"}, ${personal?["city"] ?? "N/A"}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Center(
                            child: Text(
                              'Projects',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          projectList.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Projects Found',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: projectList.length,
                                  itemBuilder: (context, index) {
                                    final project = projectList[index];

                                    return Card(
                                      color: Colors.white.withOpacity(0.6), // Semi-transparent project card
                                      margin: EdgeInsets.all(10.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                    child: _buildProjectImage(
                                                        project['Image1Base64'])),
                                                Flexible(
                                                    child: _buildProjectImage(
                                                        project['Image2Base64'])),
                                              ],
                                            ),
                                            SizedBox(height: 10.0),
                                            Text(
                                              project['projectName'] ?? 'No Name',
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  color: const Color.fromARGB(
                                                      255, 16, 13, 13),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 10.0),
                                            Text(
                                              project['projectDescription'] ?? 'No Description',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: const Color.fromARGB(
                                                      255, 32, 27, 27)),
                                            ),
                                            SizedBox(height: 10.0),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                          SizedBox(height: 20),

                          Center(
                            child: Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          reviewList.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Reviews Yet',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: reviewList.length,
                                  itemBuilder: (context, index) {
                                    final review = reviewList[index];

                                    return Card(
                                      color: Colors.grey[800]?.withOpacity(0.7), // Semi-transparent review card
                                      margin: EdgeInsets.all(10.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review['review'] ?? 'No Review',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(height: 10.0),
                                            Text(
                                              'Reviewer: ${review['uName'] ?? 'Unknown'}',
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.white70),
                                            ),
                                            SizedBox(height: 10.0),
                                            review['reply'] == "none"
                                                ? Text(
                                                    'Not replied yet',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.redAccent),
                                                  )
                                                : Text(
                                                    'Reply: ${review['reply'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.greenAccent),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                          SizedBox(height: 20),

                          TextField(
                            controller: reviewController,
                            decoration: InputDecoration(
                              labelText: 'Write a Review',
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: submitReview,
                            child: Text('Submit Review'),
                          ),
                        ],
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
                  ],
                ),
              ),
      ),
    );
  }
}

Widget _buildProjectImage(String? base64Image) {
  return Container(
    height: 150,
    width: 150,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: base64Image != null
        ? Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.cover,
          )
        : Icon(Icons.broken_image, color: Colors.white),
  );
}
