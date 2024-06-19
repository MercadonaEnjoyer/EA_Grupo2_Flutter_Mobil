// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/edit_activity.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/new_activity.dart'; // Importa la nueva pantalla
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:http/http.dart' as http;

late ActivityService activityService;

class MyActivities extends StatefulWidget {
  const MyActivities({Key? key}) : super(key: key);

  @override
  _MyActivities createState() => _MyActivities();
}

class _MyActivities extends State<MyActivities> {
  late List<Activity> lista_activities;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    getData();
  }

  void getData() async {
    List<Activity> fetchedActivities = [];
    List<Activity> pendingActivities = [];
    List<Activity> pastActivities = [];

    try {
      fetchedActivities = await activityService.getUserActivities();

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
        lista_activities = [...pendingActivities, ...pastActivities];

        isLoading = false;
      });
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se han podido obtener los datos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print('Error al comunicarse con el backend: $error');
      }
    }
  }

  Future<String?> getAddressFromCoordinates(
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
          title: Text(
            'My activities',
            style: TextStyle(
              color: Pallete.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Pallete.textColor,
              ),
              onPressed: () {
                Get.to(() => HomePage(initialIndex: 3));
              },
            ),
          ),
        ),
        body: lista_activities.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You have not created any activities yet',
                    style: TextStyle(
                      color: Pallete.textColor.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  bool isPast =
                      lista_activities[index].date.isBefore(DateTime.now());
                  return Card(
                    color: isPast
                        ? Pallete.primaryColor.withOpacity(0.1)
                        : Pallete.primaryColor,
                    child: InkWell(
                      onTap: () {
                        print(lista_activities[index]);
                        Get.to(() => EditActivity(lista_activities[index],
                            onUpdate: getData));
                      },
                      child: ActivityCard(
                          getAddressFromCoordinates, lista_activities[index]),
                    ),
                  );
                },
                itemCount: lista_activities.length,
              ),
        floatingActionButton: Tooltip(
          message: 'Add new activity',
          child: FloatingActionButton(
            backgroundColor: Pallete.textColor,
            child: Icon(
              Icons.add,
              color: Pallete.accentColor,
            ),
            onPressed: () {
              Get.to(() => NewActivityScreen(onUpdate: getData));
            },
          ),
        ),
      );
    }
  }
}
