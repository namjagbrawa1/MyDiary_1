import 'dart:io';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String? profilePicture;
  final VoidCallback onSettingsTap;

  const ProfileHeader({
    super.key,
    required this.userName,
    this.profilePicture,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profilePicture != null && File(profilePicture!).existsSync()
                  ? Image.file(
                      File(profilePicture!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // User name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Settings button
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}