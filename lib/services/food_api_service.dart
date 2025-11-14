import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodApiService {
  static const String _apiKey = "e4U2p6HfAGNGGXtHpGa0h1BxlL8ZSrhUUsFywnkw";

  /// Lấy calories theo tên món + số gram
  Future<double?> getCalories(String foodName, double grams) async {
    try {
      final url = Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search"
        "?api_key=$_apiKey&query=$foodName&pageSize=1",
      );

      final response = await http.get(url);
      print("🔍 USDA API Status: ${response.statusCode}");
      print("🔍 USDA API Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['foods'] == null || data['foods'].isEmpty) {
          print("⚠ Không tìm thấy món ăn: $foodName");
          return null;
        }

        final food = data['foods'][0];
        final nutrients = food['foodNutrients'] as List<dynamic>;

        final energyNutrient = nutrients.firstWhere(
          (n) => n['nutrientName']
              .toString()
              .toLowerCase()
              .contains('energy'),
          orElse: () => null,
        );

        if (energyNutrient == null) {
          print("⚠ Không tìm thấy calories cho món: $foodName");
          return null;
        }

        final caloriesPer100g = (energyNutrient['value'] as num).toDouble();
        return caloriesPer100g * (grams / 100);
      }

      print("❌ Lỗi API: ${response.statusCode}");
      return null;
    } catch (e) {
      print("❌ Lỗi khi gọi API USDA: $e");
      return null;
    }
  }
}
