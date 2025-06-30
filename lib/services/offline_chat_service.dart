import 'dart:async';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_similarity/string_similarity.dart';

/// Lightweight offline medical Q&A service.
///
/// It performs a best-match lookup against bundled datasets and
/// enriches the answer with description, severity and precautions
/// if available.
class OfflineChatService {
  // Singleton
  static final OfflineChatService _instance = OfflineChatService._internal();
  factory OfflineChatService() => _instance;
  OfflineChatService._internal();

  bool _loaded = false;

  final List<Map<String, dynamic>> _qaPairs = [];
  final Map<String, String> _descriptions = {};
  final Map<String, List<String>> _precautions = {};
  final Map<String, int> _severities = {};

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    // Load Q&A JSON
    final qaJson = await rootBundle.loadString(
        'assets/chatbot/medical_chatbot_dataset_1000.json');
    final List<dynamic> qaData = json.decode(qaJson);
    for (final item in qaData) {
      if (item is Map<String, dynamic>) {
        _qaPairs.add({
          'symptom': item['symptom']?.toString() ?? '',
          'response': item['response']?.toString() ?? '',
        });
      }
    }

    // Helper to load csv from assets
    Future<List<List<dynamic>>> _loadCsv(String path) async {
      final raw = await rootBundle.loadString(path);
      return const CsvToListConverter(eol: '\n').convert(raw, shouldParseNumbers: false);
    }

    // symptom_Description.csv => Symptom, Description
    final descRows = await _loadCsv('assets/chatbot/symptom_Description.csv');
    for (final row in descRows.skip(1)) {
      if (row.length >= 2) {
        _descriptions[row[0].toString().trim().toLowerCase()] = row[1].toString();
      }
    }

    // Symptom-severity.csv => Symptom, Severity (int)
    final sevRows = await _loadCsv('assets/chatbot/Symptom-severity.csv');
    for (final row in sevRows.skip(1)) {
      if (row.length >= 2) {
        _severities[row[0].toString().trim().toLowerCase()] = int.tryParse(row[1].toString()) ?? 0;
      }
    }

    // symptom_precaution.csv => Symptom, Precaution1, Precaution2 ...
    final precRows = await _loadCsv('assets/chatbot/symptom_precaution.csv');
    for (final row in precRows.skip(1)) {
      if (row.isNotEmpty) {
        final key = row[0].toString().trim().toLowerCase();
        _precautions[key] = row.skip(1).where((e) => e.toString().trim().isNotEmpty).map((e) => e.toString()).toList();
      }
    }

    _loaded = true;
  }

  /// Returns an enriched answer for the [query].
  /// If confidence is low, recommends consulting a doctor.
  Future<String> ask(String query) async {
    await _ensureLoaded();
    final q = query.toLowerCase();

    double bestScore = 0.0;
    Map<String, dynamic>? bestMatch;

    for (final m in _qaPairs) {
      final symptom = m['symptom'] as String;
      final score = StringSimilarity.compareTwoStrings(q, symptom.toLowerCase());
      if (score > bestScore) {
        bestScore = score;
        bestMatch = m;
      }
    }

    // Heuristic threshold – adjust for sensitivity
    if (bestMatch == null || bestScore < 0.25) {
      return 'I\'m sorry, I\'m not sure about that. Please consider consulting a qualified medical professional.';
    }

    final symptomKey = (bestMatch['symptom'] as String).toLowerCase();
    final buffer = StringBuffer();
    buffer.writeln(bestMatch['response']);

    // Additional context
    if (_descriptions.containsKey(symptomKey)) {
      buffer.writeln('\nDescription: ${_descriptions[symptomKey]}');
    }
    if (_severities.containsKey(symptomKey)) {
      buffer.writeln('Estimated severity (1-5): ${_severities[symptomKey]}');
    }
    if (_precautions.containsKey(symptomKey) && _precautions[symptomKey]!.isNotEmpty) {
      buffer.writeln('\nRecommended precautions:\n• ${_precautions[symptomKey]!.join('\n• ')}');
    }

    return buffer.toString();
  }
}
