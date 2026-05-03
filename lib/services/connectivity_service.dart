import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  // To keep track of the current status
  bool _isOffline = false;

  void initialize(GlobalKey<ScaffoldMessengerState> messengerKey) {
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkStatus(results, messengerKey);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _checkStatus(List<ConnectivityResult> results, GlobalKey<ScaffoldMessengerState> messengerKey) {
    // connectivity_plus 6.0.0+ returns a List<ConnectivityResult>
    final bool isDisconnected = results.isEmpty || results.contains(ConnectivityResult.none);

    if (isDisconnected) {
      if (!_isOffline) {
        _isOffline = true;
        _showNoInternetSnackBar(messengerKey);
      }
    } else {
      if (_isOffline) {
        _isOffline = false;
        _showBackOnlineSnackBar(messengerKey);
      }
    }
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
        duration: const Duration(days: 365), // Keep it visible until connection returns or dismissed
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
  
  // Method to check initial connection on app start
  Future<void> checkInitialConnection(GlobalKey<ScaffoldMessengerState> messengerKey) async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOffline = true;
      _showNoInternetSnackBar(messengerKey);
    }
  }
}
