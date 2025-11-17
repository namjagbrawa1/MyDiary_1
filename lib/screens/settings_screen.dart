import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/app_provider.dart';
import '../utils/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _nameController.text = appProvider.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.setProfilePicture(pickedFile.path);
    }
  }

  Future<void> _updateUserName() async {
    if (_nameController.text.trim().isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.setUserName(_nameController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Profile picture
                      Center(
                        child: GestureDetector(
                          onTap: _pickProfilePicture,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ThemeManager.getThemeColor(
                                    appProvider.currentTheme),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: appProvider.profilePicture != null &&
                                      File(appProvider.profilePicture!)
                                          .existsSync()
                                  ? Image.file(
                                      File(appProvider.profilePicture!),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: ThemeManager.getThemeColor(
                                              appProvider.currentTheme)
                                          .withOpacity(0.1),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: ThemeManager.getThemeColor(
                                            appProvider.currentTheme),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // User name
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _updateUserName(),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ElevatedButton(
                        onPressed: _updateUserName,
                        child: const Text('Update Name'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Theme section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Theme selection
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => appProvider.setTheme(ThemeManager.themeTaki),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: ThemeManager.getThemeGradient(
                                      ThemeManager.themeTaki),
                                  borderRadius: BorderRadius.circular(12),
                                  border: appProvider.currentTheme == ThemeManager.themeTaki
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Taki',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: GestureDetector(
                              onTap: () => appProvider.setTheme(ThemeManager.themeMitsuha),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: ThemeManager.getThemeGradient(
                                      ThemeManager.themeMitsuha),
                                  borderRadius: BorderRadius.circular(12),
                                  border: appProvider.currentTheme == ThemeManager.themeMitsuha
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Mitsuha',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // About section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'MyDiary Flutter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Version 1.0.0'),
                      const SizedBox(height: 8),
                      Text(
                        'A cross-platform diary app inspired by the movie "Your Name" (君の名は).',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}