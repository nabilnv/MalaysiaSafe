import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is imported
import 'package:awesome_notifications/awesome_notifications.dart';
import 'login_screen.dart';
import 'osm_map_screen.dart';
import 'alerts_screen.dart'; // Import the Alerts screen
import 'community_report_screen.dart'; // Import the Community Report screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Logout function
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to Login screen
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSafetyAlerts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('disaster_alerts').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching safety alerts: $e');
      return [];
    }
  }

  void _sendSOSAlert() async {
    try {
      await _firestore.collection('sos_alerts').add({
        'alertMessage': 'Emergency SOS Alert',
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': 3.139,
        'longitude': 101.6869,
        'status': 'Sent',
      });

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'basic_channel',
          title: 'SOS Alert Sent',
          body: 'Your emergency SOS has been successfully sent.',
        ),
      );

      _showConfirmationDialog();
    } catch (e) {
      print('Error sending SOS: $e');
      _showErrorDialog('Error: Unable to send SOS alert.');
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SOS Sent'),
        content: Text('Your emergency SOS has been successfully sent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
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
        title: Text('Home'),
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          // Logout button
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: _logout, // Trigger logout on press
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text(
                  'Welcome to MalaysiaSafe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OSMMapScreen()),
                    );
                  },
                  child: Text('View Map'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _sendSOSAlert();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Emergency SOS'),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AlertsScreen()),
                    );
                  },
                  child: Text('View Alerts'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommunityReportScreen()),
                    );
                  },
                  child: Text('Community Reports'),
                ),
                SizedBox(height: 30),
                Text(
                  'Safety Alerts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchSafetyAlerts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching alerts.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No safety alerts available.'));
                    } else {
                      return Column(
                        children: snapshot.data!.map((alert) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(alert['alertMessage'] ?? 'Unknown Alert'),
                              subtitle: Text(
                                'Location: (${alert['latitude']}, ${alert['longitude']})\nRadius: ${alert['radius']} km',
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
