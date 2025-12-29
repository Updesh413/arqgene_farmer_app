import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().reset();
    });
  }

  // 1. Send OTP Logic
  void _sendOtp() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("invalid_phone".tr())));
      return;
    }

    // Add country code (Hardcoded to +91 for India, change as needed)
    String number = "+91" + _phoneController.text.trim();

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyPhoneNumber(number);

    if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed: ${authProvider.errorMessage}"),
        ),
      );
    }
  }

  // 2. Verify OTP Logic
  void _verifyOtp() async {
    String otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a full 6-digit code")),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOTP(otp);

    if (mounted) {
       if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Error: ${authProvider.errorMessage}"),
          ),
        );
      } else {
         // Success is handled by AuthWrapper listening to authStateChanges
         // But we can manually navigate if needed, or just let the stream do it.
         // Since we are in AuthWrapper, it will rebuild and switch to HomeScreen/ProfileScreen.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        bool isOtpSent = authProvider.verificationId != null;
        bool isLoading = authProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text("app_title").tr(),
            centerTitle: true,
            backgroundColor: Colors.green,
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // STEP 1: PHONE INPUT
                  if (!isOtpSent) ...[
                    Text(
                      "welcome_title".tr(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("enter_mobile_instruction".tr()),
                    SizedBox(height: 30),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        prefixText: "+91 ",
                        labelText: "phone_label".tr(),
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("get_otp".tr(), style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ]
                  // STEP 2: OTP INPUT
                  else ...[
                    Text(
                      "verify_phone_title".tr(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("enter_code_instruction".tr()),
                    SizedBox(height: 30),

                    Pinput(
                      length: 6,
                      controller: _otpController, // Bind controller
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // THE VERIFY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "verify_proceed".tr(),
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        authProvider.reset();
                        _otpController.clear();
                      },
                      child: Text("change_phone".tr()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
