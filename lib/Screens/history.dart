import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:http/http.dart' as http;
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;

class HistoryPage extends StatefulWidget {
  final User user;
  const HistoryPage(this.user, {Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  late List<Activity> listaActivities;
  late List<String> activities_id;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    activities_id = widget.user.listActivities!;
    getData();
  }

  void getData() async {
    listaActivities = [];
    List<Activity> fetchedActivities = [];
    List<Activity> pendingActivities = [];
    List<Activity> pastActivities = [];

    for (var act in activities_id) {
      Activity activity = await activityService.getActivity(act);
      fetchedActivities.add(activity);
    }

    DateTime now = DateTime.now();
    for (var activity in fetchedActivities) {
      if (activity.date.isAfter(now)) {
        pendingActivities.add(activity);
      } else {
        pastActivities.add(activity);
      }
    }

    pendingActivities.sort((a, b) => a.date.compareTo(b.date));
    pastActivities.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      listaActivities = [...pendingActivities, ...pastActivities];
      isLoading = false;
    });
  }

  Future<String?> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final address = data['address'];
        if (address != null) {
          final road = address['road'] ?? '';
          final houseNumber = address['house_number'] ?? '';
          final postcode = address['postcode'] ?? '';
          final city =
              address['city'] ?? address['town'] ?? address['village'] ?? '';
          final country = address['country'] ?? '';

          List<String> parts = [];

          if (road.isNotEmpty) parts.add(road);
          if (houseNumber.isNotEmpty) parts.add(houseNumber);
          if (postcode.isNotEmpty) parts.add(postcode);
          if (city.isNotEmpty) parts.add(city);
          if (country.isNotEmpty) parts.add(country);

          String formattedAddress = parts.join(', ');
          return formattedAddress;
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener la dirección desde las coordenadas: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.backgroundColor,
          iconTheme: IconThemeData(color: Pallete.textColor),
          title: Text(
            'Activities history',
            style: TextStyle(color: Pallete.textColor),
          ),
        ),
        body: listaActivities.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You have not participated or signed up for any activities yet',
                  style: TextStyle(
                    color: Pallete.textColor.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              child:ListView.builder(
                  shrinkWrap: true,
                  itemCount: listaActivities.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isPast =
                        listaActivities[index].date.isBefore(DateTime.now());
                    Color cardColor = isPast
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Pallete.primaryColor;
                    return Card(
                      color: cardColor,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(
                            '/activity/${listaActivities[index].id}',
                            arguments: {'onUpdate': getData},
                          );
                          listaActivities = [];
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ActivityCard(_getAddressFromCoordinates,
                                listaActivities[index])
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
    }
  }
}
