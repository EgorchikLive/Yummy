import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy/widgets/card_page.dart';

class FoodList extends StatefulWidget {
  final bool isAdmin;
  const FoodList({super.key, required this.isAdmin});

  @override
  State<FoodList> createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Map<String, dynamic>> _foodList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodList();
  }

  Future<void> _loadFoodList() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('foods').get();

      final foodList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': data['id'] ?? '',
          'name': data['name'] ?? 'Без названия',
          'image': data['image'] ?? '',
          'price': data['price'] ?? 0,
          'discount': data['discount'] ?? 0.0,
          'description': data['description'] ?? '',
        };
      }).toList();

      setState(() => _foodList = foodList);
    } catch (e) {
      debugPrint('Ошибка загрузки списка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadFoodList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_foodList.isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fastfood, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Нет данных о товарах',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Потяните вниз для обновления',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _foodList.length,
        itemBuilder: (context, index) {
          final food = _foodList[index];
          return CardPage(
            id: food['id'],
            name: food['name'],
            imageUrl: food['image'],
            price: food['price'],
            discount: food['discount'],
            description: food['description'],
          );
        },
      ),
    );
  }
}
