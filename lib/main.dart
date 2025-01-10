import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'HomeScreen.dart';
import 'osm_map_screen.dart';
import 'EmergencyScreen.dart'; // Import Emergency Screen
import 'auth_wrapper.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'community_report_screen.dart';  // Import CommunityReportScreen
import 'alerts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'This channel is used for simple notifications.',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MalaysiaSafe',
      home: AuthWrapper(),  // AuthWrapper handles user authentication flow
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/emergency': (context) => EmergencyScreen(),
        '/communityReport': (context) => CommunityReportScreen(),  // Add route for Community Report
      },
    );
  }
}
