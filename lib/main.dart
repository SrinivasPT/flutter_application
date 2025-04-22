import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(FacialParalysisApp());
}

class FacialParalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Facial Paralysis Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Facial Paralysis Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildOptionCard(
              context,
              'Scan',
              'Scan face for facial paralysis detection',
              Icons.camera_alt,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanScreen()),
              ),
            ),
            SizedBox(height: 20),
            _buildOptionCard(
              context,
              'Alerts',
              'View real-time facial paralysis alerts',
              Icons.notifications,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlertScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
