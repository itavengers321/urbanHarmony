import 'package:firebase_database/firebase_database.dart';

class DatabaseMethods {
  // Reference to the Firebase Realtime Database
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Method to add a product to the 'products' table
  Future<void> addProduct(Map<String, dynamic> product) async {
    // Create a new unique key under the 'products' node
    await databaseRef.child("products").push().set(product);
  }
}




class DatabaseMethodsGallery {
  // Reference to the Firebase Realtime Database
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Method to add a product to the 'products' table
  Future<void> addProduct(Map<String, dynamic> product) async {
    // Create a new unique key under the 'products' node
    await databaseRef.child("galleryDesigns").push().set(product);
  }
}
