class Activity {
  final String? id;
  final String name;
  final String description;
  final double? rate;
  final String idUser;
  final String date;
  final List<String>? listUsers;
  final List<String>? comments;
    

  Activity({
    this.id,
    required this.name,
    required this.description,
    this.rate,
    required this.idUser,
    required this.date,
    this.listUsers,
    this.comments,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      rate: json['rate'],
      idUser: json['owner']['name'],
      date: json['date'],
      listUsers: (json['listUsers'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
