import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/userModel.dart';
import '../model/newsModel.dart';
import '../model/ratingPlanModel.dart';
import '../model/studentSemesterModel.dart';
import '../model/timetableModel.dart';

class TimetableResponse {
  final List<StudentTimeTable> items;
  final List<dynamic> raw;

  TimetableResponse({
    required this.items,
    required this.raw,
  });
}

class ApiService {
  static const String baseUrl = 'https://p.mrsu.ru/';
  static const String baseUserUrl = 'https://papi.mrsu.ru/';
  static const String tokenUrl = baseUrl + 'OAuth/Token';
  static const String userUrl = baseUserUrl + 'v1/User';

  Future<Token> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': '8',
        'client_secret': 'qweasd',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Token.fromJson(jsonResponse);
    } else {
      throw Exception('Ошибка при авторизации: ${response.body}');
    }
  }

  Future<User> getUser(String tokenType, String accessToken) async {
    final response = await http.get(
      Uri.parse(userUrl),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('Полученный JSON: $jsonResponse');
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Ошибка при получении данных пользователя: ${response.body}');
    }
  }

  Future<List<News>> getNews(String tokenType, String accessToken) async {
    final newsUrl = '$baseUserUrl/v1/News';
    final response = await http.get(
      Uri.parse(newsUrl),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print("JSON новостей: $jsonResponse"); // Для отладки
      if (jsonResponse is List) {
        return jsonResponse.map((item) => News.fromJson(item)).toList();
      } else {
        throw Exception('Неверный формат данных новостей: $jsonResponse');
      }
    } else {
      throw Exception('Ошибка при получении новостей: ${response.body}');
    }
  }

  Future<TimetableResponse> getStudentTimeTable(String tokenType, String accessToken, String date) async {
    final timetableUrl = '$baseUserUrl/v1/StudentTimeTable?date=$date';
    final response = await http.get(
      Uri.parse(timetableUrl),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is! List) {
        throw Exception('Неверный формат расписания: ${response.body}');
      }
      final items = jsonResponse
          .whereType<Map<String, dynamic>>()
          .map((e) => StudentTimeTable.fromJson(e))
          .toList();
      return TimetableResponse(items: items, raw: jsonResponse);
    } else {
      throw Exception('Ошибка при получении расписания: ${response.body}');
    }
  }

  Future<StudentSemester> getStudentSemester(String tokenType, String accessToken) async {
    final semesterUrl = '$baseUserUrl/v1/StudentSemester?selector=current';
    try {
      final response = await http.get(
        Uri.parse(semesterUrl),
        headers: {
          'Authorization': '$tokenType $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Map<String, dynamic> data;
        if (jsonResponse is List) {
          if (jsonResponse.isNotEmpty) {
            data = jsonResponse[0] as Map<String, dynamic>;
          } else {
            throw Exception('Пустой список данных');
          }
        } else if (jsonResponse is Map<String, dynamic>) {
          data = jsonResponse;
        } else {
          throw Exception('Неверный формат ответа');
        }
        return StudentSemester.fromJson(data);
      } else {
        throw Exception('Ошибка получения семестра: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка запроса: $e');
    }
  }

  Future<StudentRatingPlan> getRatingPlan(String tokenType, String accessToken, int disciplineId) async {
    final ratingPlanUrl = '$baseUserUrl/v1/StudentRatingPlan?id=$disciplineId';
    final response = await http.get(
      Uri.parse(ratingPlanUrl),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return StudentRatingPlan.fromJson(jsonResponse);
    } else {
      throw Exception('Ошибка получения рейтингового плана: ${response.body}');
    }
  }
}
