import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ltld;
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewActivityScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  const NewActivityScreen({required this.onUpdate});

  @override
  _NewActivityScreenState createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final TextEditingController _dateController = TextEditingController();

  String? _image;
  Uint8List? _imageBytes;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _userId = '';
  double _latitude = 41.27552212202214;
  double _longitude = 1.9863014220734023;
  bool _locationLoaded = false;
  bool _isMapVisible = false;
  late TileLayer _tileLayer;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _selectLocation();
    _setupMapTheme();
    _dateController.text =
        DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
  }

  Future<void> _fetchUserId() async {
    final String? userId = await UserService().getId();
    setState(() {
      _userId = userId!;
    });
  }

  void _setupMapTheme() async {
    final box = GetStorage();
    String? theme = box.read('theme');

    setState(() {
      if (theme == 'Dark') {
        _tileLayer = TileLayer(
          urlTemplate:
              'https://tiles-eu.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
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

  void _showImageSourceActionSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              if (_image != null)
                ListTile(
                  leading: const Icon(Icons.remove_circle),
                  title: const Text('Remove image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _image = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final Uint8List bytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = 'data:image/png;base64,' + base64Encode(bytes);
      });
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) {
      print('No hay imagen para subir.');
      return null;
    }

    final Uri url =
        Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
    final String filename =
        'upload_${DateTime.now().millisecondsSinceEpoch}.png';
    final http.MultipartRequest request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'typvcah6'
      ..files.add(http.MultipartFile.fromBytes('file', _imageBytes!,
          filename: filename));

    try {
      final http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final http.Response responseData =
            await http.Response.fromStream(response);
        final Map<String, dynamic> jsonData = jsonDecode(responseData.body);
        final String imageUrl = jsonData['secure_url'];

        return imageUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (pickedDateTime.isBefore(DateTime.now())) {
          Get.snackbar(
            'Error',
            'The selected date and time cannot be earlier than the current date and time.',
            snackPosition: SnackPosition.BOTTOM,
            titleText: const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            messageText: Text(
              'The selected date and time cannot be earlier than the current date and time. Please select a valid date and time.',
              style: TextStyle(color: Pallete.textColor),
            ),
          );
          setState(() {
            _selectedDate = DateTime.now();
            _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
            _dateController.text =
                DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
          });
        } else {
          setState(() {
            _selectedDate = pickedDateTime;
            _selectedTime = pickedTime;
            _dateController.text =
                DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
          });
        }
      }
    }
  }

  Future<void> _selectLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoaded = true;
        _mapController.move(ltld.LatLng(_latitude, _longitude), 12);
      });
    } catch (e) {
      print('No se pudo obtener la ubicación actual.');
      setState(() {
        _locationLoaded = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_locationController.text.isEmpty) {
      getCoordinatesFromAddress(_locationController.text);
    }
    if (_formKey.currentState!.validate()) {
      final Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: await _uploadImage(),
        date: DateTime.parse(_selectedDate.toIso8601String()),
        idUser: _userId,
        location: LatLng(latitude: _latitude, longitude: _longitude),
      );
      await ActivityService().addActivity(newActivity).then((value) {
        Get.snackbar(
          'Successful',
          'Activity created!',
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            'Successful',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          messageText: Text(
            'Activity created!',
            style: TextStyle(color: Pallete.textColor),
          ),
        );
      }).catchError((error) {
        print("Error: $error"); // Manejo de errores si la promesa falla
      });
      widget.onUpdate();
      Get.to(() => HomePage(initialIndex: 1));
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<List<double>?> getCoordinatesFromAddress(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json';

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final Map<String, dynamic> firstResult = data.first;
          final double lat = double.parse(firstResult['lat']);
          final double lon = double.parse(firstResult['lon']);
          setState(() {
            _latitude = lat;
            _longitude = lon;
            _mapController.move(ltld.LatLng(_latitude, _longitude), 12);
          });
          return [lat, lon];
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener las coordenadas desde la dirección: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final String url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> address = data['address'];
        final String road = address['road'] ?? '';
        final String houseNumber = address['house_number'] ?? '';
        final String postcode = address['postcode'] ?? '';
        final String city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final String country = address['country'] ?? '';

        final List<String> parts = [];

        if (road.isNotEmpty) parts.add(road);
        if (houseNumber.isNotEmpty) parts.add(houseNumber);
        if (postcode.isNotEmpty) parts.add(postcode);
        if (city.isNotEmpty) parts.add(city);
        if (country.isNotEmpty) parts.add(country);

        final String formattedAddress = parts.join(', ');
        setState(() {
          _locationController.text = formattedAddress;
        });
        return formattedAddress;
      }
      return null;
    } catch (e) {
      print('Error al obtener la dirección desde las coordenadas: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New activity',
          style: TextStyle(
            color: Pallete.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Pallete.backgroundColor.withOpacity(0.7),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Pallete.textColor,
          ),
          onPressed: () {
            widget.onUpdate();
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    _showImageSourceActionSheet(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Pallete.primaryColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Pallete.textColor),
                        ),
                        child: _image == null
                            ? Center(
                                child: Text(
                                  'Tap to select an image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Pallete.textColor),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(_image!.split(',').last),
                                  height: 100,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    labelStyle: TextStyle(
                      color: Pallete.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    fillColor: Pallete.primaryColor.withOpacity(0.7),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.salmonColor),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Pallete.salmonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(color: Pallete.textColor),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the activity name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Pallete.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    fillColor: Pallete.primaryColor.withOpacity(0.7),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.salmonColor),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Pallete.salmonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(color: Pallete.textColor),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(
                            color: Pallete.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          fillColor: Pallete.primaryColor.withOpacity(0.7),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Pallete.textColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Pallete.textColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Pallete.salmonColor),
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Pallete.salmonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextStyle(color: Pallete.textColor),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isMapVisible ? Icons.close : Icons.map,
                        color: Pallete.textColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMapVisible = !_isMapVisible;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: TextStyle(
                      color: Pallete.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    fillColor: Pallete.primaryColor.withOpacity(0.7),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.textColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Pallete.salmonColor),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Pallete.salmonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextStyle(color: Pallete.textColor),
                  onTap: () => _selectDateTime(context),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Visibility(
                  visible: _isMapVisible,
                  child: _locationLoaded
                      ? Container(
                          height: 300,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter:
                                      ltld.LatLng(_latitude, _longitude),
                                  initialZoom: 12,
                                  interactionOptions: const InteractionOptions(
                                      flags: ~InteractiveFlag.doubleTapZoom),
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      _latitude = point.latitude;
                                      _longitude = point.longitude;
                                      _locationController.text =
                                          '$_latitude,$_longitude';
                                    });
                                    getAddressFromCoordinates(
                                        _latitude, _longitude);
                                  },
                                ),
                                children: [
                                  _tileLayer,
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point:
                                            ltld.LatLng(_latitude, _longitude),
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 50.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 20,
                                left: 20,
                                right: 20,
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Pallete.backgroundColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _searchController,
                                          decoration: const InputDecoration(
                                            hintText: 'Search...',
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                              color: Pallete.textColor),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.search,
                                          color: Pallete.textColor,
                                        ),
                                        onPressed: () {
                                          getCoordinatesFromAddress(
                                              _searchController.text);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: SignUpButton(
                      onPressed: _submitForm,
                      text: 'Post activity',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
