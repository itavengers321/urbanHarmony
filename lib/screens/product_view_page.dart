import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project_2208e/models/cart.dart';
import 'package:flutter_project_2208e/models/product_furniture.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import 'package:flutter_project_2208e/screens/single_product_view.dart';
import 'package:flutter_project_2208e/services/cart_dao.dart';
import 'package:flutter_project_2208e/services/product_services.dart';
import 'package:flutter_project_2208e/widgets/item_card.dart';
import '../widgets/custom_drawer.dart';

class ProductViewPage extends StatefulWidget {
  const ProductViewPage({super.key});
  static const String routeName = '/ProductViewPage';

  @override
  State<ProductViewPage> createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final cartDao = CartDao();
  final productDao = ProductServiceDao();
  late String displayName;
  String? uuid;
  int cartItemCount = 0;
  Map<ProductFurniture, int> prodQuantities = {};
  bool isAscending = true;
  List<ProductFurniture> products = [];
  List<ProductFurniture> filteredProducts = [];
  String searchQuery = '';

  Future<void> getTotalCartItemsCountInitial() async {
    try {
      final count = await cartDao.getTotalCartItemsCount(uuid.toString());
      setState(() {
        cartItemCount = count;
      });
    } catch (error) {
      print("Error unable to get cart item count");
    }
  }

  Future<void> fetchProducts() async {
    final snapshot = await productDao.getMessageQuery().get();
    if (snapshot.exists) {
      final List<ProductFurniture> fetchedProducts = [];
      snapshot.children.forEach((child) {
        final json = child.value as Map<dynamic, dynamic>;
        fetchedProducts.add(ProductFurniture.fromJson(json));
      });
      setState(() {
        products = fetchedProducts;
        filteredProducts = products; // Initialize filteredProducts
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products.where((product) {
        return product.ProductName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      print("Search query: $searchQuery");
      print("Filtered products count: ${filteredProducts.length}");
    });
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

    bool isAlreadySaved = false;

    if (snapshotSaved_Item.exists) {
      final savedItems_check = snapshotSaved_Item.value as Map<dynamic, dynamic>;

      savedItems_check.forEach((key, value) {
        if (value["productkey"] == product.prokey && value["uuid"] == uuid) {
          isAlreadySaved = true;
          return;
        }
      });
    }

    if (isAlreadySaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already in 'Saved Items'")),
      );
    } else {
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
        const SnackBar(content: Text("Item saved to 'Saved Items'")),
      );
    }
  }

  void productDetails(ProductFurniture product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleProductView(prodkey: product.prokey),
      ),
    );
  }

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      filteredProducts.sort((a, b) {
        final priceA = double.parse(a.ProductPrice);
        final priceB = double.parse(b.ProductPrice);
        return isAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    });
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

      getTotalCartItemsCountInitial();
      fetchProducts();
    } else {
      print("No user signed in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product View',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: toggleSortOrder,
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black,
            child: IconButton(
              icon: const Icon(Icons.add_shopping_cart_outlined),
              onPressed: () {
                Navigator.pushReplacementNamed(context, PageRoutes.cart);
              },
              color: cartItemCount > 0 ? Colors.green : Colors.white,
            ),
          ),
          const SizedBox(width: 5.0),
          if (cartItemCount > 0)
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 12,
              child: Text("$cartItemCount"),
            ),
          const SizedBox(width: 5.0),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
              ),
              onChanged: handleSearch, // This should trigger the search
            ),
          ),
        ),
      ),
      drawer: CustNavigationDrawer(displayName: displayName),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final prd = filteredProducts[index];
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
        },
      ),
    );
  }
}
