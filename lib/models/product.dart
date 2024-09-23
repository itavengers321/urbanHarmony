class Product{
  late String code;  
  late String name;
  late String desc;
  late double price;
  late String image;
  late String status; // available, out of stock, top selling, vender recommended

  Product({
    required this.code,
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    required this.status
  });


}