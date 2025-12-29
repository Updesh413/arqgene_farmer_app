import 'package:arqgene_farmer_app/db/schemas.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../db/isar_service.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _locationAddress = "Location not set";
  String? _selectedFarmSize;
  List<String> _selectedCrops = [];
  bool _isLoading = false;
  // 1. Initialize Service
  final IsarService _isarService = IsarService();

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty ||
        _selectedFarmSize == null ||
        _selectedCrops.isEmpty) {
      // ... Error handling ...
      return;
    }

    // 2. Create Object
    final newProfile = FarmerProfile()
      ..name = _nameController.text
      ..location = _locationAddress
      ..farmSize = _selectedFarmSize!
      ..crops = _selectedCrops;

    // 3. Save to DB
    await _isarService.saveProfile(newProfile);

    // 4. Update SharedPrefs ONLY for the "First Run" check
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileCompleted', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // Pre-defined options (You can translate these keys too)
  final List<String> _farmSizes = ['size_small', 'size_medium', 'size_large'];
  final List<String> _cropOptions = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Tomato',
    'Onion',
  ];

  // 1. Logic to Auto-Detect Location
  Future<void> _detectLocation() async {
    setState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      // Get GPS Coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert Coords to Address (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        // e.g., "Vellore, Tamil Nadu"
        _locationAddress = "${place.locality}, ${place.administrativeArea}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationAddress = "Error detecting location";
        _isLoading = false;
      });
    }
  }

  // 2. Logic to Save Data Locally
  // Future<void> _saveProfile() async {
  //   if (_nameController.text.isEmpty ||
  //       _selectedFarmSize == null ||
  //       _selectedCrops.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("error_fill_fields".tr()),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('userName', _nameController.text);
  //   await prefs.setString('userLocation', _locationAddress);
  //   await prefs.setString('farmSize', _selectedFarmSize!);
  //   await prefs.setStringList('userCrops', _selectedCrops);
  //   await prefs.setBool('isProfileCompleted', true); // Critical Flag

  //   // Go to Home
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => HomeScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("profile_title").tr(), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME INPUT
            Text(
              "name_label".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),

            // LOCATION DETECTOR
            Text(
              "location_label".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _locationAddress,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _detectLocation,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.my_location),
                    label: Text("Detect"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // FARM SIZE (Radio Chips)
            Text(
              "farm_size_label".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: _farmSizes.map((sizeKey) {
                return ChoiceChip(
                  label: Text(sizeKey.tr()),
                  selected: _selectedFarmSize == sizeKey,
                  onSelected: (selected) {
                    setState(
                      () => _selectedFarmSize = selected ? sizeKey : null,
                    );
                  },
                  selectedColor: Colors.green[200],
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // CROPS (Multi-Select Chips)
            Text(
              "crops_label".tr(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _cropOptions.map((crop) {
                return FilterChip(
                  label: Text(
                    crop,
                  ), // You can add .tr() here if you add crops to JSON
                  selected: _selectedCrops.contains(crop),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedCrops.add(crop)
                          : _selectedCrops.remove(crop);
                    });
                  },
                  selectedColor: Colors.green[200],
                  checkmarkColor: Colors.green[900],
                );
              }).toList(),
            ),
            SizedBox(height: 40),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  "save_profile_btn".tr(),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
