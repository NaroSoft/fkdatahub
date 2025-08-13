import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
//import 'dart:js' as js;
import 'dart:convert';

class UpdateChecker {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // Get current version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Fetch latest version info
      const versionUrl = '/version.json';
      final response = await http.get(Uri.parse(versionUrl));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'];
        final latestBuild = data['build'];
        final updateMessage = data['update_message'] ?? 'A new version is available';

        // Compare versions
        if (latestBuild > currentBuild) {
          _showUpdateDialog(context, latestVersion, updateMessage);
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static void _showUpdateDialog(
    BuildContext context, 
    String newVersion, 
    String message
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New version: $newVersion'),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              // Trigger the update
              Navigator.pop(context);
              _applyUpdate();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  static void _applyUpdate() {
    // This calls the JavaScript function to apply the update
   if (kIsWeb) {
      //js.context.callMethod('applyUpdate');
    }
  }
}