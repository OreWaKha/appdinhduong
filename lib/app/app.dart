import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/routes.dart';
import '../screens/home/home_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/camera_analysis/camera_screen.dart';

class NutritionApp extends StatelessWidget {
  const NutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nutrition Tracker",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      routes: appRoutes, // ✔ lấy routes từ routes.dart

      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lấy current user (đảm bảo không null)
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Nếu chưa login → đưa về màn login
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, "/login");
      });
      return const Center(child: CircularProgressIndicator());
    }

    final List<Widget> screens = const [
      HomeScreen(),
      CalendarScreen(),
      ProfileScreen(),
      CameraScreen(),
    ];

    final List<String> titles = ["Home", "Calendar", "Profile", "Camera"];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camera"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
