import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/pages/menu_page.dart';

import 'main_page.dart';
import 'account_page.dart';
import 'actions_page.dart';
import 'checkout_page.dart';
import 'like_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final pages = [
    const MainPage(),
    const ActionsPage(),
    const CheckoutPage(),
    const LikePage(),
    const AccountPage(),
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
            // type: BottomNavigationBarType.fixed,
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
            ]),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DrawerWidget({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuBackgroundColor: Pallete.menu,
      controller: ZoomDrawerController(),
      mainScreen: const HomePage(),
      menuScreen: MenuPage(
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}
