import 'package:eios_flut/model/userModel.dart';
import 'package:flutter/material.dart';
import 'profileScreen.dart';
import 'timetableScreen.dart';
import '../view/disciplinesScreen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;
  final User user;

  const HomeScreen({
    Key? key,
    required this.token,
    required this.user,
  }) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget?> _screens = [null, null, null];


  final GlobalKey<DisciplinesScreenState> _disciplinesKey = GlobalKey<DisciplinesScreenState>();

  @override
  Widget build(BuildContext context) {
    if (_screens[0] == null) {
      _screens[0] = ProfileScreen(user: widget.user, token: widget.token);
    }
    if (_selectedIndex == 1 && _screens[1] == null) {
      _screens[1] = TimetableScreen(
        tokenType: widget.token.tokenType,
        accessToken: widget.token.accessToken,
      );
    }
    if (_selectedIndex == 2 && _screens[2] == null) {
      _screens[2] = DisciplinesScreen(
        tokenType: widget.token.tokenType,
        accessToken: widget.token.accessToken,
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens.map((screen) => screen ?? Container()).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Расписание"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Дисциплины"),
        ],
      ),
    );
  }
}

