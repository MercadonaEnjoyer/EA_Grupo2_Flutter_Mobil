import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/new_activity.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:http/http.dart' as http;
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({Key? key}) : super(key: key);

  @override
  _ActivityListPageState createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  late List<Activity> listaActivities;
  late List<Activity> sortedActivities;
  bool isLoading = true;
  bool hasMore = true; 
  Position? position;
  int currentPage = 1; 
  double selectedDistance = 5.0; // Distancia inicial seleccionada
  String selectedSort = "Date";
  final ScrollController _scrollController = ScrollController();
  final Distance distance = Distance();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    if(box.read('distance') == null){
      box.write('distance', selectedDistance);
    }else{
      selectedDistance = box.read('distance');
    }
    activityService = ActivityService();
    listaActivities = [];
    sortedActivities = [];
    getData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && hasMore) {
        currentPage++;
        getData(page: currentPage);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getData({int page = 1, int limit = 10}) async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Activity> activities = await activityService.getData(selectedDistance * 1000, page, limit, selectedSort); // Filtrar por distancia
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        listaActivities.addAll(activities);
        isLoading = false;
        hasMore = activities.length == limit; 
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

  void _onDistanceChanged(double? newDistance) {
    if (newDistance != null) {
      setState(() {
        selectedDistance = newDistance;
        box.write('distance', selectedDistance);
        listaActivities = [];
        sortedActivities = [];
        getData();
      });
    }
  }

  void _onSortChanged(String? newSort) {
    if (newSort != null) {
      setState(() {
        selectedSort = newSort;
        listaActivities = [];
        sortedActivities = [];
        getData();
      });
    }
  }

  Future<String?> _getAddressFromCoordinates(double latitude, double longitude) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';
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
    if (isLoading && listaActivities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color:Pallete.textColor, 
            ),
            onPressed: () {
              Get.to(HomePage()); 
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your feed',
                style: TextStyle(
                  color: Pallete.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Pallete.textColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          value: selectedDistance,
                          onChanged: _onDistanceChanged,
                          dropdownColor: Pallete.textColor,
                          style: TextStyle(color: Pallete.backgroundColor),
                          items: <double>[5.0, 10.0, 20.0, 50.0, 100.0]
                              .map((double value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text('Hasta $value km', style: TextStyle(color: Pallete.backgroundColor)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    // Add your second Container and DropdownButton here
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Pallete.textColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSort, // Customize as needed
                          onChanged: _onSortChanged, // Implement your onChanged function
                          dropdownColor: Pallete.textColor,
                          style: TextStyle(color: Pallete.backgroundColor),
                          items: <String>['Date', 'Rate', 'Proximity']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text('Sort: $value', style: TextStyle(color: Pallete.backgroundColor)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],)
              )
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Asignar el ScrollController
                itemBuilder: (BuildContext context, int index) {
                  if (index == listaActivities.length) {
                    return isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(); // Mostrar un indicador de carga al final de la lista
                  }
                  return Card(
                    color: Pallete.primaryColor,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          '/activity/${listaActivities[index].id}',
                          arguments: {'onUpdate': getData},
                        );
                        listaActivities=[];
                        sortedActivities=[];
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           ActivityCard(_getAddressFromCoordinates,listaActivities[index])
                        ],
                      ),
                    ),
                  );
                },
                itemCount: listaActivities.length + (hasMore ? 1 : 0), // Incrementar el count si hay más datos
              ),
            ),
          ],
        ),
        floatingActionButton: Tooltip(
          message: 'Add new activity',
          child: FloatingActionButton(
            backgroundColor: Pallete.textColor,
            child: Icon(Icons.add, color: Pallete.backgroundColor),
            onPressed: () {
              listaActivities.clear();
              sortedActivities.clear();
              Get.to(() => NewActivityScreen(onUpdate: getData));
            },
          ),
        ),
      );
    }
  }
}
