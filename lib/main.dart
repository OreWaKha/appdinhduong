import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Nutrition Tracker",
    initialRoute: "/login",
    routes: appRoutes,
  ));
}
