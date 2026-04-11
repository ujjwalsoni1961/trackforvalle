import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class NetworkStatus extends ChangeNotifier {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.mobile];
  bool _hasConnection = true;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  NetworkStatus() {
    _initConnectivity();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _connectionStatus = results;
      _hasConnection = !results.contains(ConnectivityResult.none);
      log('Network status changed: $_connectionStatus, hasConnection: $_hasConnection');
      notifyListeners();
    });
  }

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get hasConnection => _hasConnection;
  bool get isOnline => _hasConnection && !_connectionStatus.contains(ConnectivityResult.none);
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await Connectivity().checkConnectivity();
    } catch (e) {
      log('Error checking connectivity: $e');
      results = [ConnectivityResult.mobile];
    }
    _connectionStatus = results;
    _hasConnection = !results.contains(ConnectivityResult.none);
    notifyListeners();
  }

  void updateSyncStatus(bool syncing) {
    _isSyncing = syncing;
    if (!syncing) {
      _lastSyncTime = DateTime.now();
    }
    notifyListeners();
  }

  String getConnectionStatusText() {
    if (!_hasConnection || _connectionStatus.contains(ConnectivityResult.none)) {
      return 'No internet connection';
    }
    
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'Connected via WiFi';
    }
    
    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Connected via mobile data';
    }
    
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Connected via ethernet';
    }
    
    return 'Connected';
  }

  Color getConnectionStatusColor() {
    if (!_hasConnection || _connectionStatus.contains(ConnectivityResult.none)) {
      return Colors.red;
    }
    
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Colors.green;
    }
    
    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Colors.orange;
    }
    
    return Colors.green;
  }
}
