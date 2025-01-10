import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class EmergencyScreen extends StatelessWidget {
  void _sendSOS() async {
    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData currentLocation = await location.getLocation();

      // Define your emergency contacts
      List<Map<String, dynamic>> emergencyContacts = [
        {
          'name': 'Police',
          'phone': '999',
        },
        {
          'name': 'Hospital',
          'phone': '999',
        },
      ];

      // Send the SOS alert
      FirebaseFirestore.instance.collection('emergency_alerts').add({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'timestamp': DateTime.now(),
        'contacts': emergencyContacts,
      });

      print('SOS sent successfully!');
    } catch (e) {
      print('Error sending SOS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendSOS,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Send Emergency SOS',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
