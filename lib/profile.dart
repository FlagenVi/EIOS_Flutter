import 'package:eios_flut/models/user_models.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final Token token;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPhoto = (user.photo != null && user.photo!.urlSource.isNotEmpty)
        ? NetworkImage(user.photo!.urlSource)
        : const AssetImage('assets/images/user.svg') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Профиль"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
            radius: 1.0,
            colors: [
              Colors.grey.shade800,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: userPhoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Имя пользователя (FIO)
            Text(
              user.fio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
