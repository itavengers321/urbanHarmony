
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/widgets/beveled_button.dart';



Future<void> messageBox(
    {required BuildContext context,
    required String title,
    required String message}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
         backgroundColor: Colors.blueGrey.withOpacity(0.8),
        title: Container(color: Colors.grey,padding: const EdgeInsets.all(10) ,child: Text(title,style: Theme.of(context).textTheme.titleMedium)),
        content: Container(color: Colors.grey[800],padding: const EdgeInsets.all(10),child: Text(message)),
        actions: <Widget>[          
          beveledButton(title: "OK", onTap: ()=>Navigator.of(context).pop())
        ],
      );
    },
  );
}