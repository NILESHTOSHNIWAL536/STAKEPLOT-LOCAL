import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<File?> pickImageWithPermissions(
  BuildContext context, {
  required Function(String) showErrorSnackBar,
}) async {

  // Check initial permission status
  PermissionStatus status;

  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      status = await Permission.photos.status;
    } else {
      status = await Permission.storage.status;
    }
  } else {
    status = await Permission.photos.status;
  }

  // Request permission if not granted
  if (!status.isGranted) {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }
  }

  // Handle permission outcomes
  if (status.isGranted) {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      } else {
        showErrorSnackBar('No image selected');
        return null;
      }
    } catch (e) {
      showErrorSnackBar('Error picking image: $e');
      return null;
    }
  } else if (status.isDenied) {
    showErrorSnackBar('Please grant photo library access to select images');
    return null;
  } else if (status.isPermanentlyDenied) {
    showErrorSnackBar(
      'Photo library access is permanently denied. Please enable it in settings.',
    );
    await openAppSettings();
    return null;
  } else {
    showErrorSnackBar('Unknown permission status: $status');
    return null;
  }
}