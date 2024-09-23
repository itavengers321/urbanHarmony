
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/models/cart.dart';
import 'package:flutter_project_2208e/models/order.dart';
import 'package:flutter_project_2208e/services/order_dao.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  static const String routeName = '/OrderPage';

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late String displayName;
  String? uuid;
  OrdersDao ordersDao = OrdersDao();
  List<Order> orders = [];
  bool isLoading = true;

  Future<void> fetchAndSortOrders() async {
    if (uuid != null) {
      try {
        List<Order> fetchedOrders = await ordersDao.fetchOrdersByUuid(uuid!);
        fetchedOrders.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
        setState(() {
          orders = fetchedOrders;
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching orders: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<dynamic> showOrderDetails(Order order) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white.withOpacity(0.6), // Semi-transparent card
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Contact Name: ${order.contacName}',
                              style: Theme.of(context).textTheme.bodyLarge),
                          Text('Address: ${order.address}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Mobile: ${order.mobile}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('City: ${order.city}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Email: ${order.email}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Order Date: ${order.orderDate}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Amount: ${order.amount} PKR',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Status: ${order.status}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Comments: ${order.comments}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                          Text('Order Details:',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: order.orderDetail.length,
                              itemBuilder: (context, index) {
                                Cart cartItem = order.orderDetail[index];
                                return ListTile(
                                  title: Text(cartItem.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                  subtitle: Text(
                                      'Quantity: ${cartItem.quantity} x  ${cartItem.price} RS.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  trailing: Text(
                                      'Total: ${cartItem.quantity * cartItem.price} PKR',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName ?? "Unknown User";
      uuid = user.uid;
      fetchAndSortOrders();
    } else {
      displayName = "Unknown User";
      uuid = null;
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(displayName: displayName),
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8), // Whitish background
              Colors.lightBlue.withOpacity(0.8), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orders.isEmpty
                ? const Center(child: Text('No orders available.'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      Order order = orders[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6), // Semi-transparent background
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(order.contacName,
                              style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text(
                              'Order Date: ${order.orderDate}\nAmount: ${order.amount} RS.',
                              style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Text(order.status,
                              style: Theme.of(context).textTheme.bodyMedium),
                          onTap: () {
                            showOrderDetails(order);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
