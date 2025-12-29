import 'package:arqgene_farmer_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/Re fork farmer.json'),
              SizedBox(height: 20),
              Text(
                'ARQGENE FARMER',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                label: Text(
                  'Get Started',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
