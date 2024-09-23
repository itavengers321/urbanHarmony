import 'package:flutter/material.dart';

class ProductFurniture{
  late String ImageBase64;  
  late String ProductName;
  late String ProductDescription;
  late String ProductPrice;
  late String productCategory;
  late String brand;
  late String status; // Available, out of stock, top selling, vender recommended
  late String prokey; // Available, out of stock, top selling, vender recommended

  ProductFurniture({
    required this.ImageBase64,
    required this.ProductName,
    required this.ProductDescription,
    required this.ProductPrice,
    required this.brand,
    required this.productCategory,
    required this.status,
    required this.prokey
  });

  ProductFurniture.fromJson(Map<dynamic,dynamic> json)
   : ImageBase64=json['ImageBase64'] as String,
   ProductName=json['ProductName'] as String,
   ProductDescription=json['ProductDescription'] as String,
   ProductPrice=json['ProductPrice'] as String,
   brand=json['brand'] as String,
   productCategory=json['productCategory'] as String,
   status=json['status'] as String,
   prokey=json['prokey'] as String;

  Map<dynamic,dynamic> toJson()=><dynamic,dynamic>{
    'ImageBase64':ImageBase64,
    'ProductName':ProductName,
    'ProductDescription':ProductDescription,
    'ProductPrice':ProductPrice,
    'brand':brand,
    'productCategory':productCategory,
    'status':status,
    "prokey": prokey,
    
   };


   Map<String,dynamic> toMap ()=><String,dynamic>{
    'ImageBase64':ImageBase64,
    'ProductName':ProductName,
    'ProductDescription':ProductDescription,
    'ProductPrice':ProductPrice,
    'brand':brand,
    'productCategory':productCategory,
    'status':status,
    "prokey": prokey,
  
   };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFurniture &&
          runtimeType == other.runtimeType &&
          ProductName == other.ProductName;

  @override
  int get hashCode => ProductName.hashCode;


}