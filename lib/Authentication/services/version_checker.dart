// lib/services/version_checker.dart
import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'package:flutter/material.dart';

class VersionChecker {
  static const String versionUrl = '/version.json';
  static String currentVersion = '1.0.0'; // Should match pubspec.yaml
  static Timer? _checkTimer;
  
  static Future<String> getRemoteVersion() async {
    try {
      //final response = await HttpRequest.getString(versionUrl);
      //final remoteData = jsonDecode(response);
      //return remoteData['version'] as String;
      return "done";
    } catch (e) {
      return currentVersion;
    }
  }

  static Future<bool> hasUpdate() async {
    final remoteVersion = await getRemoteVersion();
    return remoteVersion != currentVersion;
  }

  static void startPeriodicChecks(BuildContext context) {
    // Cancel any existing timer
    _checkTimer?.cancel();
    
    // Check immediately
    _checkForUpdate(context);
    
    // Then check every 30 minutes
    _checkTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _checkForUpdate(context);
    });
  }

  static Future<void> _checkForUpdate(BuildContext context) async {
    if (await hasUpdate()) {
      _showUpdateDialog(context);
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text('A new version of the app is available.'),
        actions: [
          TextButton(
            onPressed: (){},
            // => window.location.reload(), // Force reload
            child: const Text('Reload Now'),
          ),
        ],
      ),
    );
  }
}