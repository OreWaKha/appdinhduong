import 'package:appdinhduong/screens/food_log/edit_food_log_screen.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/food_log/add_food_log_screen.dart';
import '../app/app.dart';
import '../screens/food_log/edit_food_log_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  "/login": (context) => const LoginScreen(),
  "/register": (context) => const RegisterScreen(),
  "/main_nav": (context) => const MainNavigation(),
  "/add_food_log": (context) => const AddFoodLogScreen(),
  
};

