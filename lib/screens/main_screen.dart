import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/topic.dart';
import '../utils/theme_manager.dart';
import '../widgets/topic_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/add_topic_dialog.dart';
import 'diary_screen.dart';
import 'memo_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Topic> _filteredTopics = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Just trigger a rebuild, filtering is now handled in build method
    setState(() {});
  }

  void _onTopicTap(Topic topic) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.selectTopic(topic);

    Widget screen;
    switch (topic.type) {
      case Topic.typeDiary:
        screen = DiaryScreen(topic: topic);
        break;
      case Topic.typeMemo:
        screen = MemoScreen(topic: topic);
        break;
      case Topic.typeContacts:
        screen = ContactsScreen(topic: topic);
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showAddTopicDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTopicDialog(),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Always update filtered topics when search is empty
          if (_searchController.text.isEmpty) {
            _filteredTopics = appProvider.topics;
          } else {
            // Re-apply search filter when topics change
            final query = _searchController.text.toLowerCase();
            _filteredTopics = appProvider.topics
                .where((topic) =>
                    topic.name.toLowerCase().contains(query) ||
                    (topic.subtitle?.toLowerCase().contains(query) ?? false))
                .toList();
          }

          return Container(
            decoration: BoxDecoration(
              gradient: ThemeManager.getThemeGradient(appProvider.currentTheme),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Profile header
                  ProfileHeader(
                    userName: appProvider.userName,
                    profilePicture: appProvider.profilePicture,
                    onSettingsTap: _navigateToSettings,
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search topics...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Topics list
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Topics header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Topics',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _showAddTopicDialog,
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: ThemeManager.getThemeColor(
                                        appProvider.currentTheme),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Topics grid
                          Expanded(
                            child: _filteredTopics.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.folder_open,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchController.text.isEmpty
                                              ? 'No topics yet.\nTap + to create your first topic!'
                                              : 'No topics found.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: _filteredTopics.length,
                                    itemBuilder: (context, index) {
                                      final topic = _filteredTopics[index];
                                      return TopicCard(
                                        topic: topic,
                                        onTap: () => _onTopicTap(topic),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}