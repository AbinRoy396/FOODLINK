import 'dart:io';

void main() {
  // Update main.dart
  updateFile('lib/main.dart');
  
  // Update all dart files in lib/screens
  final screensDir = Directory('lib/screens');
  if (screensDir.existsSync()) {
    screensDir.listSync(recursive: true).forEach((file) {
      if (file.path.endsWith('.dart')) {
        updateFile(file.path);
      }
    });
  }
  
  print('✅ All buttons have been updated with green background and black text');
}

void updateFile(String filePath) {
  try {
    final file = File(filePath);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync();
    
    // Pattern to find ElevatedButton.styleFrom
    final pattern = RegExp(
      r'(ElevatedButton\.styleFrom\()([^)]*)\)',
      multiLine: true,
      dotAll: true,
    );
    
    // Replacement with new style
    const newStyle = '''
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevation: MaterialStateProperty.all<double>(0),
    )'''
    .replaceAll('\n', '\n    '); // Add proper indentation
    
    content = content.replaceAllMapped(pattern, (match) => newStyle);
    
    // Also update any existing ButtonStyle
    content = content.replaceAllMapped(
      RegExp(r'style: ButtonStyle\([^)]*\)', dotAll: true),
      (match) => newStyle,
    );
    
    file.writeAsStringSync(content);
    print('✅ Updated buttons in: $filePath');
  } catch (e) {
    print('❌ Error updating $filePath: $e');
  }
}
