

class User {
  final String? id;
  final String name;
  final String email;
  final String phone_number;
  final String gender;
  final String? birthday;
  final List<String>? activities;
  final List<String>? listActivities;
  final List<String>? comments;
  final bool? active;
  String? image;
  final String password;
  final LatLng? location;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone_number,
    required this.gender,
    this.active,
    this.image,
    required this.password,
    this.birthday,
    this.activities,
    this.listActivities,
    this.comments,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phone_number,
      'gender': gender,
      'active': active,
      'image': image,
      'password': password,
      'birthday': birthday,
      'location': location != null
          ? {
              'coordinates': [location!.longitude, location!.latitude],
              'type': 'Point',
            }
          : null,
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
      image: json['image'],
      password: json['password'],
      birthday: json['birthday'],
      activities: (json['Activities'] as List<dynamic>?)?.cast<String>(),
      listActivities: (json['listActivities'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
      location: json['location'] != null && json['location']['coordinates'] != null
          ? LatLng.fromCoordinates(json['location']['coordinates'])
          : null,
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

    factory LatLng.fromCoordinates(List<dynamic> coordinates) {
    return LatLng(
      latitude: coordinates[1],
      longitude: coordinates[0],
    );
  }
}
