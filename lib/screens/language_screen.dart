import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class LanguageScreen extends StatelessWidget {
  // List of supported languages for the UI
  final List<Map<String, dynamic>> languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    // {'code': 'pa', 'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ'},
    // {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    // {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
  ];

  Future<void> _selectLanguage(BuildContext context, String code) async {
    // 1. Update App Language Instantly
    await context.setLocale(Locale(code));

    // 2. Mark "First Run" as false so we don't show this again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);

    // 3. Go to Login Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Select Language / भाषा चुनें"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            childAspectRatio: 1.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _selectLanguage(context, languages[index]['code']),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      languages[index]['native'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      languages[index]['name'],
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
