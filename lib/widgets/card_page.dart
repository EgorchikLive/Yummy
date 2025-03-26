import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/widgets/heart_button.dart';

class CardPage extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final double discount;

  const CardPage({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    const priceTextColor = Pallete.orange;

    return InkWell(
      onTap: () {},
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
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
                          height: 48.0, // Фиксированная ширина
                          child: RichText(
                            text: TextSpan(
                              text: name,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: textColor, // Цвет текста зависит от темы
                              ),
                            ),
                            softWrap: true, // Разрешаем перенос текста
                            maxLines: 2, // Ограничиваем текст 3 строками
                            overflow: TextOverflow
                                .ellipsis, // Если текст не помещается, добавляем многоточие
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              if (discount > 0)
                                Text(
                                  '$price',
                                  style: const TextStyle(
                                    color: Pallete.gray,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10,
                                  ),
                                ),
                              if (discount > 0)
                                const SizedBox(
                                    width: 4), // Расстояние между ценами
                              Text(
                                discount > 0
                                    ? '${(price * (1 - discount)).toStringAsFixed(2)} руб'
                                    : '$price руб',
                                style: TextStyle(
                                  color: discount > 0
                                      ? priceTextColor // Цвет текста зависит от темы
                                      : textColor, // Цвет текста зависит от темы
                                  fontWeight: discount > 0
                                      ? FontWeight.w600
                                      : FontWeight
                                          .normal, // Установка веса шрифта в зависимости от скидки
                                ),
                              ),
                            ],
                          ),
                          HeartButton(id: id),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_cart),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
