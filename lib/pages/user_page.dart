import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../provider/theme_provider.dart';
import '../services/auth_storage_service.dart';

class UserPage extends StatefulWidget {
  final VoidCallback onLogout;

  const UserPage({super.key, required this.onLogout});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ImagePicker _imagePicker = ImagePicker();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Ошибка загрузки данных');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackbar('Ошибка при выборе изображения');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackbar('Ошибка при съемке фото');
    }
  }

  Future<void> _uploadImage() async {
    final user = _auth.currentUser;
    if (user == null || _selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // В реальном приложении здесь должна быть загрузка в Firebase Storage
      // Для демонстрации используем временный URL
      await Future.delayed(const Duration(seconds: 2)); // Имитация загрузки
      
      // В реальном приложении:
      // 1. Загружаем файл в Firebase Storage
      // 2. Получаем download URL
      // 3. Сохраняем URL в Firestore
      
      final String imageUrl = 'https://via.placeholder.com/150?text=New+Avatar';

      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _userData?['avatarUrl'] = imageUrl;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аватарка успешно обновлена'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackbar('Ошибка загрузки аватарки');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoWithCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Метод для обновления данных при свайпе
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchUserData();
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;

      final authStorage = AuthStorageService();
      await authStorage.clearLoginState();

      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      await ThemeProvider.saveThemeState(isDarkMode);

      widget.onLogout();
    } catch (e) {
      _showErrorSnackbar('Ошибка при выходе');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userData == null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Информация о пользователе
          _buildUserProfile(isDark),

          // Разделитель
          Container(
            height: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),

          // Заголовок заказов
          _buildOrdersHeader(),

          // Список заказов
          _buildOrdersList(isDark),

          // Кнопка выхода
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        heightFactor: 12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Данные не найдены',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Потяните вниз для обновления',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватарка слева
          _buildAvatarSection(),
          
          const SizedBox(width: 16),
          
          // Имя и email справа
          Expanded(
            child: _buildUserInfoSection(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.orange,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _isUploading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  )
                : _buildAvatarImage(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 14),
              padding: EdgeInsets.zero,
              color: Colors.white,
              onPressed: _isUploading ? null : _showImagePickerDialog,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _userData!['username'] ?? 'Не указано',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Text(
          _userData!['email'] ?? 'Не указан',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    }

    final avatarUrl = _userData?['avatarUrl'];
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildOrdersHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, color: Colors.orange),
          const SizedBox(width: 8),
          const Text(
            'Мои заказы',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('orders')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Text(
                '$count ${_getOrderCountText(count)}',
                style: TextStyle(color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getOrderCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'заказ';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'заказа';
    }
    return 'заказов';
  }

  Widget _buildOrdersList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState('Ошибка загрузки заказов');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('У вас еще нет заказов');
        }

        final orders = snapshot.data!.docs;

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;

            return OrderCard(
              orderData: data,
              orderId: order.id,
              isDark: isDark,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Потяните вниз для обновления',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Выйти из аккаунта'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}

// Остальные классы (InfoField, OrderCard) остаются без изменений
class InfoField extends StatelessWidget {
  final String label;
  final String value;

  const InfoField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  final bool isDark;

  const OrderCard({
    super.key,
    required this.orderData,
    required this.orderId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = (orderData['total'] ?? 0.0).toDouble();
    final createdAt = _getOrderDate();
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
    final status = orderData['status'] ?? 'completed';
    final paymentStatus = orderData['paymentStatus'] ?? 'succeeded';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок заказа
            _buildOrderHeader(createdAt, status, paymentStatus),

            const SizedBox(height: 12),

            // Список товаров
            if (items.isNotEmpty) ..._buildOrderItems(items),

            const SizedBox(height: 12),

            // Итоговая сумма
            _buildOrderTotal(total),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(
      DateTime createdAt, String status, String paymentStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заказ #${orderId.substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadges(status, paymentStatus),
            ],
          ),
        ),
        Text(
          _formatDate(createdAt),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(String status, String paymentStatus) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getPaymentStatusColor(paymentStatus),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPaymentStatusText(paymentStatus),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOrderItems(List<Map<String, dynamic>> items) {
    return [
      ...items.map((item) {
        final name = item['name']?.toString() ?? 'Неизвестный товар';
        final imageUrl = item['imageUrl']?.toString();
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
        final quantity = (item['quantity'] ?? 1) is num
            ? (item['quantity'] ?? 1)
            : 1;

        final total = price * quantity;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${price.toStringAsFixed(2)} ₽ × $quantity',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),

              Text(
                '${total.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildOrderTotal(double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Итого:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₽',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getOrderDate() {
    if (orderData['createdAt'] != null) {
      return (orderData['createdAt'] as Timestamp).toDate();
    }
    return DateTime.now();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Выполнен';
      case 'processing':
        return 'В обработке';
      case 'cancelled':
        return 'Отменен';
      default:
        return 'Неизвестно';
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'succeeded':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String paymentStatus) {
    switch (paymentStatus) {
      case 'succeeded':
        return 'Оплачен';
      case 'pending':
        return 'Ожидает оплаты';
      case 'failed':
        return 'Ошибка оплаты';
      default:
        return 'Неизвестно';
    }
  }
}