import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class SingleProductView extends StatefulWidget {
  final String prodkey;

  const SingleProductView({super.key, required this.prodkey});

  @override
  _SingleProductViewState createState() => _SingleProductViewState();
}

class _SingleProductViewState extends State<SingleProductView> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? prod;
  String? productkey_original;
  final List<Map<String, dynamic>> reviewList = [];
  final TextEditingController reviewController = TextEditingController();

Map<String, dynamic>? savedItems_check;
  late String displayName;
  late String userUuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchReviews();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName ?? "Unknown User";
        userUuid = user.uid;
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(userUuid);
    connectedRef.keepSynced(true);
  }

  // Fetch product details
  Future<void> fetchProducts() async {
    final refProduct = databaseReference.child('products');
    final snapshotProduct = await refProduct.get();

    if (snapshotProduct.exists) {
      final prodData = snapshotProduct.value as Map<dynamic, dynamic>;

      prodData.forEach((key, value) {
        if (value["prokey"] == widget.prodkey) {
          setState(() {
            prod = {
              "ImageBase64": value["ImageBase64"],
              "ProductDescription": value["ProductDescription"],
              "ProductName": value["ProductName"],
              "ProductPrice": value["ProductPrice"],
              "brand": value["brand"],
              "productCategory": value["productCategory"],
            };

            productkey_original = key;
          });
        }
      });
    }
  }

  Future<void> fetchReviews() async {
    DatabaseReference ref = databaseReference.child("reviews_products");
    ref.orderByChild("productkey").equalTo(widget.prodkey).onValue.listen((event) {
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
        "uuid": userUuid,
        "productkey": widget.prodkey,
        "uName": displayName,
        "reply": "none",
        "ImageBase64": prod!["ImageBase64"],
        "ProductName": prod!["ProductName"],
      };

      await databaseReference.child("reviews_products").push().set(reviewData);
      reviewController.clear();
      fetchReviews(); 
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review added")));
    }
  }



  Future<void> saveItem() async {
  final refSaved_Item = databaseReference.child('savedItemsFavourites');
  final snapshotSaved_Item = await refSaved_Item.get();

  bool isAlreadySaved = false; // Track if the item is already saved

  if (snapshotSaved_Item.exists) {
    final savedItems_check = snapshotSaved_Item.value as Map<dynamic, dynamic>;

    // Check if the item is already saved
    savedItems_check.forEach((key, value) {
      if (value["productkey"] == widget.prodkey && value["uuid"] == userUuid) {
        isAlreadySaved = true; // Mark as already saved
        return; // Exit the loop early since we found a match
      }
    });
  }

  // If the item is already saved, show a message and do not save again
  if (isAlreadySaved) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product already in 'Saved Items'"))
    );
  } else {
    // Save the new item
    final saveData = {
      "uuid": userUuid,
      "productkey": widget.prodkey,
      "ImageBase64": prod!["ImageBase64"],
      "ProductDescription": prod!["ProductDescription"],
      "ProductName": prod!["ProductName"],
      "ProductPrice": prod!["ProductPrice"],
      "brand": prod!["brand"],
      "productCategory": prod!["productCategory"],
    };

    await databaseReference.child("savedItemsFavourites").push().set(saveData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item saved to 'Saved Items'"))
    );
  }
}



  

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildProductDetailsCard(),
                const SizedBox(height: 20),
                _buildReviewsSection(), // The reviews section
                const SizedBox(height: 20),
                _buildReviewInputSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Product details card
  Widget _buildProductDetailsCard() {
    return Card(
      color: Colors.white.withOpacity(0.9), // Transparent theme
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            prod != null
                ? Column(
                    children: [
                      Image.memory(
                        base64Decode(prod!["ImageBase64"]),
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        prod!["ProductName"],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Brand: ${prod!["brand"]}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Category: ${prod!["productCategory"]}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prod!["ProductDescription"],
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${prod!["ProductPrice"]} Rs.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        onPressed: saveItem,
                        child: const Text('Save Item'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // Reviews section
  Widget _buildReviewsSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Reviews',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        reviewList.isEmpty
            ? const Center(
                child: Text(
                  'No Reviews Yet',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            : SizedBox(
                height: 200, // Set a specific height for the reviews list
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: reviewList.length,
                  itemBuilder: (context, index) {
                    final review = reviewList[index];

                    return Card(
                      color: Colors.grey[800]?.withOpacity(0.7),
                      margin: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['review'] ?? 'No Review',
                              style: const TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Reviewer: ${review['uName'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 14.0, color: Colors.white70),
                            ),
                            const SizedBox(height: 10.0),
                            review['reply'] == "none"
                                ? const Text(
                                    'Not replied yet',
                                    style: TextStyle(fontSize: 14.0, color: Colors.redAccent),
                                  )
                                : Text(
                                    'Reply: ${review['reply'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 14.0, color: Colors.greenAccent),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Review input section
  Widget _buildReviewInputSection() {
    return Column(
      children: [
        TextField(
          controller: reviewController,
          decoration: const InputDecoration(
            labelText: 'Write a Review',
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: submitReview,
          child: const Text('Submit Review'),
        ),
      ],
    );
  }
}
