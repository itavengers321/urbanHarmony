import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/screens/categories/Curtains.dart';
import 'package:flutter_project_2208e/screens/categories/Wall.dart';
import 'package:flutter_project_2208e/screens/product_view_page.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'categories/furniture.dart';
import 'categories/DecorPage.dart';
import 'categories/LightingPage.dart';
import 'categories/rugs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String displayName;
  final databaseReference = FirebaseDatabase.instance.ref(); // Initialize Firebase reference
  List<Map<String, dynamic>> products = []; // List to hold products
  List<String> productKeys = []; // List to hold product keys

  @override
  void initState() {
    super.initState();
    fetchProducts();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName.toString();
    } else {
      displayName = "Unknown User";
    }
  }

  Future<void> fetchProducts() async {
    final ref = databaseReference.child('products'); // Assuming 'products' is the node
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
            "ImageBase64": value["ImageBase64"], // Assuming base64 image
          });
          productKeys.add(key); // Store the product key
        });
      });
    } else {
      print("No products found");
      // Optionally show a message in the UI
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'Welcome to Urban Harmony',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        color: Colors.white.withOpacity(0.8), // Transparent whitish background
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transform Your Space',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent, // Theme color
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Transform Your Life',
                            style: TextStyle(
                              fontSize: 10,
                              color:  Colors.black,
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent, // Theme color
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Category icons with names
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryCard(
                        icon: Icons.chair,
                        label: 'Furniture',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => furniturePage()));
                        },
                      ),
                      CategoryCard(
                        icon: Icons.wallpaper,
                        label: 'Wall Art',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => wallViewPage()));
                        },
                      ),
                      CategoryCard(
                        icon: Icons.curtains,
                        label: 'Curtains',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CurtainsPage()));
                        },
                      ),
                      CategoryCard(
                        icon: Icons.clean_hands,
                        label: 'Rugs',
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => rugsPage()));
                        },
                      ),
                      CategoryCard(
                        icon: Icons.art_track,
                        label: 'Decor',
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => DecorPage()));
                        },
                      ),
                      CategoryCard(
                        icon: Icons.light,
                        label: 'Lighting',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => lightingPage()));
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Product carousel
                products.isNotEmpty
                    ? Container(
                        height: 200,
                        child: PageView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: Product(
                                name: product["ProductName"],
                                category: product["productCategory"],
                                imageUrl: product["ImageBase64"], // Assuming you handle base64 appropriately
                                price: product["ProductPrice"],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(child: Text('No products found')),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductViewPage(), // Pass the correct designerUuid
                        ),
                      );
                    },
                    child: Text('View All Products'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 6, 73, 128),),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _launchURL(
                          'https://www.daraz.pk/shop/6elbbxhx/?spm=a2a0e.pdp_revamp.seller.1.4a93b7e9m4sfnD&itemId=466887343&channelSource=pdp'); // Replace with your desired URL
                    },
                    child: Text('Visit More Products'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent), // Updated color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  CategoryCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 6, 73, 128),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 252, 249, 249),
                  size: 45,
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String category;
  final String imageUrl;
  final String price;

  Product({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
  });
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          // Assuming image is displayed from base64; you might need to decode it appropriately
          Image.memory(base64Decode(product.imageUrl),
              fit: BoxFit.cover, height: 100, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(product.category, style: TextStyle(color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${product.price} RS.' ,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
