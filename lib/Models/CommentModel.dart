class Comment {
  final String? id;
  final String title;
  final String content;
  final String user;
  final String activity;
  final double review;

  Comment({
    this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.activity,
    required this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'users': user,
      'activities': activity,
      'review': review,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      user: json['users'],
      activity: json['activities'],
      review: json['review'],
    );
  }
}
