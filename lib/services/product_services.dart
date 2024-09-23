import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ProductServiceDao{
  final _databaseRef = FirebaseDatabase.instance.ref('products');

  // method modified with unique userid in order to display only user record
  Query getMessageQuery(){
     if(!kIsWeb){
        FirebaseDatabase.instance.setPersistenceEnabled(true);
     }
     return _databaseRef;
  }

}