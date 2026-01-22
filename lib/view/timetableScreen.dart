import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';
import '../service/apiService.dart';
import '../model/timetableModel.dart';
import '../service/timetableDatabase.dart';
import '../theme/app_theme.dart';

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
  final TimetableDatabase _database = TimetableDatabase.instance;

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
    String dateString =
        "${_selectedDay.year.toString().padLeft(4, '0')}-"
        "${_selectedDay.month.toString().padLeft(2, '0')}-"
        "${_selectedDay.day.toString().padLeft(2, '0')}";
    try {
      final response = await _apiService.getStudentTimeTable(
        widget.tokenType,
        widget.accessToken,
        dateString,
      );
      await _database.saveTimetable(dateString, response.raw);
      if (!mounted) {
        return;
      }
      setState(() {
        _timetable = response.items;
      });
    } catch (e) {
      final cached = await _database.getTimetable(dateString);
      if (!mounted) {
        return;
      }
      if (cached != null) {
        setState(() {
          _timetable = cached;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (!mounted) {
        return;
      }
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.page,
        ),
        child: Column(
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
                titleTextStyle: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black87),
                weekendStyle: TextStyle(color: Colors.black54),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.black87),
                weekendTextStyle: const TextStyle(color: Colors.black54),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Text(
                  "Ошибка: $_errorMessage",
                  style: const TextStyle(color: Colors.black87),
                ),
              )
                  : ListView.builder(
                itemCount: pairTimes.length,
                itemBuilder: (context, index) {
                  final lesson = lessons.firstWhereOrNull((l) => l.number == index + 1);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppGradients.card,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок с номером пары и временем
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Пара №${index + 1} • ${pairTimes[index]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            lesson == null
                                ? const Text(
                              "Нет пары",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            )
                                : buildLessonBlock(lesson),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLessonBlock(TimeTableLesson lesson) {
    if (lesson.subgroupCount == 0) {
      final discipline = lesson.disciplines.isNotEmpty ? lesson.disciplines.first : null;
      return discipline != null
          ? buildDisciplineBlock(discipline)
          : const Text(
        "Данные отсутствуют",
        style: TextStyle(color: Colors.black87, fontSize: 16),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lesson.disciplines.map((discipline) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Подгруппа: ${discipline.subgroupNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
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
        CircleAvatar(
          radius: 24,
          backgroundImage: teacherPhoto,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                discipline.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Аудитория: ${discipline.auditorium.number} (${discipline.auditorium.title})",
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                "Преподаватель: ${discipline.teacher.fio}",
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
