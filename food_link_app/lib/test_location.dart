import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  String _locationStatus = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Testing location...';
    });

    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = '❌ Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      // Step 2: Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      setState(() {
        _locationStatus = 'Current permission: $permission\nRequesting permission...';
      });

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        setState(() {
          _locationStatus = 'Permission after request: $permission';
        });
        
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = '❌ Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = '❌ Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      // Step 3: Get location
      setState(() {
        _locationStatus = 'Permission granted! Getting location...';
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _locationStatus = '✅ Location found!\nLat: ${position.latitude}\nLng: ${position.longitude}\nAccuracy: ${position.accuracy}m';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _locationStatus = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Location Permission Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Location Access'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _locationStatus,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Tap "Test Location Access"\n'
              '2. Grant permission when asked\n'
              '3. If no permission dialog appears, check emulator settings\n'
              '4. For emulator: Set mock location in Extended Controls',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
