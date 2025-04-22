import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'alert_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section with app logo and title
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.face_retouching_natural,
                            size: 36,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FacialParalysis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Facial Symmetry Detection',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Early detection of facial paralysis can lead to better treatment outcomes',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Information about facial paralysis
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Facial Paralysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Facial paralysis affects the ability to move muscles on one or both sides of the face. '
                      'It can be caused by Bell\'s palsy, stroke, trauma, or other conditions. '
                      'This app helps monitor facial symmetry and track changes over time.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // Navigation options - Use a fixed height container with GridView
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = (constraints.maxWidth - 15) / 2;
                    double cardHeight =
                        cardWidth * 0.9; // Aspect ratio adjustment

                    return Container(
                      height:
                          cardHeight * 2 + 15, // Two rows of cards plus spacing
                      child: GridView.count(
                        physics:
                            NeverScrollableScrollPhysics(), // Disable GridView scrolling
                        crossAxisCount: 2,
                        childAspectRatio: cardWidth / cardHeight,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        shrinkWrap: true,
                        children: [
                          _buildFeatureCard(
                            context,
                            'New Scan',
                            Icons.camera_alt,
                            Colors.green.shade100,
                            Colors.green,
                            'Analyze your facial symmetry',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanScreen(),
                              ),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Scan History',
                            Icons.history,
                            Colors.orange.shade100,
                            Colors.orange,
                            'View previous scan results',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanHistoryScreen(),
                              ),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Alerts',
                            Icons.notifications_active,
                            Colors.red.shade100,
                            Colors.red,
                            'View important alerts',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlertScreen(),
                              ),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Information',
                            Icons.medical_information,
                            Colors.blue.shade100,
                            Colors.blue,
                            'Learn about facial paralysis',
                            () => _showInfoDialog(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Add some bottom padding for safety
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('About Facial Paralysis'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'What is Facial Paralysis?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Facial paralysis is the loss of facial movement due to nerve damage. It can affect one or both sides of the face.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Common Symptoms:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Drooping of one side of the face'),
                  Text('• Difficulty smiling or closing eye on affected side'),
                  Text('• Drooling and difficulty with eating'),
                  Text('• Changes in taste sensation'),
                  SizedBox(height: 16),
                  Text(
                    'This app is intended as a monitoring tool and not for medical diagnosis. Always consult a healthcare professional.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showAlertScreen(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Alerts'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAlert(
                    'Daily Facial Exercise Reminder',
                    'Don\'t forget to complete your facial exercises today',
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                  SizedBox(height: 12),
                  _buildAlert(
                    'Appointment Reminder',
                    'Follow-up appointment scheduled for next week',
                    Icons.event,
                    Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildAlert(
                    'Medication Reminder',
                    'Take your prescribed medication as directed',
                    Icons.medical_services,
                    Colors.green,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Widget _buildAlert(String title, String message, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
