class StudentSemester {
  final List<RecordBook> recordBooks;
  final int? unreadedDisCount;
  final int? unreadedDisMesCount;
  final String? year;
  final int? period;

  StudentSemester({
    required this.recordBooks,
    this.unreadedDisCount,
    this.unreadedDisMesCount,
    this.year,
    this.period,
  });

  factory StudentSemester.fromJson(Map<String, dynamic> json) {
    List<RecordBook> books = [];
    if (json['RecordBooks'] != null) {
      books = (json['RecordBooks'] as List)
          .map((e) => RecordBook.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return StudentSemester(
      recordBooks: books,
      unreadedDisCount: json['UnreadedDisCount'] as int?,
      unreadedDisMesCount: json['UnreadedDisMesCount'] as int?,
      year: json['Year'] as String?,
      period: json['Period'] as int?,
    );
  }
}

class RecordBook {
  final String cod;
  final String number;
  final String faculty;
  final List<Discipline> disciplines;

  RecordBook({
    required this.cod,
    required this.number,
    required this.faculty,
    required this.disciplines,
  });

  factory RecordBook.fromJson(Map<String, dynamic> json) {
    List<Discipline> discList = [];
    if (json['Disciplines'] != null) {
      discList = (json['Disciplines'] as List)
          .map((e) => Discipline.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RecordBook(
      cod: json['Cod'] as String? ?? '',
      number: json['Number'] as String? ?? '',
      faculty: json['Faculty'] as String? ?? '',
      disciplines: discList,
    );
  }
}

class Discipline {
  final int id;
  final String planNumber;
  final String title;

  Discipline({
    required this.id,
    required this.planNumber,
    required this.title,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['Id'] as int? ?? 0,
      planNumber: json['PlanNumber'] as String? ?? '',
      title: json['Title'] as String? ?? '',
    );
  }
}
