import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../lookup/models/caller_info.dart';
import '../../../utils/gdpr_utils.dart';

/// Service for managing call history
class HistoryService extends StateNotifier<List<CallerInfo>> {
  HistoryService() : super([]) {
    _initializeDatabase();
  }
  
  Database? _database;
  static const String _tableName = 'call_history';
  
  /// Initialize database
  Future<void> _initializeDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'danish_caller_insight.db');
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              hashed_number TEXT NOT NULL,
              name TEXT,
              company_name TEXT,
              address TEXT,
              spam_score INTEGER DEFAULT 0,
              is_spam INTEGER DEFAULT 0,
              is_business INTEGER DEFAULT 0,
              call_date TEXT NOT NULL,
              call_type TEXT NOT NULL
            )
          ''');
        },
      );
      
      await loadRecentCalls();
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
  
  /// Add call to history
  Future<void> addToHistory(CallerInfo callerInfo, String callType) async {
    if (_database == null) return;
    
    try {
      await _database!.insert(_tableName, {
        'hashed_number': callerInfo.hashedNumber,
        'name': callerInfo.name,
        'company_name': callerInfo.companyName,
        'address': callerInfo.address,
        'spam_score': callerInfo.spamScore,
        'is_spam': callerInfo.isSpam ? 1 : 0,
        'is_business': callerInfo.isBusiness ? 1 : 0,
        'call_date': DateTime.now().toIso8601String(),
        'call_type': callType,
      });
      
      await loadRecentCalls();
    } catch (e) {
      print('Error adding to history: $e');
    }
  }
  
  /// Load recent calls
  Future<void> loadRecentCalls() async {
    if (_database == null) return;
    
    try {
      final result = await _database!.query(
        _tableName,
        orderBy: 'call_date DESC',
        limit: 50,
      );
      
      final calls = result.map((row) {
        return CallerInfo.fromMap(row, 'hidden');
      }).toList();
      
      state = calls;
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    if (_database == null) return;
    
    try {
      await _database!.delete(_tableName);
      state = [];
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
  
  /// Delete old history (older than 30 days)
  Future<void> deleteOldHistory() async {
    if (_database == null) return;
    
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
      await _database!.delete(
        _tableName,
        where: 'call_date < ?',
        whereArgs: [thirtyDaysAgo.toIso8601String()],
      );
      
      await loadRecentCalls();
    } catch (e) {
      print('Error deleting old history: $e');
    }
  }
}

/// Provider for history service
final historyServiceProvider = StateNotifierProvider<HistoryService, List<CallerInfo>>(
  (ref) => HistoryService(),
);