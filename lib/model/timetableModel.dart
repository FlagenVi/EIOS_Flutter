class Auditorium {
  final int id;
  final String number;
  final String title;
  final int campusid;
  final String campustitle;

  Auditorium({
    required this.id,
    required this.number,
    required this.title,
    required this.campusid,
    required this.campustitle,
  });

  factory Auditorium.fromJson(Map<String, dynamic> json) {
    return Auditorium(
      id: json['Id'] as int? ?? 0,
      number: json['Number'] as String? ?? '',
      title: json['Title'] as String? ?? '',
      campusid: json['CampusId'] as int? ?? 0,
      campustitle: json['CampusTitle'] as String? ?? '',
    );
  }
}

enum TimeTableLessonDisciplineTypeEnum { DEFAULT, CONSULTATION, OFFSET, EXAM }

TimeTableLessonDisciplineTypeEnum parseDisciplineType(int? type) {
  switch (type) {
    case 1:
      return TimeTableLessonDisciplineTypeEnum.CONSULTATION;
    case 2:
      return TimeTableLessonDisciplineTypeEnum.OFFSET;
    case 3:
      return TimeTableLessonDisciplineTypeEnum.EXAM;
    default:
      return TimeTableLessonDisciplineTypeEnum.DEFAULT;
  }
}


class UserCrop {
  final String id;
  final String name;
  final String fio;
  final String photoUrl;

  UserCrop({
    required this.id,
    required this.name,
    required this.fio,
    required this.photoUrl,
  });

  factory UserCrop.fromJson(Map<String, dynamic> json) {
    final photoJson = json['Photo'];
    String photoUrl = '';
    if (photoJson != null && photoJson is Map<String, dynamic>) {
      photoUrl = photoJson['UrlSource'] as String? ?? '';
    }
    return UserCrop(
      id: json['Id'] as String? ?? '',
      name: json['UserName'] as String? ?? '',
      fio: json['FIO'] as String? ?? '',
      photoUrl: photoUrl,
    );
  }
}

class TimeTableLessonDiscipline {
  final int id;
  final String title;
  final String language;
  final TimeTableLessonDisciplineTypeEnum lessonType;
  final bool remote;
  final String group;
  final int subgroupNumber;
  final UserCrop teacher;
  final Auditorium auditorium;

  TimeTableLessonDiscipline({
    required this.id,
    required this.title,
    required this.language,
    required this.lessonType,
    required this.remote,
    required this.group,
    required this.subgroupNumber,
    required this.teacher,
    required this.auditorium,
  });

  factory TimeTableLessonDiscipline.fromJson(Map<String, dynamic> json) {
    return TimeTableLessonDiscipline(
      id: json['Id'] as int? ?? 0,
      title: json['Title'] as String? ?? '',
      language: json['Language'] as String? ?? '',
      lessonType: parseDisciplineType(json['LessonType'] as int?),
      remote: json['Remote'] as bool? ?? false,
      group: json['Group'] as String? ?? '',
      subgroupNumber: json['SubgroupNumber'] as int? ?? 0,
      teacher: json['Teacher'] != null
          ? UserCrop.fromJson(json['Teacher'] as Map<String, dynamic>)
          : UserCrop(id: '', name: '', fio: '', photoUrl: ''),
      auditorium: json['Auditorium'] != null
          ? Auditorium.fromJson(json['Auditorium'] as Map<String, dynamic>)
          : Auditorium(id: 0, number: '', title: '', campusid: 0, campustitle: ''),
    );
  }
}

class TimeTableLesson {
  final int number;
  final int subgroupCount;
  final List<TimeTableLessonDiscipline> disciplines;

  TimeTableLesson({
    required this.number,
    required this.subgroupCount,
    required this.disciplines,
  });

  factory TimeTableLesson.fromJson(Map<String, dynamic> json) {
    var disciplinesJson = json['Disciplines'] as List<dynamic>? ?? [];

    List<TimeTableLessonDiscipline> disciplinesList = disciplinesJson
        .map((d) => TimeTableLessonDiscipline.fromJson(d as Map<String, dynamic>))
        .toList();
    return TimeTableLesson(
      number: json['Number'] as int? ?? 0,
      subgroupCount: json['SubgroupCount'] as int? ?? 0,
      disciplines: disciplinesList,
    );
  }
}

class TimeTable {
  final String date;
  final List<TimeTableLesson> lessons;

  TimeTable({
    required this.date,
    required this.lessons,
  });

  factory TimeTable.fromJson(Map<String, dynamic> json) {
    var lessonsJson = json['Lessons'] as List<dynamic>? ?? [];
    List<TimeTableLesson> lessonsList = lessonsJson
        .map((l) => TimeTableLesson.fromJson(l as Map<String, dynamic>))
        .toList();
    return TimeTable(
      date: json['Date'] as String? ?? '',
      lessons: lessonsList,
    );
  }
}

class StudentTimeTable {
  final String? group;
  final String? planNumber;
  final String? facultyName;
  final int? timeTableBlockd;
  final TimeTable? timeTable;

  StudentTimeTable({
    this.group,
    this.planNumber,
    this.facultyName,
    this.timeTableBlockd,
    this.timeTable,
  });

  factory StudentTimeTable.fromJson(Map<String, dynamic> json) {
    print("DEBUG StudentTimeTable JSON: $json");
    return StudentTimeTable(
      group: json['Group'] as String? ?? '',
      planNumber: json['PlanNumber'] as String? ?? '',
      facultyName: json['FacultyName'] as String? ?? '',
      timeTableBlockd: json['TimeTableBlockd'] as int? ?? 0,
      timeTable: json['TimeTable'] != null
          ? TimeTable.fromJson(json['TimeTable'] as Map<String, dynamic>)
          : null,
    );
  }
}
