import 'package:first_project/views/home.view.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Flutter App',
      // routes: {
      //   '/': (context) => CustomTabBar(),
      //   '/jambform': (context) => Jambform(),
      // },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: Home(),
    );
  }
}
