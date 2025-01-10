import 'dart:convert'; // Import jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'community_report_screen.dart'; // Import your community report screen

class OSMMapScreen extends StatefulWidget {
  @override
  _OSMMapScreenState createState() => _OSMMapScreenState();
}

class _OSMMapScreenState extends State<OSMMapScreen> {
  LatLng? _currentLocation;
  MapController _mapController = MapController();
  final _searchController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _getCurrentLocation();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 14.0);
    });
  }

  // Save disaster alerts to local storage
  Future<void> _saveHazardAlertsToLocal(List<Map<String, dynamic>> hazardAlerts) async {
    List<String> savedHazardAlerts = hazardAlerts.map((alert) {
      return jsonEncode(alert); // Convert each alert to a JSON string for storage
    }).toList();
    await _prefs.setStringList('hazardAlerts', savedHazardAlerts);
  }

  // Save evacuation routes to local storage
  Future<void> _saveEvacuationRoutesToLocal(List<Map<String, dynamic>> evacuationRoutes) async {
    List<String> savedRoutes = evacuationRoutes.map((route) {
      return jsonEncode(route); // Convert each route to a JSON string for storage
    }).toList();
    await _prefs.setStringList('evacuationRoutes', savedRoutes);
  }

  // Retrieve hazard alerts from local storage
  List<Map<String, dynamic>> _getHazardAlertsFromLocal() {
    List<String> savedHazardAlerts = _prefs.getStringList('hazardAlerts') ?? [];
    return savedHazardAlerts.map((alert) {
      return jsonDecode(alert) as Map<String, dynamic>; // Convert JSON string back to map
    }).toList();
  }

  // Retrieve evacuation routes from local storage
  List<Map<String, dynamic>> _getEvacuationRoutesFromLocal() {
    List<String> savedRoutes = _prefs.getStringList('evacuationRoutes') ?? [];
    return savedRoutes.map((route) {
      return jsonDecode(route) as Map<String, dynamic>; // Convert JSON string back to map
    }).toList();
  }

  // Fetch hazard alerts from Firestore
  Future<List<Map<String, dynamic>>> _fetchHazardAlerts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('disaster_alerts').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching hazard alerts: $e');
      return [];
    }
  }

  // Fetch evacuation routes from Firestore
  Future<List<Map<String, dynamic>>> _fetchEvacuationRoutes() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('evacuation_routes').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching evacuation routes: $e');
      return [];
    }
  }

  Future<List<List<Map<String, dynamic>>>> _fetchData() async {
    try {
      final hazardAlerts = await _fetchHazardAlerts();
      final evacuationRoutes = await _fetchEvacuationRoutes();

      // Save fetched data to local storage for offline usage
      await _saveHazardAlertsToLocal(hazardAlerts);
      await _saveEvacuationRoutesToLocal(evacuationRoutes);

      return [hazardAlerts, evacuationRoutes];
    } catch (e) {
      print('Error fetching data: $e');

      // Return cached data if offline
      return [
        _getHazardAlertsFromLocal(),
        _getEvacuationRoutesFromLocal()
      ];
    }
  }

  // Handle search location
  Future<void> _searchLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final result = locations.first;

        // Animate the map to the new location
        _mapController.move(LatLng(result.latitude, result.longitude), 14.0);
        setState(() {
          _currentLocation = LatLng(result.latitude, result.longitude);
        });
      } else {
        _showErrorMessage('Location not found.');
      }
    } catch (e) {
      _showErrorMessage('Error: Unable to find location.');
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive Map (OSM)'),
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () {
              Navigator.pushNamed(context, '/communityReport');  // Navigate to community report screen
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            List<Map<String, dynamic>> hazardAlerts = snapshot.data![0];
            List<Map<String, dynamic>> evacuationRoutes = snapshot.data![1];

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation ?? LatLng(3.139, 101.6869),
                zoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.malaysiasafe',
                ),
                // Displaying markers for hazard locations
                MarkerLayer(
                  markers: hazardAlerts.map((alert) {
                    double latitude = double.tryParse(alert['latitude'].toString()) ?? 0.0;
                    double longitude = double.tryParse(alert['longitude'].toString()) ?? 0.0;

                    return Marker(
                      point: LatLng(latitude, longitude),
                      builder: (ctx) => Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    );
                  }).toList(),
                ),
                // Displaying routes
                PolylineLayer(
                  polylines: evacuationRoutes.map((route) {
                    double startLatitude = double.tryParse(route['startLatitude'].toString()) ?? 0.0;
                    double startLongitude = double.tryParse(route['startLongitude'].toString()) ?? 0.0;
                    double endLatitude = double.tryParse(route['endLatitude'].toString()) ?? 0.0;
                    double endLongitude = double.tryParse(route['endLongitude'].toString()) ?? 0.0;
                    bool isEvacuationRoute = route['isEvacuationRoute'] ?? false;

                    return Polyline(
                      points: [
                        LatLng(startLatitude, startLongitude),
                        LatLng(endLatitude, endLongitude),
                      ],
                      strokeWidth: 4.0,
                      color: isEvacuationRoute ? Colors.blue : Colors.grey,
                    );
                  }).toList(),
                ),
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        builder: (ctx) => Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
