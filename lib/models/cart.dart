class Cart {
  late String code;
  late String name;
  late double price;
  late int quantity;

  Cart(
      {required this.code,
      required this.name,
      required this.price,
      required this.quantity});

  Cart.fromJson(Map<dynamic, dynamic> json)
      : code = json['code'] as String,
        name = json['name'] as String,
        //price = json['price'] as double,
        price = (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : json['price'] as double,
        quantity = json['quantity'] as int;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'code': code,
        'name': name,
        'price': price,
        'quantity': quantity
      };

  Map<String, dynamic> toMap() => <String, dynamic>{
        'code': code,
        'name': name,
        'price': price,
        'quantity': quantity
      };
}
