

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileDao{
  final _databaseRef = FirebaseDatabase.instance.ref('users');

  Future<void> saveUser(UsersProfile users)async{
    try {
      //print("the current uuid is $uuid");
      await _databaseRef.push().set(users.toJson());
    } catch (error) {
      print ("error in saving user: $error");
    }
  }

// Method to search a UsersProfile by email
   Future<UsersProfile?> searchByEmail(String email) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
    final Query query = ref.orderByChild('email').equalTo(email);
    
    final DatabaseEvent event = await query.once();
    if (event.snapshot.exists) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
      final firstKey = data.keys.first;
      final userProfileData = data[firstKey] as Map<dynamic, dynamic>;
      return UsersProfile.fromJson(userProfileData);
    } else {
      return null;  // If no user is found
    }
}




Future<DataSnapshot> getUserProfile(String uid) async {
    final DatabaseEvent event = await _databaseRef.child(uid).once();
    return event.snapshot;
  }



// method modified with unique userid in order to display only user record
  Query getMessageQuery(String uuid){
     if(!kIsWeb){
        FirebaseDatabase.instance.setPersistenceEnabled(true);
     }
     return _databaseRef;
  }

  void updateUser({
    required String key,
    required String uuid,
    required UsersProfile users
  })async{
      try {
        await _databaseRef.child(uuid).child(key).update(users.toMap());
      } catch (error) {
        print("Error unable to update record");
      }
  }

}