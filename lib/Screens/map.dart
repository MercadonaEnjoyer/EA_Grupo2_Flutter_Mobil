import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart' as ltlg;
import 'package:flutter/foundation.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Widgets/paramTextBox_sign_up.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/UserService.dart';

late UserService userService;
late ActivityService activityService;

class MapScreen extends StatefulWidget {
  final ltlg.LatLng defaultLocation;

  const MapScreen({Key? key, required this.defaultLocation}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  final MapController mapController = Get.put(MapController());
  late List<Activity> lista_activities;
  late List<Marker> _markers = [];
  bool isLoading = true;
  Position? position;
  late ltlg.LatLng initialLocation;
  late TileLayer _tileLayer;
  double distance = 10000; 
  int limit = 10;
  double selectedDistance = 5.0; // Distancia inicial seleccionada
  String selectedSort = "Date";
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    userService = UserService();
    if(box.read('distance') == null){
      box.write('distance', selectedDistance);
    }else{
      selectedDistance = box.read('distance');
    }
    getData(null);
    setupMapTheme();
  }

  void setupMapTheme() async {
    final box = GetStorage();
    String? theme = box.read('theme');
    
    setState(() {
      if (theme == 'Dark') {
        _tileLayer = TileLayer(
          urlTemplate: 'https://tiles-eu.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        );
      } else {
        _tileLayer = TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        );
      }
    });
  }

  void getData(byName) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Los servicios de ubicación están dehabilitados');
        useDefaultLocation();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Permiso de ubicación denegado');
          useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Los permisos de ubicación están permanentemente denegados.');
        useDefaultLocation();
        return;
      }

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await userService.updateLocation(position);

      initialLocation = ltlg.LatLng(position!.latitude, position!.longitude);

      List<Activity> activities;
      if (byName == null) {
        activities = await getAllActivities(selectedDistance * 1000, limit);
      } else {
        activities = await mapController.searchByName(selectedDistance * 1000, limit);
      }

      setState(() {
        // Clear existing markers
        _markers.clear();

        // Add current location marker
        _markers.add(
          Marker(
            point: initialLocation,
            width: 60,
            height: 60,
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.circle,
              size: 20,
              color: Pallete.salmonColor,
            ),
          ),
        );

        // Add activity markers
        for (var actividad in activities) {
          _markers.add(
            Marker(
              point: ltlg.LatLng(actividad.location!.latitude, actividad.location!.longitude),
              width: 60,
              height: 60,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(
                                '/activity/${actividad.id}',
                              );
                            },
                            child: Card(
                              color: Pallete.primaryColor,
                              surfaceTintColor: Pallete.accentColor,
                              elevation: 5,
                              margin: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  // Left side: Image
                                  Container(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(
                                      actividad.imageUrl ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjCoUtOal33JWLqals1Wq7p6GGCnr3o-lwpQ&s',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Right side: Title, Description, and Value
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            actividad.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Description: ${actividad.description}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: actividad.rate!,
                                                itemBuilder: (context, index) =>
                                                    const Icon(
                                                  Icons.star,
                                                  size: 18,
                                                  color: Colors.amber,
                                                ),
                                                itemCount: 5,
                                                itemSize: 18,
                                                direction: Axis.horizontal,
                                                unratedColor:
                                                    Colors.blueAccent.withAlpha(50),
                                              ),
                                              const SizedBox(width:8), 
                                              Text(
                                                actividad.rate!.toStringAsFixed(1), 
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.amber, 
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      );
                    },
                  );
                },
                child: Icon(Icons.location_pin,
                    size: 60, color: Pallete.salmonColor),
              ),
            ),
          );
        }

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

  void _onDistanceChanged(double? newDistance) {
    if (newDistance != null) {
      setState(() {
        selectedDistance = newDistance;
        box.write('distance', selectedDistance);
        getData(null);
      });
    }
  }

  Future<List<Activity>> getAllActivities(double distance, int limit) async {
    int page = 1;
    bool hasMore = true;
    List<Activity> allActivities = [];

    while (hasMore) {
      List<Activity> activities = await activityService.getData(distance, page, limit, "Date");
      allActivities.addAll(activities);

      hasMore = activities.length == limit;
      page++;
    }

    return allActivities;
  }

  void useDefaultLocation() {
    setState(() {
      initialLocation = widget.defaultLocation;
      _markers.add(
        Marker(
          point: initialLocation,
          width: 60,
          height: 60,
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.circle,
            size: 20,
            color: Pallete.salmonColor,
          ),
        ),
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom),
            ),
            children: [
              _tileLayer,
              MarkerLayer(markers: _markers),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ParamTextBox(
                          controller: mapController.searchBarController,
                          text: 'Scaperoom...',
                        ),
                        IconButton(
                          icon: Icon(
                              size: 40,
                              color: Pallete.textColor,
                              LineIcons.searchLocation),
                          onPressed: () {
                            getData("byName");
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    child: Container(
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
                          items: <double>[5.0, 10.0, 20.0, 50.0, 100.0].map((double value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text(
                                'Hasta $value km',
                                style: TextStyle(color: Pallete.backgroundColor),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}


class MapController extends GetxController {
  final TextEditingController searchBarController = TextEditingController();

  Future<List<Activity>> searchByName(double distance, int limit) async {
    int page = 1;
    bool hasMore = true;
    List<Activity> allActivities = [];

    while (hasMore) {
      List<Activity> activities = await activityService.getDataByName(distance, page, limit, searchBarController.text);
      allActivities.addAll(activities);

      hasMore = activities.length == limit;
      page++;
    }
    print(allActivities.length);

    return allActivities;
  }
}
