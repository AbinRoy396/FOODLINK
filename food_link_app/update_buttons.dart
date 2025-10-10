import 'dart:io';

void main() {
  // Read the main.dart file
  final file = File('lib/main.dart');
  String content = file.readAsStringSync();

  // Define the new button style
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
                    ),''';

  // Replace all ElevatedButton styles
  final regex = RegExp(r'style: ElevatedButton\.styleFrom\([^)]*\)', dotAll: true);
  content = content.replaceAllMapped(regex, (match) => newStyle);

  // Write the updated content back to the file
  file.writeAsStringSync(content);
  
  print('Successfully updated all ElevatedButton styles in main.dart');
}
