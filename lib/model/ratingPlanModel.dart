enum OldRatingPlanSectionType { EXAM, DEFAULT, PROJECT }

OldRatingPlanSectionType parseOldRatingPlanSectionType(dynamic type) {
  if (type is int) {
    if (type == 0) return OldRatingPlanSectionType.EXAM;
    if (type == 1) return OldRatingPlanSectionType.DEFAULT;
    return OldRatingPlanSectionType.DEFAULT;
  } else if (type is String) {
    switch (type) {
      case "Экзамен":
        return OldRatingPlanSectionType.EXAM;
      case "Курсовая":
        return OldRatingPlanSectionType.PROJECT;
      default:
        return OldRatingPlanSectionType.DEFAULT;
    }
  }
  return OldRatingPlanSectionType.DEFAULT;
}

class RatingMark {
  final int id;
  final double ball;
  final String creatorId;
  final String createDate;
  RatingMark({
    required this.id,
    required this.ball,
    required this.creatorId,
    required this.createDate,
  });

  factory RatingMark.fromJson(Map<String, dynamic> json) {
    return RatingMark(
      id: json['Id'],
      ball: (json['Ball'] as num?)?.toDouble() ?? 0.0,
      creatorId: json['CreatorId'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

class MarkZeroSession {
  final int id;
  final double ball;
  final String creatorId;
  final String createDate;
  MarkZeroSession({
    required this.id,
    required this.ball,
    required this.creatorId,
    required this.createDate,
  });

  factory MarkZeroSession.fromJson(Map<String, dynamic> json) {
    return MarkZeroSession(
      id: json['Id'],
      ball: (json['Ball'] as num?)?.toDouble() ?? 0.0,
      creatorId: json['CreatorId'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

class ControlDots {
  final RatingMark mark;
  final int id;
  final int order;
  final String title;
  final String date;
  final double maxBall;
  final bool isReport;
  final bool isCredit;
  final String creatorId;
  final String createDate;
  ControlDots({
    required this.mark,
    required this.id,
    required this.order,
    required this.title,
    required this.date,
    required this.maxBall,
    required this.isReport,
    required this.isCredit,
    required this.creatorId,
    required this.createDate,
  });

  factory ControlDots.fromJson(Map<String, dynamic> json) {
    return ControlDots(
      mark: json['Mark'] != null
          ? RatingMark.fromJson(json['Mark'])
          : RatingMark(id: 0, ball: 0.0, creatorId: '', createDate: ''),
      id: json['Id'],
      order: json['Order'],
      title: json['Title'] ?? '',
      date: json['Date'] ?? '',
      maxBall: (json['MaxBall'] as num?)?.toDouble() ?? 0.0,
      isReport: json['IsReport'] ?? false,
      isCredit: json['IsCredit'] ?? false,
      creatorId: json['CreatorId'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

class Section {
  final List<ControlDots> controlDots;
  final OldRatingPlanSectionType sectionType;
  final int id;
  final int order;
  final String title;
  final String description;
  final String creatorId;
  final String createDate;
  Section({
    required this.controlDots,
    required this.sectionType,
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.createDate,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['ControlDots'] as List? ?? [];
    return Section(
      controlDots: list
          .map((e) => ControlDots.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectionType: parseOldRatingPlanSectionType(json['SectionType']),
      id: json['Id'],
      order: json['Order'],
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      creatorId: json['CreatorId'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

class StudentRatingPlan {
  final MarkZeroSession? markZeroSession;
  final List<Section> sections;
  StudentRatingPlan({
    required this.markZeroSession,
    required this.sections,
  });

  factory StudentRatingPlan.fromJson(Map<String, dynamic> json) {
    var sectionsJson = json['Sections'] as List? ?? [];
    return StudentRatingPlan(
      markZeroSession: json['MarkZeroSession'] != null
          ? MarkZeroSession.fromJson(json['MarkZeroSession'])
          : null,
      sections: sectionsJson
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
