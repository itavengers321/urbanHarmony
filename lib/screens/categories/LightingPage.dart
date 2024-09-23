import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_2208e/models/cart.dart';
import 'package:flutter_project_2208e/models/product_furniture.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/screens/categories/furniture.dart';
import 'package:flutter_project_2208e/screens/single_product_view.dart';
import 'package:flutter_project_2208e/services/cart_dao.dart';
import 'package:flutter_project_2208e/services/product_services.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';
import 'package:flutter_project_2208e/widgets/item_card.dart';

class lightingPage extends StatefulWidget {
  const lightingPage({super.key});
  static const String routeName = '/lightingPage';

  @override
  State<lightingPage> createState() => _lightingPageState();
}

class _lightingPageState extends State<lightingPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final cartDao = CartDao();
  final productDao = ProductServiceDao();
  late String displayName;
  String? uuid;
  int cartItemCount = 0;
  Map<ProductFurniture, int> prodQuantities = {};

  Future<void> getTotalCartItemsCountInitial() async {
    try {
      final count = await cartDao.getTotalCartItemsCount(uuid.toString());
      setState(() {
        cartItemCount = count;
      });
    } catch (error) {
      print("Error unable get cart item count");
    }
  }

  Future<void> handlePCartTap(ProductFurniture prd) async {
    if (prd.status == "out of stock") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product is out of stock")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You have selected ${prd.ProductName}")));

      final cart = Cart(
        code: prd.ProductName,
        name: prd.ProductName,
        price: double.parse(prd.ProductPrice),
        quantity: prodQuantities[prd] ?? 1,
      );

      await cartDao.saveToCart(cart, uuid.toString());
      await getTotalCartItemsCountInitial();
    }
  }

  void incrementPQuantity(ProductFurniture product) {
    setState(() {
      prodQuantities[product] = (prodQuantities[product] ?? 1) + 1;
    });
  }

  void decrementPQuantity(ProductFurniture product) {
    setState(() {
      if ((prodQuantities[product] ?? 1) > 1) {
        prodQuantities[product] = (prodQuantities[product] ?? 1) - 1;
      }
    });
  }

  Future<void> savedItem(ProductFurniture product) async {
  final refSaved_Item = databaseReference.child('savedItemsFavourites');
  final snapshotSaved_Item = await refSaved_Item.get();

  bool isAlreadySaved = false; // Track if the item is already saved

  if (snapshotSaved_Item.exists) {
    final savedItems_check = snapshotSaved_Item.value as Map<dynamic, dynamic>;

    // Check if the item is already saved
    savedItems_check.forEach((key, value) {
      if (value["productkey"] == product.prokey && value["uuid"] == uuid) {
        isAlreadySaved = true; // Mark as already saved
        return; // Exit the loop early since we found a match
      }
    });
  }

  // If the item is already saved, show a message and do not save again
  if (isAlreadySaved) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product already in 'Saved Items'"))
    );
  } else {
    // Save the new item
    final saveData = {
      "uuid": uuid,
      "productkey": product.prokey,
      "ImageBase64": product.ImageBase64,
      "ProductDescription": product.ProductDescription,
      "ProductName": product.ProductName,
      "ProductPrice": product.ProductPrice,
      "brand": product.brand,
      "productCategory": product.productCategory,
    };

    await databaseReference.child("savedItemsFavourites").push().set(saveData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item saved to 'Saved Items'"))
    );
  }
}


  void productDetails(ProductFurniture product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleProductView(
            prodkey: product.prokey), // Pass the correct designerUuid
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        displayName = user.displayName.toString();
        uuid = user.uid.toString();
      });

      final connectedCartRef = cartDao.getMessageQuery(uuid.toString());
      final connectedProdRef = productDao.getMessageQuery();
      connectedCartRef.keepSynced(true);
      connectedProdRef.keepSynced(true);
      getTotalCartItemsCountInitial();
    } else {
      print("No user signed in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Category - Lighting',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black,
            child: IconButton(
                icon: const Icon(Icons.add_shopping_cart_outlined),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, PageRoutes.cart);
                },
                color: cartItemCount > 0 ? Colors.green : Colors.white),
          ),
          const SizedBox(width: 5.0),
          if (cartItemCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 12,
                child: Text("$cartItemCount"),
              ),
            ),
          const SizedBox(width: 5.0),
        ],
      ),
      
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return FirebaseAnimatedList(
              query: productDao.getMessageQuery().orderByChild('productCategory').equalTo('Lighting'),
              itemBuilder: (context, snapshot, animation, index) {
                final json = snapshot.value as Map<dynamic, dynamic>;
                final prd = ProductFurniture.fromJson(json);
                final quantity = prodQuantities[prd] ?? 1;
                return getProductCard(
                  product: prd,
                  quantity: quantity,
                  onCartTap: () => handlePCartTap(prd),
                  onFavoriteTap: () => savedItem(prd),
                  onDecreaseTap: () => decrementPQuantity(prd),
                  onIncreasseTap: () => incrementPQuantity(prd),
                  onDetailsTap: () => productDetails(prd),
                );
              },
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(20.0),
              child: const Center(
                child: Card(
                  elevation: 10.0,
                  margin: EdgeInsets.all(30),
                  color: Colors.white,
                  child: ListTile(
                    title: Text('Warning'),
                    subtitle: Text("Please change to portrait view"),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
