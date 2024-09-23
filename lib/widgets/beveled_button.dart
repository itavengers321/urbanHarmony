import 'package:flutter/material.dart';

Widget beveledButton({
  required String title,
  required GestureTapCallback onTap,
  Color? color, // Add color parameter
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? Colors.black.withOpacity(0.4), // Use the passed color or default
      foregroundColor: Colors.white,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    onPressed: onTap,
    child: Text(title),
  );
}
