import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ltld;
import 'package:http/http.dart' as http;

import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/my_activities.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';

class EditActivity extends StatefulWidget {
  final VoidCallback onUpdate;
  final Activity activity;

  const EditActivity(this.activity, {required this.onUpdate});

  @override
  _EditActivityState createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final MapController _mapController = MapController();
  ActivityService activityService = ActivityService();

  String? _image;
  Uint8List? _imageBytes;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _userId = '';
  double _latitude = 0;
  double _longitude = 0;
  bool _locationLoaded = false;
  bool _isEditing = false;
  bool _isMapVisible = false;
  late TileLayer _tileLayer;

  @override
  void initState() {
    super.initState();

    _fetchUserId();
    activityService = ActivityService();
    _setupMapTheme();
    if (widget.activity.imageUrl != null) {
      _loadImage();
    }

    _setInitialValues();
  }

  Future<void> _setInitialValues() async {
    await  _selectLocation();
    _nameController.text = widget.activity.name;
    _descriptionController.text = widget.activity.description;
    _selectedDate = widget.activity.date.toLocal();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _dateController.text = DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
  }

  Future<void> _fetchUserId() async {
    final userId = await UserService().getId();
    setState(() {
      _userId = userId!;
    });
  }

  Future<void> _loadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.activity.imageUrl!));
      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        setState(() {
          _image = 'data:image/png;base64,' + base64Encode(bytes);
        });
      } else {
        print('Failed to load image');
      }
    } catch (e) {
      print('Error: $e');
    }
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
          _dateController.text = DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
        });
      } else {
        setState(() {
          _selectedDate = pickedDateTime;
          _selectedTime = pickedTime;
          _dateController.text = DateFormat('dd/MM/yyyy hh:mm a').format(_selectedDate);
        });
      }
    }
  }
}

  Future<void> _selectLocation() async {
    try {
      _latitude = widget.activity.location!.latitude;
      _longitude = widget.activity.location!.longitude;
      setState(() async {
        _locationController.text =(await getAddressFromCoordinates(_latitude, _longitude))!;
      });
    } catch (e) {
      setState(() {
        _locationLoaded = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: await _uploadImage(),
        date: DateTime.parse(_selectedDate.toIso8601String()),
        idUser: _userId,
        location: LatLng(latitude: _latitude, longitude: _longitude),
      );

      await activityService
          .editActivity(newActivity, widget.activity.id)
          .then((statusCode) {
        Get.snackbar(
          'Successful',
          'Activity edited!',
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            'Successful',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          messageText: Text(
            'Activity edited!',
            style: TextStyle(color: Pallete.textColor),
          ),
        );
      });
      widget.onUpdate();
      print('Actividad editada correctamente.');
      Get.to(() => MyActivities());
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<List<double>?> getCoordinatesFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstResult = data.first;
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
          setState(() {
            _locationController.text = formattedAddress;
            _locationLoaded = true;
          });
          return formattedAddress;
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener la dirección desde las coordenadas: $e');
      return null;
    }
  }

  Future<void> _deleteActivity() async {
    await activityService.deleteActivity(widget.activity.id);
    widget.onUpdate();
    print('Actividad eliminada correctamente.');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Activity',
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
              Get.to(() => MyActivities());
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isEditing ? Icons.cancel : Icons.edit,
                color: Pallete.textColor,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  _setInitialValues();
                });
              },
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
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _image == null
                            ? Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Pallete.primaryColor.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Pallete.textColor),
                                ),
                                child: Center(
                                  child: Text(
                                    'Tap to select an image',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Pallete.textColor),
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(_image!.split(',').last),
                                  height: 100,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Activity Name',
                  readOnly:
                      !_isEditing, // Controlar solo lectura según el modo de edición
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the activity name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  maxLines: 5,
                  readOnly:
                      !_isEditing, // Controlar solo lectura según el modo de edición
                  validator: (value) {
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
                      child: _buildTextField(
                        controller: _locationController,
                        labelText: 'Location',
                        readOnly: !_isEditing,
                        validator: (value) {
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
                _buildTextField(
                  controller: _dateController,
                  labelText: 'Date',
                  readOnly: true,
                  onTap: () {
                    if (_isEditing) {
                      _selectDateTime(
                          context); // Permitir seleccionar la fecha solo en modo de edición
                    }
                  },
                  validator: (value) {
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
                                    if (_isEditing) {
                                      setState(() {
                                        _latitude = point.latitude;
                                        _longitude = point.longitude;
                                      });
                                      getAddressFromCoordinates(
                                          _latitude, _longitude);
                                    }
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
                                          if (_isEditing) {
                                            getCoordinatesFromAddress(
                                                _searchController.text);
                                          }
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
                if (_isEditing) // Mostrar botones solo en modo de edición
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Edit'),
                    ),
                  ),
                if (_isEditing) // Mostrar botones solo en modo de edición
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _deleteActivity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                      ),
                      child: Text('Delete'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    int maxLines = 1,
    required String? Function(String?)? validator,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Pallete.textColor,
            fontWeight: FontWeight.bold,
          ),
          fillColor: Pallete.primaryColor.withOpacity(0.7),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
        validator: validator,
        onTap: onTap,
      ),
    );
  }
}
