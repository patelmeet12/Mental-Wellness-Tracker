import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyProfile = 'student_profile';
  static const String _keyJournals = 'journal_entries';
  static const String _keyChatHistory = 'chat_history';
  static const String _keyGeminiApiKey = 'gemini_api_key';
  static const String _keyStreaks = 'user_streaks';

  // Profile Storage
  Future<void> saveProfile(Map<String, dynamic> profileJson) async {
    await _prefs.setString(_keyProfile, jsonEncode(profileJson));
  }

  Map<String, dynamic>? getProfile() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Journal Storage
  Future<void> saveJournals(List<Map<String, dynamic>> journalsList) async {
    final stringList = journalsList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList(_keyJournals, stringList);
  }

  List<Map<String, dynamic>> getJournals() {
    final list = _prefs.getStringList(_keyJournals);
    if (list == null) return [];
    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((element) => element.isNotEmpty).toList();
  }

  // Chat History Storage
  Future<void> saveChatHistory(List<Map<String, dynamic>> messagesList) async {
    final stringList = messagesList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList(_keyChatHistory, stringList);
  }

  List<Map<String, dynamic>> getChatHistory() {
    final list = _prefs.getStringList(_keyChatHistory);
    if (list == null) return [];
    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((element) => element.isNotEmpty).toList();
  }

  Future<void> clearChatHistory() async {
    await _prefs.remove(_keyChatHistory);
  }

  // Streaks Storage
  Future<void> saveStreaks(Map<String, dynamic> streaksJson) async {
    await _prefs.setString(_keyStreaks, jsonEncode(streaksJson));
  }

  Map<String, dynamic>? getStreaks() {
    final raw = _prefs.getString(_keyStreaks);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // API Key Storage
  Future<void> saveGeminiApiKey(String key) async {
    await _prefs.setString(_keyGeminiApiKey, key);
  }

  String getGeminiApiKey() {
    // Check local preferences first, then fall back to dart-define compile-time env
    // To set at build time: flutter run --dart-define=GEMINI_API_KEY=your_key_here
    final saved = _prefs.getString(_keyGeminiApiKey) ?? '';
    if (saved.isNotEmpty) return saved;
    const defineKey = String.fromEnvironment('GEMINI_API_KEY');
    if (defineKey.isNotEmpty) return defineKey;
    // No key available — user must set one via the Settings dialog
    return '';
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
