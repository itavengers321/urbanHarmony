import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/routes/route_pages.dart';
import '../screens/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int counter = 0;

  void loadingStatus() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      setState(() {
        counter += 25;
      });
      loadingStatus();
    });
  }

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingStatus();
    Timer(
        const Duration(seconds: 4),
        () => Navigator.pushReplacementNamed(context, PageRoutes.sitemap)
           
            );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/splash.jpg'),
                  fit: BoxFit.fill)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Loading: $counter%',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                const CircularProgressIndicator(backgroundColor: Colors.white),
                const SizedBox(
                  height: 10,
                ),
                const Text('App Powered by Urban Harmony',
                    style: TextStyle(color: Color.fromARGB(255, 6, 5, 5),
                    fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
          )),
    );
  }
}
