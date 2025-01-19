import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestSongPermission() async {
  try {
    final bool audioGranted = await Permission.audio.isGranted;
    final bool storageGranted = await Permission.storage.isGranted;

    if (Platform.isAndroid) {
      if (!audioGranted || !storageGranted) {
        final Map<Permission, PermissionStatus> statuses =
            await [Permission.audio, Permission.storage].request();

        if (statuses[Permission.audio] == PermissionStatus.permanentlyDenied ||
            statuses[Permission.storage] ==
                PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }
    }
  } catch (e) {
    debugPrint("Erreur audio Permission: $e");
  }
}
