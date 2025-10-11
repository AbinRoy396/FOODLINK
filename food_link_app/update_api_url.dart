import 'dart:io';

void main() {
  print('========================================');
  print('FoodLink - Update API URL');
  print('========================================\n');

  print('Choose environment:');
  print('1. Local Development (http://192.168.4.88:3000/api)');
  print('2. Production (Render - enter your URL)');
  print('3. Custom URL');
  
  stdout.write('\nEnter choice (1-3): ');
  final choice = stdin.readLineSync();
  
  String newUrl;
  
  switch (choice) {
    case '1':
      newUrl = 'http://192.168.4.88:3000/api';
      break;
    case '2':
      stdout.write('Enter your Render URL (e.g., https://foodlink-api.onrender.com/api): ');
      newUrl = stdin.readLineSync() ?? '';
      if (!newUrl.startsWith('http')) {
        print('❌ Invalid URL format');
        return;
      }
      break;
    case '3':
      stdout.write('Enter custom URL: ');
      newUrl = stdin.readLineSync() ?? '';
      if (!newUrl.startsWith('http')) {
        print('❌ Invalid URL format');
        return;
      }
      break;
    default:
      print('❌ Invalid choice');
      return;
  }
  
  // Read the file
  final file = File('lib/services/api_service.dart');
  if (!file.existsSync()) {
    print('❌ api_service.dart not found!');
    return;
  }
  
  String content = file.readAsStringSync();
  
  // Replace the baseUrl line
  final regex = RegExp(r'static const String baseUrl = "[^"]+";');
  if (!regex.hasMatch(content)) {
    print('❌ Could not find baseUrl in api_service.dart');
    return;
  }
  
  content = content.replaceFirst(
    regex,
    'static const String baseUrl = "$newUrl";'
  );
  
  // Write back
  file.writeAsStringSync(content);
  
  print('\n✅ API URL updated successfully!');
  print('📝 New URL: $newUrl');
  print('\nNext steps:');
  print('1. Run: flutter clean');
  print('2. Run: flutter pub get');
  print('3. Build APK: flutter build apk --release');
}
