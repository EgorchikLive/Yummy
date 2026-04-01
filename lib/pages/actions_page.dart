import 'package:flutter/material.dart';
import 'package:yummy/utils/responsive_utils.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
      
  List<Map<String, dynamic>> _discountFoodList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDiscountFoods();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadDiscountFoods() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('foods').get();
      List<Map<String, dynamic>> discountFoods = snapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return {
              'id': data['id'] ?? '',
              'name': data['name'] ?? 'Без названия',
              'image': data['image'] ?? '',
              'price': data['price'] ?? 0,
              'discount': data['discount'] ?? 0.0,
              'description': data['description'] ?? '',
            };
          })
          .where((item) => item['discount'] > 0)
          .toList();

      setState(() {
        _discountFoodList = discountFoods;
      });
    } catch (e) {
      print('Ошибка загрузки товаров со скидкой: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDiscountFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Скидки')),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _discountFoodList.isEmpty
                ? const Center(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.discount, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Нет товаров со скидками',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Потяните вниз для обновления',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getCrossAxisCount(context),
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                    ),
                    itemCount: _discountFoodList.length,
                    itemBuilder: (context, index) {
                      return CardPage(
                        id: _discountFoodList[index]['id']!,
                        name: _discountFoodList[index]['name']!,
                        imageUrl: _discountFoodList[index]['image']!,
                        price: _discountFoodList[index]['price']!,
                        discount: _discountFoodList[index]['discount']!,
                        description: _discountFoodList[index]['description']!,
                      );
                    },
                  ),
      ),
    );
  }
}