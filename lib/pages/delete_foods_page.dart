import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteFoodsPage extends StatefulWidget {
  const DeleteFoodsPage({super.key});

  @override
  State<DeleteFoodsPage> createState() => _DeleteFoodsPageState();
}

class _DeleteFoodsPageState extends State<DeleteFoodsPage> {
  List<Map<String, dynamic>> _foods = [];
  bool _isLoading = true;
  List<String> _selectedFoodIds = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('foods').get();
      setState(() {
        _foods = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'id': data['id'] ?? '',
            'name': data['name'] ?? 'Без названия',
            'image': data['image'] ?? '',
            'price': data['price'] ?? 0,
            'discount': data['discount'] ?? 0.0,
            'description': data['description'] ?? '',
            'documentId': doc.id,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  void _toggleSelection(String foodId) {
    setState(() {
      if (_selectedFoodIds.contains(foodId)) {
        _selectedFoodIds.remove(foodId);
      } else {
        _selectedFoodIds.add(foodId);
      }
      _isSelectionMode = _selectedFoodIds.isNotEmpty;
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedFoodIds.length == _foods.length) {
        _selectedFoodIds.clear();
      } else {
        _selectedFoodIds = _foods.map((food) => food['documentId'] as String).toList();
      }
      _isSelectionMode = _selectedFoodIds.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFoodIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedFoods() async {
    if (_selectedFoodIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить товары'),
        content: Text('Вы уверены, что хотите удалить ${_selectedFoodIds.length} товар(ов)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (String documentId in _selectedFoodIds) {
          await FirebaseFirestore.instance.collection('foods').doc(documentId).delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Удалено ${_selectedFoodIds.length} товар(ов)'),
            backgroundColor: Colors.green,
          ),
        );

        _clearSelection();
        _loadFoods();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('Выбрано: ${_selectedFoodIds.length}')
            : const Text('Удалить товары'),
        backgroundColor: _isSelectionMode ? Colors.red : Colors.red,
        foregroundColor: Colors.white,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Выбрать все',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Очистить выбор',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedFoods,
              tooltip: 'Удалить выбранные',
            ),
          ] else if (!_isLoading && _foods.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => setState(() { _isSelectionMode = true; }),
              tooltip: 'Выбрать товары',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foods.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Нет товаров для удаления',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_isSelectionMode)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.red.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Выбрано: ${_selectedFoodIds.length} из ${_foods.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            TextButton(
                              onPressed: _selectAll,
                              child: Text(
                                _selectedFoodIds.length == _foods.length
                                    ? 'Снять выделение'
                                    : 'Выбрать все',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {
                          final food = _foods[index];
                          final isSelected = _selectedFoodIds.contains(food['documentId']);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: isSelected ? Colors.red.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  Image.network(
                                    food['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.fastfood),
                                  ),
                                  if (_isSelectionMode)
                                    Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.black.withOpacity(0.3),
                                      child: Icon(
                                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(food['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${food['price']} ₽'),
                                  if (food['discount'] > 0)
                                    Text(
                                      'Скидка: ${(food['discount'] * 100).toInt()}%',
                                      style: const TextStyle(color: Colors.green),
                                    ),
                                ],
                              ),
                              trailing: _isSelectionMode
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteSingleFood(food['documentId'], food['name']),
                                    ),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(food['documentId']);
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _toggleSelection(food['documentId']);
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _isSelectionMode && _selectedFoodIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedFoods,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete),
              label: Text('Удалить (${_selectedFoodIds.length})'),
            )
          : null,
    );
  }

  Future<void> _deleteSingleFood(String documentId, String foodName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить товар'),
        content: Text('Вы уверены, что хотите удалить "$foodName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('foods').doc(documentId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Товар "$foodName" удален')),
        );
        _loadFoods();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }
}