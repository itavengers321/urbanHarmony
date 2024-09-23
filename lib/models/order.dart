
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_project_2208e/models/cart.dart';

// class Order{
//   late String uuid;
//   late String contacName;
//   late String address;
//   late String mobile;
//   late String city;
//   late String email;
//   late String orderDate;
//   late double amount;
//   late List<Cart> orderDetail;
//   late String status; //delivered, cancelled, pending, dispatched, aproved
//   late String comments;

//  DateTime get orderDateTime => DateTime.parse(orderDate); // Ensure the format is parsable


//   Order({
//     required this.uuid,
//     required this.contacName,
//     required this.address,
//     required this.mobile,
//     required this.city,    
//     required this.email,
//     required this.orderDate,
//     required this.amount,
//     required this.orderDetail,
//     required this.status,
//     required this.comments
//   });

//   Order.fromJson(Map<dynamic, dynamic> json)
//       : 
//         uuid = json['uuid'] as String,
//         contacName = json['contacName'] as String,
//         address = json['address'] as String,
//         mobile = json['mobile'] as String,
//         city = json['city'] as String,
//         email = json['email'] as String,
//         orderDate = json['orderDate'] as String,
//         amount = (json['amount'] is int)
//             ? (json['amount'] as int).toDouble()
//             : json['amount'] as double,
//         orderDetail = (json['orderDetail'] as List<dynamic>).map((cart)=>Cart.fromJson(cart)).toList(),
//         status = json['status'] as String;
  
//   Map<dynamic,dynamic> toJson() => <dynamic,dynamic>{
//         'uuid':uuid,
//         'contacName' :contacName,
//         'address' : address,
//         'mobile' : mobile,
//         'city' : city,
//         'email' : email,
//         'orderDate' : orderDate,
//         'amount' : amount,
//         'orderDetail' : orderDetail.map((cart)=>cart.toJson()).toList(),
//         'status' : status
//   };

//   Map<String,dynamic> toMap() => <String,dynamic>{
//         'uuid':uuid,
//         'contacName' :contacName,
//         'address' : address,
//         'mobile' : mobile,
//         'city' : city,
//         'email' : email,
//         'orderDate' : orderDate,
//         'amount' : amount,
//         'orderDetail' : orderDetail.map((cart)=>cart.toJson()).toList(),
//         'status' : status
//   };
//  Order.fromSnapshot(DataSnapshot snapshot)
//       : uuid = snapshot.child('uuid').value as String? ?? '',
//         contacName = snapshot.child('contacName').value as String? ?? '',
//         address = snapshot.child('address').value as String? ?? '',
//         mobile = snapshot.child('mobile').value as String? ?? '',
//         city = snapshot.child('city').value as String? ?? '',
//         email = snapshot.child('email').value as String? ?? '',
//         orderDate = snapshot.child('orderDate').value as String? ?? '',
//         amount = (snapshot.child('amount').value as num?)?.toDouble() ?? 0.0,
//         orderDetail = (snapshot.child('orderDetail').value as List<dynamic>?)
//             ?.map((item) => Cart.fromJson(item))
//             .toList() ?? [],
//         status = snapshot.child('status').value as String? ?? '',
//         comments = snapshot.child('comments').value as String? ?? '';


        
  
// }


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/models/cart.dart';

class Order {
  late String uuid;
  late String contacName;
  late String address;
  late String mobile;
  late String city;
  late String email;
  late String orderDate;
  late double amount;
  late List<Cart> orderDetail;
  late String status; //delivered, cancelled, pending, dispatched, approved
  late String comments;

  DateTime get orderDateTime => DateTime.parse(orderDate); // Ensure the format is parsable

  Order({
    required this.uuid,
    required this.contacName,
    required this.address,
    required this.mobile,
    required this.city,
    required this.email,
    required this.orderDate,
    required this.amount,
    required this.orderDetail,
    required this.status,
    required this.comments,
  });

  Order.fromJson(Map<dynamic, dynamic> json)
      : uuid = json['uuid'] as String, // Fixed typo here
        contacName = json['contacName'] as String,
        address = json['address'] as String,
        mobile = json['mobile'] as String,
        city = json['city'] as String,
        email = json['email'] as String,
        orderDate = json['orderDate'] as String,
        amount = (json['amount'] is int)
            ? (json['amount'] as int).toDouble()
            : json['amount'] as double,
        orderDetail = (json['orderDetail'] as List<dynamic>).map((cart) => Cart.fromJson(cart)).toList(),
        status = json['status'] as String,
        comments = json['comments'] as String; // Added missing assignment
  
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'uuid': uuid,
        'contacName': contacName,
        'address': address,
        'mobile': mobile,
        'city': city,
        'email': email,
        'orderDate': orderDate,
        'amount': amount,
        'orderDetail': orderDetail.map((cart) => cart.toJson()).toList(),
        'status': status,
        'comments': comments,
  };


  
  Map<String,dynamic> toMap() => <String,dynamic>{
        'uuid':uuid,
        'contacName' :contacName,
        'address' : address,
        'mobile' : mobile,
        'city' : city,
        'email' : email,
        'orderDate' : orderDate,
        'amount' : amount,
        'orderDetail' : orderDetail.map((cart)=>cart.toJson()).toList(),
        'status' : status,
        'comments': comments
  };

  Order.fromSnapshot(DataSnapshot snapshot)
      : uuid = snapshot.child('uuid').value as String? ?? '',
        contacName = snapshot.child('contacName').value as String? ?? '',
        address = snapshot.child('address').value as String? ?? '',
        mobile = snapshot.child('mobile').value as String? ?? '',
        city = snapshot.child('city').value as String? ?? '',
        email = snapshot.child('email').value as String? ?? '',
        orderDate = snapshot.child('orderDate').value as String? ?? '',
        amount = (snapshot.child('amount').value as num?)?.toDouble() ?? 0.0,
        orderDetail = (snapshot.child('orderDetail').value as List<dynamic>?)
            ?.map((item) => Cart.fromJson(item))
            .toList() ?? [],
        status = snapshot.child('status').value as String? ?? '',
        comments = snapshot.child('comments').value as String? ?? '';
}
