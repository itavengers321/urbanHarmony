import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/Consultant/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class ReviewsSectionConsultant extends StatefulWidget {
  const ReviewsSectionConsultant({super.key});
  static const String routeName = '/ReviewsSectionConsultant';

  @override
  State<ReviewsSectionConsultant> createState() =>
      _ReviewsSectionConsultantState();
}

class _ReviewsSectionConsultantState extends State<ReviewsSectionConsultant> {
  late String displayName;
  late String uuid;

  final List<Map<String, dynamic>> reviewList = [];
  final TextEditingController reviewController = TextEditingController();
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('reviews');

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
        uuid = user.uid.toString();
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(uuid);
    connectedRef.keepSynced(true);
  }

  Future<void> fetchReviews() async {
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
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
    }
  }

  Future<void> updateReply(String key, String reply , String reviewer) async {
    await databaseReference.child(key).update({'reply': reply});
    fetchReviews(); // Refresh the reviews after update
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Replied to ${reviewer}')));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ConsultantCustomDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          "Profile's Reviews",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: reviewList.isEmpty
            ? Center(child: Text('No reviews found.'))
            : ListView.builder(
                itemCount: reviewList.length,
                itemBuilder: (context, index) {
                  final review = reviewList[index];
                  final String reviewKey = review['key'];
                  final String reviewText = review['review'] ?? 'No review text';
                  final String replyText = review['reply'] ?? '';
                  final String reviewer = review['uName'] ?? '';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewText,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            reviewer,
                            style: TextStyle(fontSize: 10 , color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Reply: $replyText',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: reviewController,
                            decoration: InputDecoration(
                              labelText: 'Write your reply',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (reviewController.text.isNotEmpty) {
                                updateReply(reviewKey, reviewController.text,reviewer);
                                reviewController.clear(); // Clear the input after sending
                              }
                            },
                            child: Text(replyText == 'none' ? 'Send Reply' : 'Update Reply'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
