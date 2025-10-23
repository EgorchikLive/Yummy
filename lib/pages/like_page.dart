import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yummy/widgets/card_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Map<String, dynamic>> _foodList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedItems();
  }

  Future<void> _loadLikedItems() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _foodList = [];
      });
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      List<Map<String, dynamic>> likedItems = [];

      for (var doc in snapshot.docs) {
        var productDoc = await FirebaseFirestore.instance
            .collection('foods')
            .doc(doc.id)
            .get();

        if (productDoc.exists) {
          var data = productDoc.data() as Map<String, dynamic>;
          likedItems.add({
            'id': data['id'] ?? '',
            'name': data['name'] ?? 'Без названия',
            'image': data['image'] ?? '',
            'price': data['price'] ?? 0,
            'discount': data['discount'] ?? 0.0,
            'description': data['description'] ?? '',
          });
        }
      }

      setState(() {
        _foodList = likedItems;
      });
    } catch (e) {
      print('Ошибка загрузки избранного: $e');
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
    await _loadLikedItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _foodList.isEmpty
            ? const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Center(
                  heightFactor: 12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Нет избранных товаров',
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
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _foodList.length,
                itemBuilder: (context, index) {
                  return CardPage(
                    id: _foodList[index]['id'] ?? '',
                    name: _foodList[index]['name'] ?? 'Без названия',
                    imageUrl: _foodList[index]['image'] ?? '',
                    price: _foodList[index]['price'] ?? 0,
                    discount: _foodList[index]['discount'] ?? 0.0,
                    description: _foodList[index]['description'] ?? '',
                  );
                },
              ),
      ),
    );
  }
}
