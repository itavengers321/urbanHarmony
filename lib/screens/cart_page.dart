import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/models/cart.dart';
import 'package:flutter_project_2208e/models/order.dart';
import 'package:flutter_project_2208e/models/user_profile.dart';
import 'package:flutter_project_2208e/pages/checkout_page.dart';
import 'package:flutter_project_2208e/services/cart_dao.dart';
import 'package:flutter_project_2208e/services/user_profile_dao.dart';
import '../widgets/beveled_button.dart';
import '../widgets/custom_drawer.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  static const String routeName = '/CartPage';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late String displayName;
  late String uuid;
  UsersProfile? userProfile;
  double totalOrderPrice = 0.0;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  CartDao cartDao = CartDao();
  final userProfileDao = UserProfileDao();
  List<Cart> cartItems = [];
  bool isLoading = true;

  Future<void> verifyStatus(String? email) async {
    userProfile = await userProfileDao.searchByEmail(email!);
    if (userProfile != null) {
      print('User found: ${userProfile?.displayName}, Role: ${userProfile?.type}');
      setState(() {
        isLoading = false;
      });
    } else {
      print('User not found');
      setState(() {
        isLoading = false;
      });
    }
  }

  void placeOrder() {
    loadCartItems();
    if (cartItems.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Cart is empty"),
            content: const Text("Please add items to your cart before placing an order."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Order order = Order(
      uuid: uuid.toString(),
      contacName: userProfile!.displayName,
      address: userProfile!.address,
      mobile: userProfile!.mobile,
      city: userProfile!.city,
      email: userProfile!.email,
      orderDate: DateTime.now().toLocal().toString(),
      orderDetail: cartItems,
      amount: totalOrderPrice,
      status: "pending",
      comments: "order is pending, need approval",
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(order: order),
      ),
    );
  }

  void loadCartItems() {
    final cartRef = cartDao.getMessageQuery(uuid);

    cartRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          cartItems = data.entries.map((e) {
            return Cart.fromJson(Map<String, dynamic>.from(e.value));
          }).toList();

          totalOrderPrice = cartItems.fold(
              0.0, (sum, item) => sum + (item.price * item.quantity));
          print("Loaded cart items: $cartItems");
          print("Total order price: $totalOrderPrice");
        });
      } else {
        print("No items in the cart");
      }
    }, onError: (error) {
      print("Error loading cart items: $error");
    });
  }

  void removeCartItem(String cartKey, Cart cart) {
    cartDao.deleteCart(cartKey, uuid).then((_) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => super.widget));
    }).catchError((error) {
      print("Error removing item: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName ?? "Unknown User";
      uuid = user.uid;
      verifyStatus(user.email);
      loadCartItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Cart - $displayName',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.lightBlue.withOpacity(0.6),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(15.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : userProfile == null
                    ? const Center(child: Text("No user profile found"))
                    : Center(
                        child: Card(
                          color: Colors.white.withOpacity(0.6), // Transparent card
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Center(
                                  child: Text(
                                    'User Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                buildSummaryRow(
                                    'Name:', userProfile?.displayName ?? 'N/A'),
                                buildSummaryRow(
                                    'Mobile No:', userProfile?.mobile ?? 'N/A'),
                                buildSummaryRow(
                                    'Email Address:', userProfile?.email ?? 'N/A'),
                                buildSummaryRow(
                                    'Address:', userProfile?.address ?? 'N/A'),
                                buildSummaryRow('City:', userProfile?.city ?? 'N/A'),
                                const SizedBox(height: 10.0),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FutureBuilder(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return FirebaseAnimatedList(
                        query: cartDao.getMessageQuery(uuid),
                        itemBuilder: (context, snapshot, animated, index) {
                          var json = snapshot.value as Map<dynamic, dynamic>;
                          String cartKey = snapshot.key.toString();
                          Cart cart = Cart.fromJson(json);

                          return Card(
                            elevation: 10.0,
                            color: Colors.white.withOpacity(0.6), // Transparent card
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Product Code",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(cart.code)
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Product Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(cart.name)
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Product Price",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                      const SizedBox(width: 5),
                                      Text("${cart.price} RS.")
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Product Quantity",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${cart.quantity}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text(
                                        "Total",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      Text(
                                      " ${cart.price * cart.quantity} RS.",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: beveledButton(
                                        title: 'Delete',
                                        onTap: () {
                                          removeCartItem(cartKey, cart);
                                        },
                                      
                                        color: Colors.redAccent.withOpacity(0.8)), // Stylish button
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.withOpacity(0.7), // Light blue button
        onPressed: () {
          placeOrder();
        },
        label: Text(
          'Check Out',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
