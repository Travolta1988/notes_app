class Note {
  final int id;
  final String title;
  final String content;
  final String date;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.tags,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: (json['tags'] as List).cast<String>(),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'date': date,
    };
  }
}