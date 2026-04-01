import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/widgets/cart_button_info.dart';
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

  // Метод для определения типа устройства
  bool _isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 600;
  }

  // Метод для получения высоты картинки (адаптивная)
  double _getImageHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final isLandscape = screenWidth > screenHeight;
    
    if (isTablet) {
      // Для планшетов
      if (isLandscape) {
        return screenHeight * 0.5; // 50% высоты экрана в ландшафте
      } else {
        return screenHeight * 0.4; // 40% высоты экрана в портрете
      }
    } else {
      // Для телефонов
      if (isLandscape) {
        return screenHeight * 0.6; // 60% высоты экрана в ландшафте
      } else {
        return 250; // Фиксированная высота для телефонов в портрете
      }
    }
  }

  // Метод для получения размера шрифта названия
  double _getTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = _isTablet(context);
    
    if (isTablet) {
      return screenWidth * 0.05; // 5% от ширины экрана
    } else {
      return 24; // Фиксированный размер для телефонов
    }
  }

  // Метод для получения размера шрифта описания
  double _getDescriptionFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = _isTablet(context);
    
    if (isTablet) {
      return screenWidth * 0.04; // 4% от ширины экрана
    } else {
      return 16; // Фиксированный размер для телефонов
    }
  }

  // Метод для получения отступов
  EdgeInsets _getPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = _isTablet(context);
    
    if (isTablet) {
      return EdgeInsets.all(screenWidth * 0.04); // 4% от ширины экрана
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final imageHeight = _getImageHeight(context);
    final titleFontSize = _getTitleFontSize(context);
    final descriptionFontSize = _getDescriptionFontSize(context);
    final padding = _getPadding(context);
    const priceTextColor = Pallete.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          name, 
          style: TextStyle(
            color: textColor,
            fontSize: titleFontSize * 0.7, // Заголовок в AppBar чуть меньше
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Pallete.orange,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Адаптивная картинка
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.fastfood,
                          size: imageHeight * 0.3,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: padding.top),
                
                // Название товара
                Text(
                  name,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: padding.top * 0.5),
                
                // Цена
                Row(
                  children: [
                    if (discount > 0)
                      Text(
                        '$price руб',
                        style: TextStyle(
                          color: Pallete.gray,
                          decoration: TextDecoration.lineThrough,
                          fontSize: descriptionFontSize * 0.8,
                        ),
                      ),
                    if (discount > 0) SizedBox(width: padding.left * 0.5),
                    Text(
                      discount > 0
                          ? '${(price * (1 - discount)).toInt()} руб'
                          : '$price руб',
                      style: TextStyle(
                        fontSize: titleFontSize * 0.8,
                        color: discount > 0 ? priceTextColor : textColor,
                        fontWeight: discount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding.top),
                
                // Описание
                Text(
                  'Описание',
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: padding.top * 0.3),
                Text(
                  description.isNotEmpty ? description : 'Описание отсутствует',
                  style: TextStyle(
                    fontSize: descriptionFontSize * 0.9,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: padding.top * 1.5),
                
                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeartButton(id: id),
                    CartElevatedButton(
                      id: id,
                      name: name,
                      imageUrl: imageUrl,
                      price: price,
                      discount: discount,
                    ),
                  ],
                ),
                
                // Дополнительный отступ снизу
                SizedBox(height: padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }
}