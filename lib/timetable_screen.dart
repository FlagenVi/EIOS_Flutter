import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';
import 'api_service.dart';
import 'models/timetable_models.dart';

class TimetableScreen extends StatefulWidget {
  final String tokenType;
  final String accessToken;

  const TimetableScreen({
    Key? key,
    required this.tokenType,
    required this.accessToken,
  }) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  DateTime _selectedDay = DateTime.now();
  List<StudentTimeTable> _timetable = [];
  bool _loading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  final List<String> pairTimes = [
    "8:00 - 9:30",
    "9:45 - 11:15",
    "11:35 - 13:05",
    "13:20 - 14:50",
    "15:00 - 16:30",
    "16:40 - 18:10",
    "18:15 - 19:45",
  ];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      String dateString =
          "${_selectedDay.year.toString().padLeft(4, '0')}-"
          "${_selectedDay.month.toString().padLeft(2, '0')}-"
          "${_selectedDay.day.toString().padLeft(2, '0')}";
      List<StudentTimeTable> timetable = await _apiService.getStudentTimeTable(
        widget.tokenType,
        widget.accessToken,
        dateString,
      );
      setState(() {
        _timetable = timetable;
      });
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
    StudentTimeTable? dayTimetable = _timetable.isNotEmpty ? _timetable[0] : null;
    List<TimeTableLesson> lessons = dayTimetable?.timeTable?.lessons ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _fetchTimetable();
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("Ошибка: $_errorMessage"))
                : ListView.builder(
              itemCount: pairTimes.length,
              itemBuilder: (context, index) {
                final lesson = lessons.firstWhereOrNull((l) => l.number == index + 1);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Пара №${index + 1} • ${pairTimes[index]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        lesson == null
                            ? const Text("Нет пары")
                            : buildLessonBlock(lesson),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLessonBlock(TimeTableLesson lesson) {
    if (lesson.subgroupCount == 0) {
      final discipline = lesson.disciplines.isNotEmpty ? lesson.disciplines.first : null;
      return discipline != null
          ? buildDisciplineBlock(discipline)
          : const Text("Данные отсутствуют");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lesson.disciplines.map((discipline) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Подгруппа: ${discipline.subgroupNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                buildDisciplineBlock(discipline),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  Widget buildDisciplineBlock(TimeTableLessonDiscipline discipline) {
    final teacherPhoto = discipline.teacher.photoUrl.isNotEmpty
        ? NetworkImage(discipline.teacher.photoUrl)
        : const AssetImage('assets/images/user.svg') as ImageProvider;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: teacherPhoto,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                discipline.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text("Аудитория: ${discipline.auditorium.number} (${discipline.auditorium.title})"),
              const SizedBox(height: 4),
              Text("Преподаватель: ${discipline.teacher.fio}"),
            ],
          ),
        ),
      ],
    );
  }
}
