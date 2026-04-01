// lib/utils/responsive_utils.dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Определение типа устройства
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 600;
  }

  // Определение количества столбцов
  static int getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return 3; // Большие планшеты
    } else if (screenWidth >= 800) {
      return 2; // Средние планшеты
    } else if (screenWidth >= 600) {
      return 2; // Маленькие планшеты
    } else {
      return 1; // Телефоны
    }
  }

  // Определение соотношения сторон карточки
  static double getCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = getCrossAxisCount(context);
    
    if (crossAxisCount >= 2) {
      // Для планшетов (2-3 столбца)
      if (crossAxisCount == 2) {
        return 0.85; // 2 столбца - выше
      } else {
        return 0.95; // 3 столбца - чуть ниже
      }
    } else {
      // Для телефонов (1 столбец)
      return 2.5;
    }
  }

  // Определение, нужно ли отображать картинку сверху
  static bool isImageOnTop(BuildContext context) {
    return getCrossAxisCount(context) >= 2;
  }
}