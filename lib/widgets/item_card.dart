import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/models/product.dart';
import 'package:flutter_project_2208e/models/product_furniture.dart';
import 'package:flutter_project_2208e/widgets/beveled_button.dart';
import 'dart:convert';
import 'dart:typed_data'; // For decoding Base64 string to bytes

Widget getItemCard({
  required Product product,
  required int quantity,
  required int prodKey,
  required GestureTapCallback onFavoriteTap,
  required GestureTapCallback onCartTap,
  required GestureTapCallback onIncreasseTap,
  required GestureTapCallback onDecreaseTap,
}) {
  return Card(
    elevation: 4.0,
    color: Colors.white.withOpacity(0.1), // Semi-transparent
    margin: const EdgeInsets.all(16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Image.asset(
            "assets/dump/${product.image}",
            width: 300,
            height: 200,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onFavoriteTap,
                child: const Text("Add to Favorite"),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: onCartTap,
                child: const Text("Add to Cart"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget getItemCardCar({required Product product}) {
  return Card(
    elevation: 1.0,
    color: Colors.white,
    margin: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/dump/${product.image}",
            width: 150,
            height: 90,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget getItemCardSimple({required Product product}) {
  return Card(
    elevation: 1.0,
    color: Colors.white,
    margin: const EdgeInsets.all(8.0),
    child: ListTile(
      leading: Image.asset("assets/dump/${product.image}",
          width: 50, height: 50, fit: BoxFit.fitHeight),
      title: Text(product.name),
      subtitle: Text(product.desc),
    ),
  );
}
Widget getProductCard({
  required ProductFurniture product,
  required int quantity,
  required GestureTapCallback onFavoriteTap,
  required GestureTapCallback onCartTap,
  required GestureTapCallback onIncreasseTap,
  required GestureTapCallback onDecreaseTap,
  required GestureTapCallback onDetailsTap, // New parameter for details button
}) {
  Uint8List imageBytes = base64Decode(product.ImageBase64);
  return Card(
    elevation: 4.0,
    color: Colors.white.withOpacity(0.6), // Semi-transparent whitish background
    margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0), // Rounded corners
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            product.ProductName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Darker text for better readability
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded image corners
            child: Image.memory(
              imageBytes,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.ProductDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54, // Subtle black text color
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${product.ProductPrice} RS.",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Strong contrast for price
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onDecreaseTap,
                icon: const Icon(Icons.remove, color: Colors.black87),
              ),
              Text(
                "$quantity",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              IconButton(
                onPressed: onIncreasseTap,
                icon: const Icon(Icons.add, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onFavoriteTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // Light blue for favorite button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Add to Favorite'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onCartTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent, // Light green for cart button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Add to Cart'),
              ),
            ],
          ),
          const SizedBox(height: 10), // Add some spacing
          ElevatedButton(
            onPressed: onDetailsTap, // Use the new parameter
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent, // Different color for details button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Product Details'),
          ),
        ],
      ),
    ),);
  }
