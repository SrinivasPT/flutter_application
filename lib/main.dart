// main.dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(AlertApp());
}

class AlertApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Alerts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AlertScreen(),
    );
  }
}

class Alert {
  final int id;
  final String title;
  final String message;
  final bool isCritical;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.isCritical,
    required this.timestamp,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isCritical: json['isCritical'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

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
      'ws://10.0.2.2:8000/ws'; // Use your actual server address
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
      _alerts.addAll(alerts.map((a) => Alert.fromJson(a)).toList());
      // Trim to keep only the most recent alerts
      if (_alerts.length > _maxAlertsToShow) {
        _alerts.removeRange(_maxAlertsToShow, _alerts.length);
      }
    });
  }

  void _handleNewAlert(Map<String, dynamic> alertData) {
    final alert = Alert.fromJson(alertData);
    setState(() {
      _alerts.insert(0, alert);
      // Keep only the most recent alerts
      if (_alerts.length > _maxAlertsToShow) {
        _alerts.removeRange(_maxAlertsToShow, _alerts.length);
      }
    });

    _showNotification(alert.title, alert.message);
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
      color: alert.isCritical ? Colors.red[50] : null,
      child: ListTile(
        leading: Icon(
          alert.isCritical ? Icons.warning : Icons.notifications,
          color: alert.isCritical ? Colors.red : Colors.blue,
        ),
        title: Text(alert.title),
        subtitle: Text(alert.message),
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
          (context) => AlertDialog(
            title: Text(alert.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.message),
                SizedBox(height: 16),
                Text(
                  'Received: ${DateFormat('MMM dd, yyyy - HH:mm:ss').format(alert.timestamp)}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
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
