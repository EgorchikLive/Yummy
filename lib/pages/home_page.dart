import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/menu_page.dart';
import 'package:yummy/pages/user_page.dart';

import '../services/auth_storage_service.dart';
import 'main_page.dart';
import 'account_page.dart';
import 'actions_page.dart';
import 'checkout_page.dart';
import 'like_page.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({super.key, this.selectedIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool isLoggedIn = false; // Добавляем состояние авторизации
  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final savedState = await _authStorage.getLoginState();
    setState(() {
      isLoggedIn = savedState;
    });
  }

  Future<void> toggleLoginStatus() async {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
    await _authStorage.saveLoginState(isLoggedIn);
  }

  Future<void> logout() async {
    setState(() {
      isLoggedIn = false;
    });
    await _authStorage.clearLoginState();
    // Дополнительно: очистка контроллеров или других данных
  }

  // Модифицируем список страниц
  // В HomePage измените pages:
  List<Widget> get pages => [
        const MainPage(),
        const ActionsPage(),
        const CheckoutPage(),
        const LikePage(),
        isLoggedIn
            ? const UserPage()
            : AccountPage(onLoginSuccess: toggleLoginStatus),
      ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // ctrl.fetchProducts();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yummy'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              ZoomDrawer.of(context)!.toggle();
            },
          ),
          backgroundColor: Pallete.orange,
        ),
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Pallete.gray,
          fixedColor: Pallete.orange,
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.checkmark_seal),
              label: 'Акции',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Корзина',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              label: 'Избранное',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp),
              label: 'Аккаунт',
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final int selectedIndex;

  const DrawerWidget({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuBackgroundColor: Pallete.menu,
      controller: ZoomDrawerController(),
      mainScreen: HomePage(selectedIndex: selectedIndex),
      menuScreen: MenuPage(
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

