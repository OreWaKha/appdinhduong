import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phân tích món ăn bằng camera")),
      body: const Center(
        child: Text(
          "Tính năng chụp ảnh và phân tích sẽ được thêm sau",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
