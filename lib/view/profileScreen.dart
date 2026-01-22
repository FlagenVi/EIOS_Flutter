import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/userModel.dart';
import '../model/newsModel.dart';
import '../service/apiService.dart';
import 'loginScreen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Token token;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.token,
  }) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<List<News>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiService().getNews(widget.token.tokenType, widget.token.accessToken);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('tokenType');
    await prefs.remove('user');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPhoto = (widget.user.photo != null && widget.user.photo!.urlSource.isNotEmpty)
        ? NetworkImage(widget.user.photo!.urlSource)
        : const AssetImage('assets/images/user.svg') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: AppGradients.page,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Фото профиля
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ],
                  image: DecorationImage(
                    image: userPhoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Имя пользователя
              Text(
                widget.user.fio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              // Заголовок раздела новостей
              const Text(
                'Новости',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Список новостей
              FutureBuilder<List<News>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Ошибка загрузки новостей: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Нет новостей');
                  }

                  final allNews = snapshot.data!;
                  // Сортируем новости по дате публикации (от новых к старым)
                  allNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
                  // Берём только последние 10 новостей
                  final limitedNews = allNews.take(10).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: limitedNews.length,
                    itemBuilder: (context, index) {
                      final news = limitedNews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Html(
                            data: news.shortText.isNotEmpty ? news.shortText : news.text,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14.0),
                                color: Colors.black87,
                              ),
                            },
                          ),
                        ),
                      );
                    },
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
