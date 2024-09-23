import 'package:firebase_database/firebase_database.dart';

class DatabaseMethods_prof {
  // Reference to the Firebase Realtime Database
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Method to add a product to the 'products' table
  Future<void> addprofessionalDeatils(Map<String, dynamic> profDetails) async {
    // Create a new unique key under the 'products' node
    await databaseRef.child("profDetailsDesigner").push().set(profDetails);
  }
}





class DatabaseMethods_project {
  // Reference to the Firebase Realtime Database
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Method to add a product to the 'products' table
  Future<void> addprojectDetails(Map<String, dynamic> projectDetails) async {
    // Create a new unique key under the 'products' node
    await databaseRef.child("DesignersProjects").push().set(projectDetails);
  }
}
