import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';


class AppToast {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF3A1025), // dark wine red
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(message),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12),
    );
  }
}