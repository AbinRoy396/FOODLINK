import 'package:flutter/material.dart';

class AppButtonStyles {
  // Primary button style (green background, black text)
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.black,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  );

  // Secondary button style (outlined button)
  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.green,
    side: const BorderSide(color: Colors.green),
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Text button style (text only)
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: Colors.green,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
