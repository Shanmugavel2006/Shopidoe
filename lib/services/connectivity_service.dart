import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  // To keep track of the current status
  bool _isOffline = false;
  bool _isPoorConnection = false;

  void initialize(GlobalKey<ScaffoldMessengerState> messengerKey) {
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkStatus(results, messengerKey);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _checkStatus(List<ConnectivityResult> results, GlobalKey<ScaffoldMessengerState> messengerKey) async {
    final bool isDisconnected = results.isEmpty || results.contains(ConnectivityResult.none);

    if (isDisconnected) {
      if (!_isOffline) {
        _isOffline = true;
        _isPoorConnection = false; // Reset poor connection if offline
        _showNoInternetSnackBar(messengerKey);
      }
    } else {
      if (_isOffline) {
        _isOffline = false;
        _showBackOnlineSnackBar(messengerKey);
      }
      // Check for poor connection even if online
      _checkLatency(messengerKey);
    }
  }

  Future<void> _checkLatency(GlobalKey<ScaffoldMessengerState> messengerKey) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode == 200) {
        if (stopwatch.elapsedMilliseconds > 3000) { // If latency is more than 3 seconds
          if (!_isPoorConnection) {
            _isPoorConnection = true;
            _showPoorNetworkSnackBar(messengerKey);
          }
        } else {
          if (_isPoorConnection) {
            _isPoorConnection = false;
            messengerKey.currentState?.clearSnackBars();
          }
        }
      }
    } catch (e) {
      // If timeout or error, it might be poor connection
      if (!_isPoorConnection && !_isOffline) {
        _isPoorConnection = true;
        _showPoorNetworkSnackBar(messengerKey);
      }
    }
  }

  void _showPoorNetworkSnackBar(GlobalKey<ScaffoldMessengerState> messengerKey) {
    messengerKey.currentState?.clearSnackBars();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.signal_cellular_connected_no_internet_4_bar, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Poor Network Connection. Some features may be slow.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orangeAccent,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNoInternetSnackBar(GlobalKey<ScaffoldMessengerState> messengerKey) {
    messengerKey.currentState?.clearSnackBars();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No Internet Connection. Please check your network.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(days: 365), 
        behavior: SnackBarBehavior.fixed,
        dismissDirection: DismissDirection.none,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () async {
            final List<ConnectivityResult> currentResults = await _connectivity.checkConnectivity();
            _checkStatus(currentResults, messengerKey);
          },
        ),
      ),
    );
  }

  void _showBackOnlineSnackBar(GlobalKey<ScaffoldMessengerState> messengerKey) {
    messengerKey.currentState?.clearSnackBars();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Back Online',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Future<void> checkInitialConnection(GlobalKey<ScaffoldMessengerState> messengerKey) async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      _showNoInternetSnackBar(messengerKey);
    } else {
      _checkLatency(messengerKey);
    }
  }
}
