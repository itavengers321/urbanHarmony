import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_project_2208e/Admin/adminpage.dart';
import 'package:flutter_project_2208e/Admin/custom_drawer_admin.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';

class DisplayProducts extends StatefulWidget {
  const DisplayProducts({super.key});
  static const String routeName = '/DisplayProducts';

  @override
  _DisplayProductsState createState() => _DisplayProductsState();
}

class _DisplayProductsState extends State<DisplayProducts> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> products = [];
  List<String> productKeys = [];
  late String displayName;
  late String uuid;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  UserProfileDao userProfileDao = UserProfileDao();

  @override
  void initState() {
    super.initState();
    fetchProducts();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        uuid = user.uid.toString();
      });
    } else {
      displayName = "Unknown User";
    }
    final connectedRef = userProfileDao.getMessageQuery(uuid);
    connectedRef.keepSynced(true);
  }

  Future<void> fetchProducts() async {
    final ref = databaseReference.child('products');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final productData = snapshot.value as Map<dynamic, dynamic>;

      productData.forEach((key, value) {
        setState(() {
          products.add({
            "ProductName": value["ProductName"],
            "ProductDescription": value["ProductDescription"],
            "ProductPrice": value["ProductPrice"],
            "productCategory": value["productCategory"],
            "ImageBase64": value["ImageBase64"],
          });
          productKeys.add(key);
        });
      });
    } else {
      print("No products found");
    }
  }

  Future<void> deleteProduct(String key) async {
    await databaseReference.child('products/$key').remove();
    setState(() {
      products.removeAt(productKeys.indexOf(key));
      productKeys.remove(key);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Product deleted successfully!"),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DisplayProducts()),
    );
  }

  void navigateToEditProduct(Map<String, dynamic> product, String key) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProduct(product: product, productKey: key),
      ),
    ).then((value) {
      if (value == true) {
        fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'View Products',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final key = productKeys[index];
                Uint8List imageBytes = base64Decode(product["ImageBase64"]);

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.memory(
                            imageBytes,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Name: ${product["ProductName"]}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Category: ${product["productCategory"]}',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Price: ${product["ProductPrice"]} RS.',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Description: ${product["ProductDescription"]}',
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey[500]),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => navigateToEditProduct(product, key),
                              child: Text("Edit"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue, textStyle: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 10),
                            TextButton(
                              onPressed: () => deleteProduct(key),
                              child: Text("Delete"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red, textStyle: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}



class EditProduct extends StatefulWidget {
  final Map<String, dynamic> product;
  final String productKey;

  const EditProduct({super.key, required this.product, required this.productKey});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  String? selectedCategory;

  final List<String> categories = [
    'Furniture',
    'Lighting',
    'Decor',
    'Rugs and Carpet',
    'Wall Art',
    'Curtains and Blinds'
  ];

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.product["ProductName"];
    productDescriptionController.text = widget.product["ProductDescription"];
    productPriceController.text = widget.product["ProductPrice"];
    selectedCategory = widget.product["productCategory"];
  }

  Future<void> updateProduct() async {
    Map<String, dynamic> updatedProduct = {
      "ProductName": productNameController.text,
      "ProductDescription": productDescriptionController.text,
      "ProductPrice": productPriceController.text,
      "productCategory": selectedCategory,
      "ImageBase64": widget.product["ImageBase64"],
    };

    await FirebaseDatabase.instance
        .ref('products/${widget.productKey}')
        .update(updatedProduct);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ManageAdminPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: productDescriptionController,
              decoration: InputDecoration(
                labelText: "Product Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: productPriceController,
              decoration: InputDecoration(
                labelText: "Product Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedCategory,
              hint: Text("Select Category"),
              isExpanded: true,
              underline: Container(height: 1, color: Colors.blueGrey),
              items: categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProduct,
              child: Text("Update Product"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
