import '../commons.dart';

// ---------------------------- UI Utilities ----------------------------

/// Displays a toast message.
String? _lastToastMessage;

void showToast(String text, Color bgColor, Color txtColor) {
  // Check if the new text is the same as the last shown message
  // if (_lastToastMessage == text) return;

  // Update last message
  // _lastToastMessage = text;

  // Cancel any existing toast
  Fluttertoast.cancel();

  // Show new toast
  Fluttertoast.showToast(
    msg: text,
    backgroundColor: bgColor,
    textColor: txtColor,
    toastLength: Toast.LENGTH_SHORT,
  );
}