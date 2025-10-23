import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'dart:io';

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
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedImage;
  bool _isUsingUrl = true;

  Future<String> _getNextFoodId() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('foods')
          .orderBy('id')
          .get();

      if (snapshot.docs.isEmpty) {
        return '1';
      }

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
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  String? _validateImage() {
    if (_isUsingUrl) {
      if (_imageController.text.isEmpty) {
        return 'Пожалуйста, введите URL изображения';
      }
      if (!_imageController.text.startsWith('http')) {
        return 'Пожалуйста, введите корректный URL';
      }
    } else {
      if (_selectedImage == null) {
        return 'Пожалуйста, выберите изображение';
      }
    }
    return null;
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isUsingUrl = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выборе изображения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isUsingUrl = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при съемке фото: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    // Здесь должна быть реализация загрузки изображения в Firebase Storage
    // Пока возвращаем временный URL для демонстрации
    await Future.delayed(const Duration(seconds: 1)); // Имитация загрузки
    
    // В реальном приложении здесь должен быть код для загрузки в Firebase Storage
    // и получения download URL
    return 'https://via.placeholder.com/300x200?text=Uploaded+Image';
  }

  Future<void> _addFoodToFirebase() async {
    if (_formKey.currentState!.validate() && _validateImage() == null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String foodId = await _getNextFoodId();
        String imageUrl = '';

        if (_isUsingUrl) {
          imageUrl = _imageController.text.trim();
        } else if (_selectedImage != null) {
          // Загружаем изображение в Firebase Storage
          imageUrl = await _uploadImageToFirebase(_selectedImage!);
        }

        await _firestore.collection('foods').doc(foodId).set({
          'id': foodId,
          'name': _nameController.text.trim(),
          'price': num.parse(_priceController.text.trim()),
          'discount': num.parse(_discountController.text.trim()),
          'description': _descriptionController.text.trim(),
          'image': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Товар успешно добавлен! ID: $foodId'),
            backgroundColor: Colors.green,
          ),
        );

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validateImage() ?? 'Пожалуйста, заполните все поля'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Превью изображения
                _buildImagePreview(),
                const SizedBox(height: 20),

                // Переключатель способа загрузки изображения
                _buildImageSourceSelector(),
                const SizedBox(height: 16),

                // Поле для URL или кнопки загрузки
                _isUsingUrl ? _buildUrlInput() : _buildImageUploadButtons(),
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

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
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Emojione_1F363.svg/640px-Emojione_1F363.svg.png',
                    ),
                    _buildExampleChip(
                      'Калифорния',
                      'Ролл с крабом и авокадо',
                      '499',
                      '0.1',
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Emojione_1F363.svg/640px-Emojione_1F363.svg.png',
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

  Widget _buildImagePreview() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isUsingUrl
            ? _imageController.text.isNotEmpty
                ? Image.network(
                    _imageController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Неверный URL', style: TextStyle(fontSize: 12)),
                        ],
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Введите URL', style: TextStyle(fontSize: 12)),
                    ],
                  )
            : _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Выберите фото', style: TextStyle(fontSize: 12)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildImageSourceSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Способ загрузки изображения:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isUsingUrl = true;
                        _selectedImage = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _isUsingUrl ? Pallete.orange.withOpacity(0.1) : null,
                      side: BorderSide(
                        color: _isUsingUrl ? Pallete.orange : Colors.grey,
                      ),
                    ),
                    child: Text(
                      'URL',
                      style: TextStyle(
                        color: _isUsingUrl ? Pallete.orange : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isUsingUrl = false;
                        _imageController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isUsingUrl ? Pallete.orange.withOpacity(0.1) : null,
                      side: BorderSide(
                        color: !_isUsingUrl ? Pallete.orange : Colors.grey,
                      ),
                    ),
                    child: Text(
                      'С устройства',
                      style: TextStyle(
                        color: !_isUsingUrl ? Pallete.orange : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInput() {
    return TextFormField(
      controller: _imageController,
      decoration: const InputDecoration(
        labelText: 'URL изображения *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
        hintText: 'https://example.com/image.jpg',
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildImageUploadButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Галерея'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhotoWithCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Камера'),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 8),
          Text(
            'Выбрано: ${_selectedImage!.path.split('/').last}',
            style: const TextStyle(fontSize: 12, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ],
      ],
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
        _isUsingUrl = true;
        _selectedImage = null;
        setState(() {});
      },
      backgroundColor: Pallete.orangeLight,
    );
  }
}