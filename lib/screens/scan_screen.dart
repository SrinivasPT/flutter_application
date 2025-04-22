import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      // Simulate a scan process
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
          });
          _showScanResult();
        }
      });
    }
  }

  void _showScanResult() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Facial Symmetry Analysis'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Complete',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                Text('Assessment Result: Mild asymmetry detected'),
                SizedBox(height: 8),
                Text('• Left side shows slight weakness in smile movement'),
                Text('• Eye closure appears normal on both sides'),
                Text('• Forehead movement shows minimal difference'),
                SizedBox(height: 12),
                Text(
                  'This analysis helps detect signs of facial paralysis or Bell\'s palsy. Please consult with a healthcare provider for proper medical advice.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Save Result'),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Result saved to history')),
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Facial Paralysis Scanner'), elevation: 2),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Facial Symmetry Assessment Tool',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'This tool uses computer vision to detect facial asymmetry, which may indicate facial paralysis or Bell\'s palsy. '
                  'Position your face in the frame and follow the instructions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _isScanning
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
                              Text('Analyzing facial symmetry...'),
                            ],
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face,
                                size: 120,
                                color: Colors.grey[400],
                              ),
                              Text(
                                'Face Scanner',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
              ),
              SizedBox(height: 30),
              Text(
                _isScanning
                    ? 'Please hold still...'
                    : 'Position your face within the frame',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                _isScanning
                    ? 'Analyzing facial movements'
                    : 'Make sure your face is well-lit and centered',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(_isScanning ? Icons.stop : Icons.camera),
                label: Text(_isScanning ? 'Cancel Scan' : 'Start Analysis'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: _isScanning ? Colors.red : Colors.blue,
                ),
                onPressed: _toggleScan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
