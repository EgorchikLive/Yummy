import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy/assets/theme/pallete.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0.0');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Функция для получения следующего ID
  Future<String> _getNextFoodId() async {
    try {
      // Получаем все товары и сортируем по ID в числовом порядке
      QuerySnapshot snapshot = await _firestore
          .collection('foods')
          .orderBy('id')
          .get();

      if (snapshot.docs.isEmpty) {
        return '1'; // Если товаров нет, начинаем с 1
      }

      // Преобразуем ID в числа и находим максимальный
      int maxId = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String id = data['id'] ?? '';
        int? numericId = int.tryParse(id);
        if (numericId != null && numericId > maxId) {
          maxId = numericId;
        }
      }

      return (maxId + 1).toString();
    } catch (e) {
      print('Ошибка при получении следующего ID: $e');
      // В случае ошибки возвращаем timestamp как fallback
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Валидация URL
  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите URL изображения';
    }
    if (!value.startsWith('http')) {
      return 'Пожалуйста, введите корректный URL';
    }
    return null;
  }

  Future<void> _addFoodToFirebase() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Получаем следующий ID
        final String foodId = await _getNextFoodId();

        await _firestore.collection('foods').doc(foodId).set({
          'id': foodId,
          'name': _nameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'discount': double.parse(_discountController.text.trim()),
          'description': _descriptionController.text.trim(),
          'image': _imageController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
        });

        // Показываем уведомление об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Товар успешно добавлен! ID: $foodId'),
            backgroundColor: Colors.green,
          ),
        );

        // Возвращаемся на главную страницу с результатом, чтобы обновить данные
        Navigator.pop(context, true);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при добавлении товара: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _discountController.text = '0.0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить новый товар'),
        backgroundColor: Pallete.orange,
        foregroundColor: Pallete.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Очистить форму',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Превью изображения
                if (_imageController.text.isNotEmpty)
                  Container(
                    width: 200,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 50);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),

                // Поле названия
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название товара *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название товара';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле цены
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Цена *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: '₽',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите цену';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите корректную цену';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Цена должна быть больше 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле скидки
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Скидка',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.discount),
                    suffixText: '%',
                    hintText: '0.0',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final discount = double.tryParse(value);
                      if (discount == null) {
                        return 'Пожалуйста, введите корректную скидку';
                      }
                      if (discount < 0 || discount > 100) {
                        return 'Скидка должна быть от 0 до 100%';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле описания
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле URL изображения
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'URL изображения *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Обновляем превью изображения
                  },
                  validator: _validateUrl,
                ),
                const SizedBox(height: 24),

                // Кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addFoodToFirebase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.orange,
                          foregroundColor: Pallete.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Добавить товар'),
                      ),
                    ),
                  ],
                ),

                // Пример данных для быстрого заполнения
                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  'Пример данных:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildExampleChip(
                      'Филладельфия',
                      'Классический ролл с лососем и сливочным сыром',
                      '599',
                      '0.2',
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Emojione_1F363.svg.png',
                    ),
                    _buildExampleChip(
                      'Калифорния',
                      'Ролл с крабом и авокадо',
                      '499',
                      '0.1',
                      'https://example.com/california.jpg',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExampleChip(
    String name,
    String description,
    String price,
    String discount,
    String imageUrl,
  ) {
    return ActionChip(
      label: Text(name),
      onPressed: () {
        _nameController.text = name;
        _descriptionController.text = description;
        _priceController.text = price;
        _discountController.text = discount;
        _imageController.text = imageUrl;
        setState(() {});
      },
      backgroundColor: Pallete.orangeLight,
    );
  }
}