class Token {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  Token({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
    );
  }
}

class UserPhoto {
  final String urlSmall;
  final String urlMedium;
  final String urlSource;

  UserPhoto({
    required this.urlSmall,
    required this.urlMedium,
    required this.urlSource,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      urlSmall: json['UrlSmall'] as String,
      urlMedium: json['UrlMedium'] as String,
      urlSource: json['UrlSource'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UrlSmall': urlSmall,
      'UrlMedium': urlMedium,
      'UrlSource': urlSource,
    };
  }
}

class User {
  final String? email;
  final bool? emailConfirmed;
  final String? englishFio;
  final String? teacherCod;
  final String? studentCod;
  final String? birthDate;
  final String? academicDegree;
  final String? academicRank;
  final List<dynamic>? roles;
  final String? id;
  final String? userName;
  final String fio;
  final UserPhoto? photo;

  User({
    this.email,
    this.emailConfirmed,
    this.englishFio,
    this.teacherCod,
    this.studentCod,
    this.birthDate,
    this.academicDegree,
    this.academicRank,
    this.roles,
    this.id,
    this.userName,
    required this.fio,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['Email'] as String?,
      emailConfirmed: json['EmailConfirmed'] as bool?,
      englishFio: json['EnglishFIO'] as String?,
      teacherCod: json['TeacherCod'] as String?,
      studentCod: json['StudentCod'] as String?,
      birthDate: json['BirthDate'] as String?,
      academicDegree: json['AcademicDegree'] as String?,
      academicRank: json['AcademicRank'] as String?,
      roles: json['Roles'] as List<dynamic>? ?? [],
      id: json['Id'] as String?,
      userName: json['UserName'] as String?,
      fio: json['FIO'] as String,
      photo: json['Photo'] != null
          ? UserPhoto.fromJson(json['Photo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'EmailConfirmed': emailConfirmed,
      'EnglishFIO': englishFio,
      'TeacherCod': teacherCod,
      'StudentCod': studentCod,
      'BirthDate': birthDate,
      'AcademicDegree': academicDegree,
      'AcademicRank': academicRank,
      'Roles': roles,
      'Id': id,
      'UserName': userName,
      'FIO': fio,
      'Photo': photo?.toJson(),
    };
  }
}
