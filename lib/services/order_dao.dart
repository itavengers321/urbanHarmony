import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/models/order.dart';


class OrdersDao{
  final _databaseRef = FirebaseDatabase.instance.ref("orders");

  void saveOrder(Order order){
     _databaseRef.push().set(order.toJson());
  }
  Query getMessageQuery() {

    if(!kIsWeb){
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }


    return _databaseRef;
  }

 Query getOrdersByUuid(String uuid) {
    return _databaseRef.orderByChild('uuid').equalTo(uuid);
  }




  void deleteOrder(String key){
    _databaseRef.child(key).remove();

  }
  void updateOrder(String key, Order order){
    _databaseRef.child(key).update(order.toMap());
  }



  
  //  Future<List<Order>> fetchOrdersByUuid(String uuid) async {
  //   final query = getOrdersByUuid(uuid);
  //   final event = await query.once();
  //   final orders = <Order>[];

  //   for (final snapshot in event.snapshot.children) {
  //     orders.add(Order.fromSnapshot(snapshot));
  //   }

  //   return orders;
  // }

Future<List<Order>> fetchOrdersByUuid(String uuid) async {
  final query = getOrdersByUuid(uuid);
  final event = await query.once();
  final orders = <Order>[];

  for (final snapshot in event.snapshot.children) {
    orders.add(Order.fromSnapshot(snapshot));
  }

  // Sort orders by date in descending order
  orders.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));

  return orders;
}


}
