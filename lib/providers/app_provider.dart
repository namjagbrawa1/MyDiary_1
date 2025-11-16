import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/topic.dart';
import '../models/diary_entry.dart';
import '../models/diary_item.dart';
import '../models/memo.dart';
import '../models/contact.dart';
import '../utils/theme_manager.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Theme
  int _currentTheme = ThemeManager.themeTaki;
  String _userName = '';
  String? _profilePicture;
  
  // Topics
  List<Topic> _topics = [];
  
  // Current selected topic
  Topic? _selectedTopic;
  
  // Diary entries
  List<DiaryEntry> _diaryEntries = [];
  List<DiaryItem> _currentDiaryItems = [];
  
  // Memos
  List<Memo> _memos = [];
  
  // Contacts
  List<Contact> _contacts = [];
  
  // Loading states
  bool _isLoading = false;
  
  // Search
  String _searchQuery = '';
  
  // Getters
  int get currentTheme => _currentTheme;
  String get userName => _userName;
  String? get profilePicture => _profilePicture;
  List<Topic> get topics => _topics;
  Topic? get selectedTopic => _selectedTopic;
  List<DiaryEntry> get diaryEntries => _diaryEntries;
  List<DiaryItem> get currentDiaryItems => _currentDiaryItems;
  List<Memo> get memos => _memos;
  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  // Initialize app
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load theme settings
      _currentTheme = await ThemeManager.getCurrentTheme();
      _userName = await ThemeManager.getUserName();
      _profilePicture = await ThemeManager.getProfilePicture();
      
      // Load topics
      await loadTopics();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Theme methods
  Future<void> setTheme(int theme) async {
    _currentTheme = theme;
    await ThemeManager.setTheme(theme);
    notifyListeners();
  }
  
  Future<void> setUserName(String name) async {
    _userName = name;
    await ThemeManager.setUserName(name);
    notifyListeners();
  }
  
  Future<void> setProfilePicture(String? path) async {
    _profilePicture = path;
    await ThemeManager.setProfilePicture(path);
    notifyListeners();
  }
  
  // Topic methods
  Future<void> loadTopics() async {
    try {
      _topics = await _databaseHelper.getTopics();
      
      // Update topic counts
      for (int i = 0; i < _topics.length; i++) {
        int count = 0;
        switch (_topics[i].type) {
          case Topic.typeDiary:
            count = await _databaseHelper.getDiaryCountByTopicId(_topics[i].id!);
            break;
          case Topic.typeMemo:
            count = await _databaseHelper.getMemoCountByTopicId(_topics[i].id!);
            break;
          case Topic.typeContacts:
            count = await _databaseHelper.getContactCountByTopicId(_topics[i].id!);
            break;
        }
        _topics[i] = _topics[i].copyWith(count: count);
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addTopic(Topic topic) async {
    try {
      await _databaseHelper.insertTopic(topic);
      await loadTopics();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateTopic(Topic topic) async {
    try {
      await _databaseHelper.updateTopic(topic);
      await loadTopics();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteTopic(int id) async {
    try {
      await _databaseHelper.deleteTopic(id);
      await loadTopics();
    } catch (e) {
      rethrow;
    }
  }
  
  void selectTopic(Topic? topic) {
    _selectedTopic = topic;
    notifyListeners();
    
    if (topic != null) {
      switch (topic.type) {
        case Topic.typeDiary:
          loadDiaryEntries(topic.id!);
          break;
        case Topic.typeMemo:
          loadMemos(topic.id!);
          break;
        case Topic.typeContacts:
          loadContacts(topic.id!);
          break;
      }
    }
  }
  
  // Diary methods
  Future<void> loadDiaryEntries(int topicId) async {
    try {
      _diaryEntries = await _databaseHelper.getDiaryEntries(topicId: topicId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addDiaryEntry(DiaryEntry entry) async {
    try {
      await _databaseHelper.insertDiaryEntry(entry);
      if (_selectedTopic != null) {
        await loadDiaryEntries(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    try {
      await _databaseHelper.updateDiaryEntry(entry);
      if (_selectedTopic != null) {
        await loadDiaryEntries(_selectedTopic!.id!);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteDiaryEntry(int id) async {
    try {
      await _databaseHelper.deleteDiaryEntry(id);
      if (_selectedTopic != null) {
        await loadDiaryEntries(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  // Diary item methods
  Future<void> loadDiaryItems(int diaryId) async {
    try {
      _currentDiaryItems = await _databaseHelper.getDiaryItems(diaryId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addDiaryItem(DiaryItem item) async {
    try {
      await _databaseHelper.insertDiaryItem(item);
      await loadDiaryItems(item.diaryId);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateDiaryItem(DiaryItem item) async {
    try {
      await _databaseHelper.updateDiaryItem(item);
      await loadDiaryItems(item.diaryId);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteDiaryItem(int id, int diaryId) async {
    try {
      await _databaseHelper.deleteDiaryItem(id);
      await loadDiaryItems(diaryId);
    } catch (e) {
      rethrow;
    }
  }
  
  // Memo methods
  Future<void> loadMemos(int topicId) async {
    try {
      _memos = await _databaseHelper.getMemos(topicId: topicId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addMemo(Memo memo) async {
    try {
      await _databaseHelper.insertMemo(memo);
      if (_selectedTopic != null) {
        await loadMemos(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateMemo(Memo memo) async {
    try {
      await _databaseHelper.updateMemo(memo);
      if (_selectedTopic != null) {
        await loadMemos(_selectedTopic!.id!);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteMemo(int id) async {
    try {
      await _databaseHelper.deleteMemo(id);
      if (_selectedTopic != null) {
        await loadMemos(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  // Contact methods
  Future<void> loadContacts(int topicId) async {
    try {
      _contacts = await _databaseHelper.getContacts(topicId: topicId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addContact(Contact contact) async {
    try {
      await _databaseHelper.insertContact(contact);
      if (_selectedTopic != null) {
        await loadContacts(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateContact(Contact contact) async {
    try {
      await _databaseHelper.updateContact(contact);
      if (_selectedTopic != null) {
        await loadContacts(_selectedTopic!.id!);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteContact(int id) async {
    try {
      await _databaseHelper.deleteContact(id);
      if (_selectedTopic != null) {
        await loadContacts(_selectedTopic!.id!);
      }
      await loadTopics(); // Update counts
    } catch (e) {
      rethrow;
    }
  }
  
  // Search methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  Future<List<DiaryEntry>> searchDiaryEntries(String query) async {
    try {
      return await _databaseHelper.searchDiaryEntries(query);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Memo>> searchMemos(String query) async {
    try {
      return await _databaseHelper.searchMemos(query);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<Contact>> searchContacts(String query) async {
    try {
      return await _databaseHelper.searchContacts(query);
    } catch (e) {
      rethrow;
    }
  }
}