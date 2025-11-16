import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/topic.dart';
import '../models/diary_entry.dart';
import '../models/diary_item.dart';
import '../models/memo.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'mydiary.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create topics table
    await db.execute('''
      CREATE TABLE topic_entry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_order INTEGER NOT NULL,
        topic_name TEXT NOT NULL,
        topic_type INTEGER NOT NULL,
        topic_subtitle TEXT,
        topic_color INTEGER NOT NULL
      )
    ''');

    // Create diary entries table (v2)
    await db.execute('''
      CREATE TABLE diary_entry_v2 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diary_time INTEGER NOT NULL,
        diary_title TEXT NOT NULL,
        diary_mood INTEGER NOT NULL,
        diary_weather INTEGER NOT NULL,
        diary_attachment TEXT,
        diary_ref_topic_id INTEGER NOT NULL,
        diary_location TEXT,
        FOREIGN KEY (diary_ref_topic_id) REFERENCES topic_entry (id)
      )
    ''');

    // Create diary items table (v2)
    await db.execute('''
      CREATE TABLE diary_item_entry_v2 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diary_item_type INTEGER NOT NULL,
        diary_item_position INTEGER NOT NULL,
        diary_item_content TEXT NOT NULL,
        item_ref_diary_id INTEGER NOT NULL,
        FOREIGN KEY (item_ref_diary_id) REFERENCES diary_entry_v2 (id)
      )
    ''');

    // Create memos table
    await db.execute('''
      CREATE TABLE memo_entry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memo_order INTEGER NOT NULL,
        memo_content TEXT NOT NULL,
        memo_checked INTEGER NOT NULL DEFAULT 0,
        memo_ref_topic_id INTEGER NOT NULL,
        FOREIGN KEY (memo_ref_topic_id) REFERENCES topic_entry (id)
      )
    ''');

    // Create contacts table
    await db.execute('''
      CREATE TABLE contacts_entry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contacts_name TEXT NOT NULL,
        contacts_phone_number TEXT,
        contacts_photo TEXT,
        contacts_ref_topic_id INTEGER NOT NULL,
        FOREIGN KEY (contacts_ref_topic_id) REFERENCES topic_entry (id)
      )
    ''');

    // Insert default topics
    await _insertDefaultTopics(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Handle database upgrades if needed
    }
  }

  Future<void> _insertDefaultTopics(Database db) async {
    // Insert default diary topic
    await db.insert('topic_entry', {
      'topic_order': 0,
      'topic_name': 'My Diary',
      'topic_type': Topic.typeDiary,
      'topic_subtitle': 'Personal thoughts and memories',
      'topic_color': 0xFF2196F3, // Blue
    });

    // Insert default memo topic
    await db.insert('topic_entry', {
      'topic_order': 1,
      'topic_name': 'Todo List',
      'topic_type': Topic.typeMemo,
      'topic_subtitle': 'Things to remember',
      'topic_color': 0xFF4CAF50, // Green
    });

    // Insert default contacts topic
    await db.insert('topic_entry', {
      'topic_order': 2,
      'topic_name': 'Friends',
      'topic_type': Topic.typeContacts,
      'topic_subtitle': 'Important people',
      'topic_color': 0xFFFF9800, // Orange
    });
  }

  // Topic operations
  Future<int> insertTopic(Topic topic) async {
    final db = await database;
    return await db.insert('topic_entry', topic.toMap());
  }

  Future<List<Topic>> getTopics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'topic_entry',
      orderBy: 'topic_order ASC',
    );
    return List.generate(maps.length, (i) => Topic.fromMap(maps[i]));
  }

  Future<int> updateTopic(Topic topic) async {
    final db = await database;
    return await db.update(
      'topic_entry',
      topic.toMap(),
      where: 'id = ?',
      whereArgs: [topic.id],
    );
  }

  Future<int> deleteTopic(int id) async {
    final db = await database;
    return await db.delete(
      'topic_entry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Diary operations
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entry_v2', entry.toMap());
  }

  Future<List<DiaryEntry>> getDiaryEntries({int? topicId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entry_v2',
      where: topicId != null ? 'diary_ref_topic_id = ?' : null,
      whereArgs: topicId != null ? [topicId] : null,
      orderBy: 'diary_time DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<DiaryEntry?> getDiaryEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entry_v2',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entry_v2',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    // Delete associated diary items first
    await db.delete(
      'diary_item_entry_v2',
      where: 'item_ref_diary_id = ?',
      whereArgs: [id],
    );
    // Delete diary entry
    return await db.delete(
      'diary_entry_v2',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getDiaryCountByTopicId(int topicId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entry_v2 WHERE diary_ref_topic_id = ?',
      [topicId],
    );
    return result.first['count'] as int;
  }

  // Diary item operations
  Future<int> insertDiaryItem(DiaryItem item) async {
    final db = await database;
    return await db.insert('diary_item_entry_v2', item.toMap());
  }

  Future<List<DiaryItem>> getDiaryItems(int diaryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_item_entry_v2',
      where: 'item_ref_diary_id = ?',
      whereArgs: [diaryId],
      orderBy: 'diary_item_position ASC',
    );
    return List.generate(maps.length, (i) => DiaryItem.fromMap(maps[i]));
  }

  Future<int> updateDiaryItem(DiaryItem item) async {
    final db = await database;
    return await db.update(
      'diary_item_entry_v2',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteDiaryItem(int id) async {
    final db = await database;
    return await db.delete(
      'diary_item_entry_v2',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Memo operations
  Future<int> insertMemo(Memo memo) async {
    final db = await database;
    return await db.insert('memo_entry', memo.toMap());
  }

  Future<List<Memo>> getMemos({int? topicId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memo_entry',
      where: topicId != null ? 'memo_ref_topic_id = ?' : null,
      whereArgs: topicId != null ? [topicId] : null,
      orderBy: 'memo_order ASC',
    );
    return List.generate(maps.length, (i) => Memo.fromMap(maps[i]));
  }

  Future<int> updateMemo(Memo memo) async {
    final db = await database;
    return await db.update(
      'memo_entry',
      memo.toMap(),
      where: 'id = ?',
      whereArgs: [memo.id],
    );
  }

  Future<int> deleteMemo(int id) async {
    final db = await database;
    return await db.delete(
      'memo_entry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getMemoCountByTopicId(int topicId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM memo_entry WHERE memo_ref_topic_id = ?',
      [topicId],
    );
    return result.first['count'] as int;
  }

  // Contact operations
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts_entry', contact.toMap());
  }

  Future<List<Contact>> getContacts({int? topicId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts_entry',
      where: topicId != null ? 'contacts_ref_topic_id = ?' : null,
      whereArgs: topicId != null ? [topicId] : null,
      orderBy: 'contacts_name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts_entry',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts_entry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getContactCountByTopicId(int topicId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM contacts_entry WHERE contacts_ref_topic_id = ?',
      [topicId],
    );
    return result.first['count'] as int;
  }

  // Search operations
  Future<List<DiaryEntry>> searchDiaryEntries(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entry_v2',
      where: 'diary_title LIKE ? OR diary_location LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'diary_time DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<List<Memo>> searchMemos(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'memo_entry',
      where: 'memo_content LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'memo_order ASC',
    );
    return List.generate(maps.length, (i) => Memo.fromMap(maps[i]));
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts_entry',
      where: 'contacts_name LIKE ? OR contacts_phone_number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'contacts_name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}