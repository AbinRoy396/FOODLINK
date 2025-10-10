import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  if (!file.existsSync()) {
    print('Error: main.dart not found');
    return;
  }

  String content = file.readAsStringSync();
  
  // Fix the login button
  final loginButtonPattern = RegExp(
    r'(ElevatedButton\(\s*onPressed: [^}]*?\s*style: )ElevatedButton\.styleFrom\([^}]*?\)',
    dotAll: true,
  );
  
  const loginButtonReplacement = r'$1ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevation: MaterialStateProperty.all<double>(0),
  )';
  
  content = content.replaceAllMapped(loginButtonPattern, (match) => loginButtonReplacement);
  
  // Fix other buttons
  final buttonPattern = RegExp(
    r'ElevatedButton\(\s*onPressed: [^}]*?\s*style: ElevatedButton\.styleFrom\(([^}]*?)\)',
    dotAll: true,
  );
  
  content = content.replaceAllMapped(buttonPattern, (match) {
    final existingStyle = match.group(1) ?? '';
    return 'ElevatedButton(
      onPressed: ${match.group(1)?.trim() ?? ''},
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
      )';
  });
  
  // Save the file
  file.writeAsStringSync(content);
  print('✅ Button styles have been updated in main.dart');
}
