import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding Base64 images
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class viewSavedItems extends StatefulWidget {
  const viewSavedItems({super.key});
  static const String routeName = '/viewSavedItems';

  @override
  State<viewSavedItems> createState() => _viewSavedItemsState();
}

class _viewSavedItemsState extends State<viewSavedItems> {
  late String displayName;
  late String Useruuid;

  final List<savedItemsItems> SavedItemsP = [];
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('savedItemsFavourites');

  @override
  void initState() {
    super.initState();
    fetchSavedItems(); // Fetch data from Firebase
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName.toString();
      Useruuid = user.uid.toString();
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> fetchSavedItems() async {
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        SavedItemsP.clear(); // Clear the list before adding new items
      });
      data.forEach((key, value) {
        setState(() {
          if (value["uuid"] == Useruuid) {
            SavedItemsP.add(savedItemsItems(
              ProductName: value['ProductName'] ?? 'Unknown Name',
              ProductDescription:
                  value['ProductDescription']?.toString() ?? 'N/A',
              ProductPrice: value['ProductPrice'] ?? 'No price',
              imageBase64: value['ImageBase64'] ?? '',
              brand: value['brand'] ?? 'Unknown',
              productCategory: value['productCategory'] ?? 'Unknown',
              productkey: key, // Store the key for deletion
            ));
          }
        });
      });
    } else {
      print("No SavedItems found");
    }
  }

  Future<void> RemoveItem(String savkey) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("savedItemsFavourites/$savkey");
    await ref.remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Product Removed From 'Saved Items'",
          style: TextStyle(fontSize: 18),
        ),
      ));
      
      // Remove item from the list
      setState(() {
        SavedItemsP.removeWhere((item) => item.productkey == savkey);
      });

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Failed to delete item: $error",
          style: TextStyle(fontSize: 18),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Saved Items',
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
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Expanded(
                child: SavedItemsP.isEmpty
                    ? Center(
                        child: Text(
                          "No saved items found.",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ) // Show a message when no items are found
                    : ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: SavedItemsP.length,
                        itemBuilder: (context, index) {
                          return DesignerCard(
                            item: SavedItemsP[index],
                            onRemove: (key) => RemoveItem(key),
                            savedItemKey: SavedItemsP[index].productkey, // Pass correct key
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignerCard extends StatelessWidget {
  final savedItemsItems item;
  final Function(String) onRemove;
  final String savedItemKey; // Add this line

  DesignerCard({required this.item, required this.onRemove, required this.savedItemKey}); // Update constructor

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.white.withOpacity(0.6), // Semi-transparent card
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item.imageBase64.isNotEmpty
              ? Image.memory(base64Decode(item.imageBase64),
                  fit: BoxFit.cover, height: 200.0, width: double.infinity)
              : Image.asset('assets/default.jpg',
                  fit: BoxFit.cover,
                  height: 200.0,
                  width: double.infinity), // Default image
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.ProductName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Brand : ${item.brand}',
                style: TextStyle(color: Colors.black54)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Category: ${item.productCategory}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Description: ${item.ProductDescription}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Price : ${item.ProductPrice} RS.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green)),
            ),
          ),
          Container(
            child: Center(
              child: ElevatedButton(
                onPressed: () => onRemove(savedItemKey), // Use the passed key here
                child: Text('Remove'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 4, 4)),
              ),
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}

class savedItemsItems {
  final String productCategory;
  final String ProductDescription;
  final String ProductName;
  final String imageBase64;
  final String brand;
  final String ProductPrice;
  final String productkey;

  savedItemsItems({
    required this.productCategory,
    required this.ProductDescription,
    required this.ProductName,
    required this.imageBase64,
    required this.brand,
    required this.ProductPrice,
    required this.productkey,
  });
}
