import 'package:flutter/material.dart';
import 'package:map_deneme/firebase.dart';
import 'package:map_deneme/user_kayit.dart';
import 'arkadaslar.dart';
import 'haritay.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      title: "Eventy",
      debugShowCheckedModeBanner: false,
      routes: {
        '/firebase': (context) => App(),
        '/userKayıt': (context) => UserKayitSayfasi(),
        '/haritay': (context) => Haritay(),
        '/arkadaslar': (context) => Arkadaslar(),
      },
      home: App(),
    );
  }
}
