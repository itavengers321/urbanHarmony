import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/cart.dart';

class CartDao{
  final _databaseRef = FirebaseDatabase.instance.ref('cart');

  Query getMessageQuery (String uid){
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
    return _databaseRef.child(uid);
  }

  Future<void> saveToCart(Cart cart, String? uid)async{
    try {
      if (uid!=null) {
        await _databaseRef.child(uid.toString()).push().set(cart.toJson());
      }
    } catch (error) {
      print("Error in saving record");
    }
  }

  Future<void> deleteCart(String? key, String? uid)async{
    try {
      if (uid!=null && key !=null) {
        await _databaseRef.child(uid).child(key).remove();
      }else{
        print("Key or UID cannot be null");
      }
    } catch (error) {
      print("Error in deleting record");
    }
  }
  

   Future<void> updateCart(String? key, String? uid, Cart cart)async{
    try {
      if (uid!=null && key !=null) {
        await _databaseRef.child(uid).child(key).update(cart.toMap());
      }else{
        print("Key or UID cannot be null");
      }
    } catch (error) {
      print("Error in deleting record");
    }
  }

  Future<int> getTotalCartItemsCount(String uid)async{
    try {
      DataSnapshot snapshot = await _databaseRef.child(uid).get();
      if (snapshot.exists) {
        return snapshot.children.length;
      }else{
        return 0;
      }
    } catch (error) {
      print("No Item found");
      return 0;
    }
    
    //return 0;
  }

Future<void> deleteAllCartItems(String uid) async {
    try {
      await _databaseRef.child(uid).remove();
    } catch (error) {
      print("Error in deleting all cart items");
    }
  }

}