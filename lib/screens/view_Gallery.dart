import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/screens/reviewImage.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});
  static const String routeName = '/GalleryPage';

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late String displayName;
  late String uuid;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  List<dynamic> galleryItems = [];
  List<dynamic> filteredGalleryItems = []; // For filtered gallery items
  bool isLoading = true;

  // Filter variables
  String? selectedRoomType = 'All';
  String? selectedTheme = 'All';
  String? selectedColorScheme = 'All';

  final List<String> roomTypes = ['All', 'Living Room', 'Bedroom', 'Kitchen', 'Bathroom', 'Others'];
  final List<String> themes = ['All', 'Modern', 'Rustic', 'Minimalist', 'Industrial' , 'Others'];
  final List<String> colorSchemes = ['All', 'Bold', 'Pastel','Dark', 'Neutral' , 'Others'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName ?? "Unknown User";
        uuid = user.uid;
      });
      fetchGalleryItems(); // Fetch gallery items when the page is initialized
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> fetchGalleryItems() async {
    final ref = databaseReference.child('galleryDesigns');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final productData = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        productData.forEach((key, value) {
          galleryItems.add({
            "prokey": value["prokey"],
            "ImageBase64": value["ImageBase64"],
            "tobeShown": value["tobeShown"],
            "roomType": value["roomType"],
            "theme": value["theme"],
            "colorScheme": value["colorScheme"],
          });
        });
        filteredGalleryItems = List.from(galleryItems); // Initially, all items are displayed
      });
    } else {
      print("No Designs found");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Apply filters based on room type, theme, and color scheme
  void applyFilter() {
    setState(() {
      filteredGalleryItems = galleryItems.where((item) {
        final matchesRoomType = selectedRoomType == 'All' || item['roomType'] == selectedRoomType;
        final matchesTheme = selectedTheme == 'All' || item['theme'] == selectedTheme;
        final matchesColorScheme = selectedColorScheme == 'All' || item['colorScheme'] == selectedColorScheme;
        return matchesRoomType && matchesTheme && matchesColorScheme;
      }).toList();
    });
  }

  Future<void> addToFavorites(String proKey, String image) async {
    final refSaved_Item = databaseReference.child('GalleryFavourites');
    final snapshotSaved_Item = await refSaved_Item.get();

    bool isAlreadySaved = false;

    if (snapshotSaved_Item.exists) {
      final savedItems_check = snapshotSaved_Item.value as Map<dynamic, dynamic>;

      savedItems_check.forEach((key, value) {
        if (value["imagekey"] == proKey && value["UserUuid"] == uuid) {
          isAlreadySaved = true;
          return;
        }
      });
    }

    if (isAlreadySaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Design already in 'My Designs'")),
      );
    } else {
      final saveData = {
        "UserUuid": uuid,
        "imagekey": proKey,
        "ImageBase64": image,
      };

      await databaseReference.child("GalleryFavourites").push().set(saveData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to My Gallery!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text('Design Gallery', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filter Dropdowns
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Room Type'),
                  value: selectedRoomType,
                  items: roomTypes
                      .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoomType = value;
                      applyFilter();
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Theme'),
                  value: selectedTheme,
                  items: themes
                      .map((theme) => DropdownMenuItem<String>(
                            value: theme,
                            child: Text(theme),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTheme = value;
                      applyFilter();
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Color Scheme'),
                  value: selectedColorScheme,
                  items: colorSchemes
                      .map((color) => DropdownMenuItem<String>(
                            value: color,
                            child: Text(color),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedColorScheme = value;
                      applyFilter();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredGalleryItems.isEmpty
                      ? Center(
                          child: Text(
                            'No designs in the gallery',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredGalleryItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredGalleryItems[index];
                            return Card(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.memory(
                                      base64Decode(item['ImageBase64']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        MaterialButton(
                                          color: Colors.blue,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReviewsPage(
                                                  productKey: item['prokey'],
                                                  productimage: item['ImageBase64'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Reviews',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        MaterialButton(
                                          color: Colors.orange,
                                          onPressed: () {
                                            addToFavorites(item['prokey'], item['ImageBase64']);
                                          },
                                          child: Text(
                                            'Add to Favorite',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
