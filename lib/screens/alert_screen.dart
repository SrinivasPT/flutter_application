import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import '../models/alert.dart';

class AlertScreen extends StatefulWidget {
  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final List<Alert> _alerts = [];
  WebSocketChannel? _channel;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isConnected = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  static const String _serverUrl =
      'ws://10.0.2.2:3006/ws'; // Use your actual server address
  // For local development, use 10.0.2.2 for Android emulator
  static const int _maxAlertsToShow = 5; // Updated to show 10 alerts

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _connectWebSocket();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  void _connectWebSocket() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      _reconnectTimer!.cancel();
    }

    try {
      setState(() {
        _isConnected = false;
      });

      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

      _channel!.stream.listen(
        (message) {
          setState(() {
            _isConnected = true;
            _reconnectAttempt = 0;
          });

          final data = json.decode(message);
          switch (data['type']) {
            case 'INITIAL_STATE':
              _handleInitialState(data['data']);
              break;
            case 'NEW_ALERT':
              _handleNewAlert(data['data']);
              break;
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleConnectionFailure(
            'Connection Error',
            'Error connecting to server',
          );
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleConnectionFailure(
            'Connection Closed',
            'Server connection was closed',
          );
        },
      );
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _handleConnectionFailure(
        'Connection Failed',
        'Could not connect to server',
      );
    }
  }

  void _handleConnectionFailure(String title, String message) {
    if (mounted) {
      setState(() {
        _isConnected = false;
      });

      _showNotification(title, message);

      // Implement exponential backoff for reconnection attempts
      _reconnectAttempt++;
      final backoffSeconds = _calculateBackoff(_reconnectAttempt);
      print(
        'Attempting to reconnect in $backoffSeconds seconds (attempt $_reconnectAttempt)',
      );

      _reconnectTimer = Timer(
        Duration(seconds: backoffSeconds),
        _connectWebSocket,
      );
    }
  }

  int _calculateBackoff(int attempt) {
    // Exponential backoff with max of 30 seconds
    return attempt > 5 ? 30 : (1 << attempt);
  }

  void _handleInitialState(List<dynamic> alerts) {
    setState(() {
      _alerts.clear();
      try {
        _alerts.addAll(
          alerts.map((a) => Alert.fromJson(a as Map<String, dynamic>)).toList(),
        );
        // Trim to keep only the most recent alerts
        if (_alerts.length > _maxAlertsToShow) {
          _alerts.removeRange(_maxAlertsToShow, _alerts.length);
        }
      } catch (e) {
        print('Error parsing initial alerts: $e');
      }
    });
  }

  void _handleNewAlert(Map<String, dynamic> alertData) {
    try {
      final alert = Alert.fromJson(alertData);
      setState(() {
        _alerts.insert(0, alert);
        // Keep only the most recent alerts
        if (_alerts.length > _maxAlertsToShow) {
          _alerts.removeRange(_maxAlertsToShow, _alerts.length);
        }
      });

      _showNotification(alert.title, alert.imageName);
    } catch (e) {
      print('Error handling new alert: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'alerts_channel',
          'Alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(0, title, body, platformChannelSpecifics);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  void _manualReconnect() {
    _reconnectAttempt = 0;
    _connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Alerts'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _manualReconnect),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () => _showConnectionInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusIndicator(),
          Expanded(
            child:
                _alerts.isEmpty
                    ? Center(child: Text('No alerts received yet'))
                    : ListView.builder(
                      reverse: true, // Newest first
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        final alert = _alerts[index];
                        return _buildAlertCard(alert);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: _isConnected ? Colors.green : Colors.red,
            size: 12,
          ),
          SizedBox(width: 8),
          Text(
            _isConnected
                ? 'Connected to server'
                : 'Disconnected - Reconnecting...',
          ),
          if (!_isConnected) Spacer(),
          if (!_isConnected)
            TextButton(
              onPressed: _manualReconnect,
              child: Text('Retry Now'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.blue),
        title: Text(alert.title),
        subtitle: Text(alert.imageName),
        trailing: Text(
          DateFormat('HH:mm:ss').format(alert.timestamp),
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () => _showAlertDetails(alert),
      ),
    );
  }

  void _showAlertDetails(Alert alert) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Display the image
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildAlertImage(alert.filePath),
                    ),
                    SizedBox(height: 24),

                    // Patient information
                    _buildInfoRow("Patient ID", alert.patientId),
                    _buildInfoRow("Patient Name", alert.patientName),
                    _buildInfoRow("Date of Birth", alert.patientDateOfBirth),
                    _buildInfoRow("Referring Physician", "Dr John Doe"),
                    _buildInfoRow(
                      "Detection Time",
                      DateFormat(
                        'MMM dd, yyyy - HH:mm:ss',
                      ).format(alert.timestamp),
                    ),

                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16)),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildAlertImage(String fileName) {
    if (fileName.isEmpty) {
      return Center(child: Text('No image available'));
    }

    try {
      // Extract just the filename from the path (removing directory parts)
      String justFileName = fileName.split('/').last.split('\\').last;

      // First try to load from assets
      String assetPath = 'assets/images/$justFileName';

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Could not load from assets: $error. Trying file path...');

            // Fallback to file path loading if asset loading fails
            if (fileName.startsWith('assets/')) {
              // If it's specified as an asset path
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  fileName,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading asset image: $error');
                    return _buildImageErrorWidget(error);
                  },
                ),
              );
            } else {
              // If it's a file path
              final file = File(fileName);
              if (file.existsSync()) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading file image: $error');
                      return _buildImageErrorWidget(error);
                    },
                  ),
                );
              } else {
                return _buildImageErrorWidget('File does not exist');
              }
            }
          },
        ),
      );
    } catch (e) {
      print('Exception trying to load image: $e');
      return _buildImageErrorWidget(e);
    }
  }

  Widget _buildImageErrorWidget(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Unable to load image', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showConnectionInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Connection Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Server: $_serverUrl'),
                SizedBox(height: 8),
                Text('Status: ${_isConnected ? "Connected" : "Disconnected"}'),
                SizedBox(height: 8),
                Text('Reconnect attempts: $_reconnectAttempt'),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Reconnect'),
                onPressed: () {
                  Navigator.pop(context);
                  _manualReconnect();
                },
              ),
            ],
          ),
    );
  }
}
