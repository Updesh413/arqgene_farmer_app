// import 'package:arqgene_farmer_app/screens/language_screen.dart';
// import 'package:arqgene_farmer_app/screens/profile_screen.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Required for logout

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // Function to handle logout
//   void _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     // The StreamBuilder in main.dart handles the navigation automatically
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // 1. Add AppBar so the user can sign out
//       appBar: AppBar(
//         title: const Text("home_title").tr(),
//         backgroundColor: Colors.green, // Match your theme
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             tooltip: "profile".tr(),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute<void>(builder: (context) => ProfileScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             tooltip: "settings".tr(),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute<void>(builder: (context) => LanguageScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: "logout".tr(),
//             onPressed: _signOut,
//           ),
//         ],
//       ),

//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/background.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.agriculture, size: 80, color: Colors.white),
//                 const SizedBox(height: 20),
//                 Text(
//                   "welcome_title".tr(),
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color:
//                         Colors.white, // White text to stand out on background
//                     shadows: [
//                       Shadow(
//                         offset: Offset(1, 1),
//                         blurRadius: 3,
//                         color: Colors.black,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:arqgene_farmer_app/db/isar_service.dart';
import 'package:arqgene_farmer_app/db/schemas.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'create_listing_screen.dart';
import 'language_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final IsarService _isarService = IsarService();

  // 1. Capture Logic
  Future<void> _captureMedia(ImageSource source, String type) async {
    final XFile? media = type == 'image'
        ? await _picker.pickImage(source: source)
        : await _picker.pickVideo(source: source);

    if (media != null) {
      // Navigate to the Details Form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CreateListingScreen(filePath: media.path, mediaType: type),
        ),
      );
    }
  }

  void _signOut() async {
    await context.read<AuthProvider>().signOut();
    // The StreamBuilder in main.dart handles the navigation automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("home_title").tr(),
        backgroundColor: Colors.green, // Match your theme
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "profile".tr(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "settings".tr(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => LanguageScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "logout".tr(),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // TOP SECTION: ACTION BUTTONS
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.green[50],
            child: Row(
              children: [
                // Button 1: Take Photo
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: "Sell by\nPhoto",
                    color: Colors.orange,
                    onTap: () => _captureMedia(ImageSource.camera, 'image'),
                  ),
                ),
                SizedBox(width: 15),
                // Button 2: Record Video
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.videocam,
                    label: "Sell by\nVideo",
                    color: Colors.blue,
                    onTap: () => _captureMedia(ImageSource.camera, 'video'),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // BOTTOM SECTION: LIST OF UPLOADS
          Expanded(
            child: StreamBuilder<List<CropListing>>(
              stream: _isarService.getAllListings(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No crops listed yet."));
                }

                final listings = snapshot.data!;
                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          // Display thumbnail if image
                          child: item.mediaType == 'image'
                              ? Image.file(
                                  File(item.mediaPath),
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.play_circle_fill),
                        ),
                        title: Text("₹ ${item.price}"),
                        subtitle: Text(item.description ?? "No description"),
                        trailing: Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                        ), // 'Grey' means offline
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black26,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
