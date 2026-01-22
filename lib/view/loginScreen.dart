import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../service/apiService.dart';
import '../model/userModel.dart';
import 'homeScreen.dart';
import '../theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');
  String? tokenType = prefs.getString('tokenType');
  String? userJson = prefs.getString('user');

  Widget startScreen;
  if (accessToken != null && tokenType != null && userJson != null) {
    User user = User.fromJson(jsonDecode(userJson));
    Token token = Token(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresIn: 0,
      refreshToken: '',
    );
    startScreen = HomeScreen(token: token, user: user);
  } else {
    startScreen = const LoginScreen();
  }

  runApp(MyApp(homeScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({Key? key, required this.homeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ЭИОС',
      theme: buildAppTheme(),
      home: homeScreen,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final token = await _apiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      final user = await _apiService.getUser(token.tokenType, token.accessToken);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token.accessToken);
      await prefs.setString('tokenType', token.tokenType);
      await prefs.setString('user', jsonEncode(user.toJson()));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(token: token, user: user),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.page,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(0, 12),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Имя пользователя',
                    prefixIcon: Icon(Icons.person_outline),
                    prefixIconColor: AppColors.primary,
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                    prefixIconColor: AppColors.primary,
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'ВОЙТИ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
