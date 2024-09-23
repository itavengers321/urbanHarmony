import 'dart:convert'; // Required to decode base64 string.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class ReviewsPage extends StatefulWidget {
  final String productKey;
  final String productimage; // Base64 string of the product image

  const ReviewsPage({
    Key? key,
    required this.productKey,
    required this.productimage,
  }) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late String displayName;
  late String Useruuid;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  final List<Map<String, dynamic>> reviewList = [];
  final TextEditingController reviewController = TextEditingController();
  bool hasDetails = true;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
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

  Future<void> fetchReviews() async {
    DatabaseReference ref = databaseReference.child("reviews_gallery");
    ref
        .orderByChild("imagekey")
        .equalTo(widget.productKey)
        .onValue
        .listen((event) {
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
        "Uuid": Useruuid,
        "imagekey": widget.productKey,
        "uName": displayName,
        "reply": "none",
        'ImageBase64': widget.productimage, // Use the product image
      };

      await databaseReference.child("reviews_gallery").push().set(reviewData);
      reviewController.clear();
      fetchReviews(); // Refresh the reviews list after submission
    }
  }

  // Convert base64 string to Image widget
  Widget imageFromBase64String(String base64String) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        height: 200, // Adjust image height as needed
        width: double.infinity,
      );
    } catch (e) {
      return SizedBox.shrink(); // If the image fails to load, return empty widget.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
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
        child: Column(
          children: [
            // Product Image Section
            imageFromBase64String(widget.productimage),
            SizedBox(height: 20),
            // Reviews Section Title
            Center(
              child: Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Reviews List Section
            Expanded(
              child: reviewList.isEmpty
                  ? Center(
                      child: Text(
                        'No Reviews Yet',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reviewList.length,
                      itemBuilder: (context, index) {
                        final review = reviewList[index];
                        return Card(
                          color: Colors.grey[800]?.withOpacity(0.7),
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
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Reviewer: ${review['uName'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                review['reply'] == "none"
                                    ? Text(
                                        'Not replied yet',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.redAccent,
                                        ),
                                      )
                                    : Text(
                                        'Reply: ${review['reply'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            // Review Submission Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      labelText: 'Write a Review',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: submitReview,
                  child: Text('Submit Review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
