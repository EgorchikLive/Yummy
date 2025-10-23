import 'package:flutter/material.dart';
import 'package:yummy/assets/theme/pallete.dart';
import 'package:yummy/services/auth_service.dart';
import 'package:yummy/widgets/custom_button.dart';
import 'package:yummy/widgets/custom_field.dart';

class AccountPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AccountPage({
    super.key,
    required this.onLoginSuccess,
  });

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
          PageView(
            controller: _pageController,
            children: [
              AuthPage(
                emailController: emailController,
                passwordController: passwordController,
                onLoginSuccess: widget.onLoginSuccess,
              ),
              RegisterPage(
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
                onLoginSuccess: widget.onLoginSuccess,
              ),
            ],
          ),

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

class AuthPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginSuccess;

  const AuthPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginSuccess,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

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
                controller: widget.emailController,
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
                controller: widget.passwordController,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Pallete.orange,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                  buttonText: 'Войти',
                  onTap: () async {
                    bool isSuccess = await AuthService().signIn(
                      email: widget.emailController.text,
                      password: widget.passwordController.text,
                    );

                    if (isSuccess) {
                      widget.onLoginSuccess(); // Успешный вход
                    } else {
                      // Ошибка авторизации
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Неверный логин или пароль')),
                      );
                    }
                  }),
              // const SizedBox(height: 10),
              // // 🔹 Кнопка входа через Google
              // ElevatedButton.icon(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.white,
              //     foregroundColor: Colors.black,
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //     side: const BorderSide(color: Pallete.orange),
              //   ),
              //   icon: Image.asset(
              //     'assets/icons/google.png',
              //     height: 24,
              //   ),
              //   label: const Text(
              //     'Войти через Google',
              //     style: TextStyle(fontWeight: FontWeight.w600),
              //   ),
              //   onPressed: () async {
              //     bool success = await AuthService().signInWithGoogle();
              //     if (success) {
              //       onLoginSuccess();
              //     } else {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text('Ошибка входа через Google')),
              //       );
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginSuccess;

  const RegisterPage({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onLoginSuccess,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

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
                controller: widget.nameController,
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
                controller: widget.emailController,
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
                controller: widget.passwordController,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Pallete.orange,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                buttonText: 'Зарегистрироваться',
                onTap: () async {
                  bool isSuccess = await AuthService().register(
                    username: widget.nameController.text,
                    email: widget.emailController.text,
                    password: widget.passwordController.text,
                  );

                  if (isSuccess) {
                    widget.onLoginSuccess();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ошибка регистрации')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}