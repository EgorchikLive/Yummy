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

  // Метод для определения количества столбцов
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return 3;
    } else if (screenWidth >= 800) {
      return 2;
    } else if (screenWidth >= 600) {
      return 2;
    } else {
      return 1;
    }
  }

  // Метод для определения, нужно ли отображать картинку сверху (2+ столбцов)
  bool _isImageOnTop(BuildContext context) {
    return _getCrossAxisCount(context) >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isImageOnTop = _isImageOnTop(context);
    const priceTextColor = Pallete.orange;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Получаем размеры карточки
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;
        
        // Рассчитываем размеры элементов пропорционально карточке
        final imageSize = isImageOnTop 
            ? cardHeight * 0.55 // Для вертикального макета картинка занимает 55% высоты
            : cardHeight * 0.7; // Для горизонтального макета картинка занимает 70% высоты
        
        // Размеры шрифтов пропорционально ширине карточки
        final titleFontSize = (cardWidth * 0.05).clamp(14.0, 18.0);
        final priceFontSize = (cardWidth * 0.05).clamp(14.0, 18.0);
        final discountFontSize = (cardWidth * 0.04).clamp(11.0, 14.0);
        
        // Отступы пропорционально размеру карточки
        final padding = cardWidth * 0.03;
        final spacing = cardWidth * 0.02;

        return Slidable(
          key: ValueKey(id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.7,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(padding),
                  padding: EdgeInsets.all(padding * 1.5),
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
                          fontSize: discountFontSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            description.isNotEmpty 
                                ? description 
                                : 'Описание отсутствует',
                            style: TextStyle(
                              fontSize: discountFontSize * 0.9,
                              color: textColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      if (discount > 0)
                        Text(
                          'Скидка: ${(discount * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: discountFontSize,
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
              margin: EdgeInsets.all(padding * 0.5),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: isImageOnTop
                  // Макет для 2-3 столбцов: картинка сверху, контент снизу
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Масштабируемая картинка сверху
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            imageUrl,
                            height: imageSize,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: imageSize,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.fastfood, 
                                  size: imageSize * 0.4,
                                ),
                              );
                            },
                          ),
                        ),
                        // Контент снизу
                        Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: spacing),
                              Row(
                                children: [
                                  if (discount > 0)
                                    Text(
                                      '$price руб',
                                      style: TextStyle(
                                        color: Pallete.gray,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: discountFontSize,
                                      ),
                                    ),
                                  if (discount > 0) SizedBox(width: spacing),
                                  Text(
                                    discount > 0
                                        ? '${(price * (1 - discount)).toInt()} руб'
                                        : '$price руб',
                                    style: TextStyle(
                                      color: discount > 0 ? priceTextColor : textColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: priceFontSize,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing * 1.5),
                              Row(
                                children: [
                                  HeartButton(id: id),
                                  SizedBox(width: spacing * 1.2),
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
                    )
                  // Макет для 1 столбца: картинка слева, контент справа
                  : Row(
                      children: [
                        // Масштабируемая картинка слева
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.fastfood, 
                                  size: imageSize * 0.5,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: padding),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: padding * 0.8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: spacing),
                                Row(
                                  children: [
                                    if (discount > 0)
                                      Text(
                                        '$price руб',
                                        style: TextStyle(
                                          color: Pallete.gray,
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: discountFontSize,
                                        ),
                                      ),
                                    if (discount > 0) SizedBox(width: spacing),
                                    Text(
                                      discount > 0
                                          ? '${(price * (1 - discount)).toInt()} руб'
                                          : '$price руб',
                                      style: TextStyle(
                                        color: discount > 0 ? priceTextColor : textColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: priceFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing * 1.2),
                                Row(
                                  children: [
                                    HeartButton(id: id),
                                    SizedBox(width: spacing * 1.2),
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
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}