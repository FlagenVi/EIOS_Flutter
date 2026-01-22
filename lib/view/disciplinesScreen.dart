import 'package:flutter/material.dart';
import '../service/apiService.dart';
import '../model/studentSemesterModel.dart';
import '../view/ratingPlanScreen.dart';
import '../theme/app_theme.dart';

class DisciplinesScreen extends StatefulWidget {
  final String tokenType;
  final String accessToken;

  const DisciplinesScreen({
    Key? key,
    required this.tokenType,
    required this.accessToken,
  }) : super(key: key);

  @override
  DisciplinesScreenState createState() => DisciplinesScreenState();
}

class DisciplinesScreenState extends State<DisciplinesScreen> {
  bool _loading = true;
  String? _errorMessage;
  StudentSemester? _studentSemester;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchStudentSemester();
  }

  Future<void> _fetchStudentSemester() async {
    print("Начало запроса семестра");
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      StudentSemester semester = await _apiService.getStudentSemester(
        widget.tokenType,
        widget.accessToken,
      );
      setState(() {
        _studentSemester = semester;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  // Метод для построения красивой кнопки для дисциплины
  Widget _buildDisciplineButton(Discipline discipline) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingPlanScreen(
              disciplineId: discipline.id,
              disciplineTitle: discipline.title,
              tokenType: widget.tokenType,
              accessToken: widget.accessToken,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            discipline.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Дисциплины"),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text("Ошибка: $_errorMessage"))
            : _studentSemester == null
            ? const Center(child: Text("Нет данных"))
            : ListView.builder(
          itemCount: _studentSemester!.recordBooks.length,
          itemBuilder: (context, index) {
            final recordBook = _studentSemester!.recordBooks[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    recordBook.faculty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: recordBook.disciplines
                        .map((discipline) =>
                        _buildDisciplineButton(discipline))
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
