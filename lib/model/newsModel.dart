class News {
  final int id;
  final String title;
  final String shortText;
  final String text;
  final DateTime publishDate;

  News({
    required this.id,
    required this.title,
    required this.shortText,
    required this.text,
    required this.publishDate,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    // Парсинг Id
    final dynamic rawId = json['Id'];
    int parsedId;
    if (rawId == null) {
      parsedId = 0;
    } else if (rawId is int) {
      parsedId = rawId;
    } else {
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }

    // Парсинг даты публикации
    final publishDateStr = json['PublishDate'] ?? '';
    final parsedDate = DateTime.tryParse(publishDateStr) ?? DateTime.now();

    return News(
      id: parsedId,
      title: json['Title'] ?? '',
      shortText: json['ShortText'] ?? '',
      text: json['Text'] ?? '',
      publishDate: parsedDate,
    );
  }
}
