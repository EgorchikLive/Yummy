import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/card_page_info.dart';
import 'package:yummy/widgets/cart_button.dart';
import 'package:yummy/widgets/heart_button.dart';

class CardPage extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double discount;
  final String description;

  const CardPage({
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
    const priceTextColor = Pallete.orange;

    return Slidable(
      key: ValueKey(id),
      // Слайдер только вправо
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.7, // Ширина слайдера (70% экрана)
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Описание:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        description.isNotEmpty 
                            ? description 
                            : 'Описание отсутствует',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.8),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (discount > 0)
                    Text(
                      'Скидка: ${(discount * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Pallete.orange,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardPageInfo(
                id: id,
                name: name,
                imageUrl: imageUrl,
                price: price,
                discount: discount,
                description: description,
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.all(10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 128,
                  height: 128,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 128,
                      height: 128,
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: SizedBox(
                        height: 48.0,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: textColor,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            if (discount > 0)
                              Text(
                                '$price руб',
                                style: const TextStyle(
                                  color: Pallete.gray,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                ),
                              ),
                            if (discount > 0) const SizedBox(width: 4),
                            Text(
                              discount > 0
                                  ? '${(price * (1 - discount)).toInt()} руб'
                                  : '$price руб',
                              style: TextStyle(
                                color: discount > 0 ? priceTextColor : textColor,
                                fontWeight: discount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        HeartButton(id: id),
                        CartButton(
                          id: id,
                          name: name,
                          imageUrl: imageUrl,
                          price: price,
                          discount: discount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}