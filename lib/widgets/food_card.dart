import 'package:flutter/material.dart';
import '../models/food_log.dart';

class FoodCard extends StatelessWidget {
  final FoodLog log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FoodCard({super.key, required this.log, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(log.foodName),
        subtitle: Text("${log.amountGram} g - ${log.calories} cal"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
