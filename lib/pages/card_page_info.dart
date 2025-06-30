import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/widgets/heart_button.dart';

class CardPageInfo extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double discount;
  final String description;

  const CardPageInfo({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    // const priceTextColor = Pallete.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: TextStyle(color: textColor)),
        backgroundColor: Pallete.orange,
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            // Row(
            //   children: [
            //     if (discount > 0)
            //       Text(
            //         '$price',
            //         style: const TextStyle(
            //           color: Pallete.gray,
            //           decoration: TextDecoration.lineThrough,
            //           fontSize: 10,
            //         ),
            //       ),
            //     if (discount > 0) const SizedBox(width: 4),
            //     Text(
            //       discount > 0
            //           ? '${(price * (1 - discount)).toStringAsFixed(2)} руб'
            //           : '$price руб',
            //       style: TextStyle(
            //         fontSize: 20,
            //         color: discount > 0 ? priceTextColor : textColor,
            //         fontWeight:
            //             discount > 0 ? FontWeight.w600 : FontWeight.normal,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            Text(
              'Описание',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeartButton(id: id),
                ElevatedButton.icon(
                  onPressed: () {
                    // здесь можно добавить логику добавления в корзину
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    discount > 0
                        ? '${(price * (1 - discount)).toStringAsFixed(2)} руб'
                        : '$price руб',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
