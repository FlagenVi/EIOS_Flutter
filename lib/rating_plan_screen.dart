import 'package:flutter/material.dart';

import 'api_service.dart';
import 'models/rating_plan_models.dart';

class RatingPlanScreen extends StatefulWidget {
  final int disciplineId;
  final String disciplineTitle;
  final String tokenType;
  final String accessToken;

  const RatingPlanScreen({
    Key? key,
    required this.disciplineId,
    required this.disciplineTitle,
    required this.tokenType,
    required this.accessToken,
  }) : super(key: key);

  @override
  _RatingPlanScreenState createState() => _RatingPlanScreenState();
}

class _RatingPlanScreenState extends State<RatingPlanScreen> {
  bool _loading = true;
  String? _errorMessage;
  StudentRatingPlan? _ratingPlan;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRatingPlan();
  }

  Future<void> _fetchRatingPlan() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      StudentRatingPlan plan = (await _apiService.getRatingPlan(
        widget.tokenType,
        widget.accessToken,
        widget.disciplineId,
      ));
      setState(() {
        _ratingPlan = plan;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  List<double> _calculateScores() {
    double myScore = 0.0;
    double maxScore = 0.0;

    if (_ratingPlan != null) {
      for (var section in _ratingPlan!.sections) {
        for (var cd in section.controlDots) {
          myScore += cd.mark.ball;
          maxScore += cd.maxBall;
        }
      }
    }

    return [myScore, maxScore];
  }
  @override
  Widget build(BuildContext context) {
    final scores = _calculateScores();
    final myScore = scores[0];
    final maxScore = scores[1];

    return Scaffold(
      appBar: AppBar(
        title: Text("Рейтинг план: ${widget.disciplineTitle}"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Ошибка: $_errorMessage"))
          : _ratingPlan == null
          ? const Center(child: Text("Нет данных"))
          : Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.disciplineTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._ratingPlan!.sections.map((section) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...section.controlDots.map((cd) {
                        final dateText = (cd.date.length >= 10)
                            ? cd.date.substring(0, 10)
                            : 'Нет даты';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(cd.title),
                          subtitle: Text("Срок сдачи: $dateText"),
                          trailing: Text(
                            "${cd.mark.ball}/${cd.maxBall}",
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),


      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: Text(
          "Мой балл: ${myScore.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

