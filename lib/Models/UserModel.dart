import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/CommentModel.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String phone_number;
  final String gender;
  final String? birthday;
  final List<Activity>? activities;
  final List<Activity>? listActivities;
  final List<Comment>? comments;
  final bool? active;
  final String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone_number,
    required this.gender,
    this.active,
    required this.password,
    this.birthday,
    this.activities,
    this.listActivities,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phone_number,
      'gender': gender,
      'active': active,
      'password': password,
      'birthday': birthday,
    };
  }


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone_number: json['phone_number'],
      gender: json['gender'],
      active: json['active'],
      password: json['password'],
      birthday: json['birthday'],
      activities: (json['activities'] as List<dynamic>)
          .map((activityJson) => Activity.fromJson(activityJson))
          .toList(),
      listActivities: (json['listActivities'] as List<dynamic>)
          .map((activityJson) => Activity.fromJson(activityJson))
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
    );
  }
}
