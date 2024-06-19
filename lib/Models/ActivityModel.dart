
class Activity {
  final String? id;
  final String name;
  final String description;
  final double? rate;
  final String idUser;
  final DateTime date; // Cambiado el tipo de dato a DateTime
  final List<String>? listUsers;
  final List<String>? comments;
  final String? imageUrl;
  final LatLng? location;

  Activity({
    this.id,
    required this.name,
    required this.description,
    this.rate,
    required this.idUser,
    required this.date,
    this.listUsers,
    this.comments,
    this.imageUrl,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'rate': rate ?? 0,
      'owner': idUser,
      'date': date.toIso8601String(),
      'listUsers': listUsers ?? [],
      'comments': comments ?? [],
      'image': imageUrl,
      'active': true,
      'location': location != null
          ? {
              'coordinates': [location!.longitude, location!.latitude],
              'type': 'Point',
            }
          : null,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      rate: json['rate'],
      idUser: json['owner'],
      date: DateTime.parse(json['date']), // Parsear la fecha desde String a DateTime
      listUsers: (json['listUsers'] as List<dynamic>?)?.cast<String>(),
      comments: (json['comments'] as List<dynamic>?)?.cast<String>(),
      imageUrl: json['image'],
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

