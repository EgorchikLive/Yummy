import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:yummy/pages/test_list.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<Map<String, dynamic>> likedFoodList = [];

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  // Загрузка избранных товаров из SharedPreferences
  _loadLikedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> likedItems = [];

    for (var foodItem in foodList) {
      bool? isLiked = prefs.getBool('isLiked_${foodItem['id']}');
      if (isLiked == true) {
        likedItems.add(foodItem); // Добавляем в список, если товар в избранном
      }
    }

    setState(() {
      likedFoodList = likedItems; // Обновляем состояние с избранными товарами
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: likedFoodList.isEmpty
          ? const Center(child: Text('Нет избранных товаров'))
          : ListView.builder(
              itemCount: likedFoodList.length,
              itemBuilder: (context, index) {
                return CardPage(
                  id: likedFoodList[index]['id']!,
                  name: likedFoodList[index]['name']!,
                  imageUrl: likedFoodList[index]['image']!,
                  price: int.parse(likedFoodList[index]['price']!.toString()),
                  discount: double.parse(
                      likedFoodList[index]['discount']!.toString()),
                );
              },
            ),
    );
  }
}
