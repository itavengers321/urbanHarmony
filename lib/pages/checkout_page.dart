import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/models/order.dart';
import 'package:flutter_project_2208e/screens/cart_page.dart';
import 'package:flutter_project_2208e/screens/home_page.dart';
import 'package:flutter_project_2208e/services/cart_dao.dart';
import 'package:flutter_project_2208e/services/order_dao.dart';
import 'package:flutter_project_2208e/widgets/beveled_button.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.order});
  final Order order;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  OrdersDao ordersDao = OrdersDao();
  CartDao cartDao = CartDao();
  late String uuid;

  @override
  void initState() {
    final connectedRef = ordersDao.getMessageQuery();
    connectedRef.keepSynced(true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      uuid = user.uid;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Check Out",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.lightBlue.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white.withOpacity(0.9), // Transparent card
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          'Order Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      buildSummaryRow('Name:', widget.order.contacName),
                      buildSummaryRow('Mobile No:', widget.order.mobile),
                      buildSummaryRow('Email Address:', widget.order.email),
                      buildSummaryRow('Address:', widget.order.address),
                      buildSummaryRow('City:', widget.order.city),
                      buildSummaryRow('Order Date:', widget.order.orderDate),
                      buildSummaryRow('Order Amount:',
                          "NFT ${widget.order.amount.toString()}"),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: beveledButton(
                              title: "OK",
                              onTap: () async {
                                ordersDao.saveOrder(widget.order);
                                await cartDao.deleteAllCartItems(uuid);

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Alert!!"),
                                      content: const Text(
                                          "Your order is placed"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomePage()));
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: beveledButton(
                              title: "Cancel",
                              onTap: () async {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CartPage()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
