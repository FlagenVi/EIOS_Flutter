import 'dart:convert';
import 'package:eios_flut/models/student_semester_models.dart';
import 'package:eios_flut/models/user_models.dart';
import 'package:http/http.dart' as http;
import 'models/rating_plan_models.dart';
import 'models/timetable_models.dart';


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

  Future<List<StudentTimeTable>> getStudentTimeTable(String tokenType, String accessToken, String date) async {
    final timetableUrl = '$baseUserUrl/v1/StudentTimeTable?date=$date';
    final response = await http.get(
      Uri.parse(timetableUrl),
      headers: {
        'Authorization': '$tokenType $accessToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List;
      return jsonResponse.map((e) => StudentTimeTable.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка при получении расписания: ${response.body}');
    }
  }

  Future<StudentSemester> getStudentSemester(String tokenType, String accessToken) async {
    final semesterUrl = '$baseUserUrl/v1/StudentSemester?selector=current';
    print("Запрос к URL: $semesterUrl");
    try {
      final response = await http.get(
        Uri.parse(semesterUrl),
        headers: {
          'Authorization': '$tokenType $accessToken',
          'Accept': 'application/json',
        },
      );
      print("Статус ответа: ${response.statusCode}");
      print("Ответ: ${response.body}");

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
      print("Ошибка запроса: $e");
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
