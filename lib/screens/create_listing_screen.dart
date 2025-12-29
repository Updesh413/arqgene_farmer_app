import 'dart:io';
import 'package:arqgene_farmer_app/db/isar_service.dart';
import 'package:arqgene_farmer_app/db/schemas.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // For currency formatting logic if needed

class CreateListingScreen extends StatefulWidget {
  final String filePath;
  final String mediaType; // 'image' or 'video'

  const CreateListingScreen({required this.filePath, required this.mediaType});

  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final IsarService _isarService = IsarService();
  bool _isSaving = false;

  void _saveToDb() async {
    if (_priceController.text.isEmpty) return;

    setState(() => _isSaving = true);

    final listing = CropListing()
      ..mediaPath = widget.filePath
      ..mediaType = widget.mediaType
      ..description = _descController.text
      ..price = double.tryParse(_priceController.text) ?? 0.0
      ..createdAt = DateTime.now()
      ..isSynced = false;

    await _isarService.saveListing(listing);

    // Close form and go back to Home
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sell Crop Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Media Preview
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black12,
              child: widget.mediaType == 'image'
                  ? Image.file(File(widget.filePath), fit: BoxFit.cover)
                  : Icon(
                      Icons.videocam,
                      size: 100,
                      color: Colors.grey,
                    ), // Simplified video placeholder
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 2. Price Input
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    decoration: InputDecoration(
                      labelText: "Price (₹ per kg)",
                      border: OutlineInputBorder(),
                      prefixText: "₹ ",
                    ),
                  ),
                  SizedBox(height: 20),

                  // 3. Description Input
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description (Quality, Variety)",
                      border: OutlineInputBorder(),
                      hintText: "e.g., Fresh red onions, harvested today...",
                    ),
                  ),
                  SizedBox(height: 30),

                  // 4. Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveToDb,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: _isSaving
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Post to Market",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
