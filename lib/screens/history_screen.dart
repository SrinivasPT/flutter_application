import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScanHistoryScreen extends StatefulWidget {
  @override
  _ScanHistoryScreenState createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _dummyHistory = [
    {
      'date': DateTime.now(),
      'severity': 'Mild',
      'details': 'Slight asymmetry detected on left side',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 1)),
      'severity': 'Moderate',
      'details': 'Noticeable asymmetry on left side, reduced movement',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 3)),
      'severity': 'Mild',
      'details': 'Minor asymmetry detected',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 7)),
      'severity': 'Normal',
      'details': 'No asymmetry detected',
    },
  ];

  List<Map<String, dynamic>> get filteredHistory {
    return _dummyHistory.where((scan) {
      return DateFormat('yyyy-MM-dd').format(scan['date']) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate);
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected Date:'),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                filteredHistory.isEmpty
                    ? Center(child: Text('No scans found for this date'))
                    : ListView.builder(
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final scan = filteredHistory[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: ListTile(
                            title: Text('Severity: ${scan['severity']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time: ${DateFormat('hh:mm a').format(scan['date'])}',
                                ),
                                SizedBox(height: 4),
                                Text('${scan['details']}'),
                              ],
                            ),
                            isThreeLine: true,
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(scan['severity']),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.face, color: Colors.white),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // View detailed result (can be implemented later)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('View detailed scan result'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Normal':
        return Colors.green;
      case 'Mild':
        return Colors.amber;
      case 'Moderate':
        return Colors.orange;
      case 'Severe':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
