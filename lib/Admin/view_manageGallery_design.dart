import 'dart:convert';
import 'dart:typed_data'; // For decoding Base64 string to bytes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/Admin/adminpage.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart'; // For Realtime Database

class ViewManagegalleryDesign extends StatefulWidget {
  const ViewManagegalleryDesign({super.key});
  static const String routeName = '/ViewManagegalleryDesign';
  
  @override
  _ViewManagegalleryDesignState createState() => _ViewManagegalleryDesignState();
}

class _ViewManagegalleryDesignState extends State<ViewManagegalleryDesign> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> products = [];
  List<String> productKeys = []; // To store product keys
  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();
  final DatabaseReference _galleryRef = FirebaseDatabase.instance.ref('galleryDesigns');
  
  bool hasDesigns = false; // New variable to track if designs exist

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Fetch products when the page loads

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

  // Function to fetch products from Realtime Database
  Future<void> fetchProducts() async {
    final ref = databaseReference.child('galleryDesigns'); // Assuming 'products' is the node
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final productData = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        products.clear();
        productKeys.clear(); // Clear existing keys
        productData.forEach((key, value) {
          products.add({
            "prokey": value["prokey"],
            "ImageBase64": value["ImageBase64"], // Add the base64 image string
            "tobeShown": value["tobeShown"],
          });
          productKeys.add(key); // Store the product key
        });
        hasDesigns = products.isNotEmpty; // Update the hasDesigns variable
      });
    } else {
      print("No Designs found");
      setState(() {
        hasDesigns = false; // Set to false if no designs found
      });
    }
  }

  // Function to delete a product
  Future<void> deleteProduct(String key) async {
    await databaseReference.child('galleryDesigns/$key').remove();
    setState(() {
      products.removeAt(productKeys.indexOf(key));
      productKeys.remove(key);
      hasDesigns = products.isNotEmpty; // Update hasDesigns
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Design Deleted successfully!"),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewManagegalleryDesign()),
    );
  }

  Future<void> _tobeNotvisible(String key) async {
    await _galleryRef.child(key).update({'tobeShown': 'no'});
    fetchProducts(); // Refresh the consultations list after update
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Design: Hide from Gallery')));
  }

  Future<void> _tobevisible(String key) async {
    await _galleryRef.child(key).update({'tobeShown': 'yes'});
    fetchProducts(); // Refresh the consultations list after update
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Design: Shown from Gallery')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'View/Manage Gallery Designs',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: !hasDesigns
          ? Center(child: Text('No Designs found.' , style: TextStyle(fontSize: 20),))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final key = productKeys[index];

                // Decode Base64 image back to bytes
                Uint8List imageBytes = base64Decode(product["ImageBase64"]);

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the image from the decoded bytes
                        Center(
                          child: Image.memory(
                            imageBytes,
                            height: 250,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (product["tobeShown"] == 'yes')
                              TextButton(
                                onPressed: () => _tobeNotvisible(key),
                                child: Text("Hide from Gallery"),
                              ),
                            if (product["tobeShown"] == 'no')
                              TextButton(
                                onPressed: () => _tobevisible(key),
                                child: Text("Show in Gallery"),
                              ),
                            SizedBox(width: 10),
                            TextButton(
                              onPressed: () => deleteProduct(key),
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
