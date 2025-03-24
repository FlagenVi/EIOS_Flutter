import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models/student_semester_models.dart';
import 'rating_plan_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.black26;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Дисциплины"),
      ),
      body: _loading
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
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: recordBook.disciplines.map((discipline) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: 4.0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          onPressed: () {
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
                          child: Text(
                            discipline.title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
