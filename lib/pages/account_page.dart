import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/services/auth_service.dart';
import 'package:yummy/widgets/custom_button.dart';
import 'package:yummy/widgets/custom_field.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final PageController _pageController = PageController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.toInt() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.toInt();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView с двумя страницами
          PageView(
            controller: _pageController,
            children: [
              AuthPage(
                emailController: emailController,
                passwordController: passwordController,
              ), // Передаем контроллеры в AuthPage
              RegisterPage(
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
              ), // Передаем контроллеры в RegisterPage
            ],
          ),

          // Индикатор слайдера поверх страниц
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Pallete.orange
                        : Pallete.grayLight,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Страница Авторизации
class AuthPage extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AuthPage({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Авторизация',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Pallete.orange,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: const Text(
                  'Почта',
                  style: TextStyle(
                    color: Pallete.orange,
                  ),
                ),
                hintText: 'Почта',
                controller: emailController,
              ),
              const SizedBox(height: 18),
              CustomField(
                label: const Text(
                  'Пароль',
                  style: TextStyle(
                    color: Pallete.orange,
                  ),
                ),
                hintText: 'Пароль',
                controller: passwordController,
              ),
              const SizedBox(height: 18),
              CustomButton(buttonText: 'Войти', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// Страница Регистрации
class RegisterPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const RegisterPage({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Pallete.orange,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: const Text(
                  'Имя',
                  style: TextStyle(
                    color: Pallete.orange,
                  ),
                ),
                hintText: 'Имя',
                controller: nameController,
              ),
              const SizedBox(height: 18),
              CustomField(
                label: const Text(
                  'Почта',
                  style: TextStyle(
                    color: Pallete.orange,
                  ),
                ),
                hintText: 'Почта',
                controller: emailController,
              ),
              const SizedBox(height: 18),
              CustomField(
                label: const Text(
                  'Пароль',
                  style: TextStyle(
                    color: Pallete.orange,
                  ),
                ),
                hintText: 'Пароль',
                controller: passwordController,
              ),
              const SizedBox(height: 18),
              CustomButton(
                buttonText: 'Зарегистрироваться',
                onTap: () async {
                  await AuthService().register(
                    username: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
