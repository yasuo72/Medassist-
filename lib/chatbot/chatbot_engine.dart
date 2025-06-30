import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DiseaseRecord {
  final int idx;
  final String disease;
  final Set<String> symptomTokens;
  final String reason;
  final List<String> tests;
  final List<String> medications;

  DiseaseRecord({
    required this.idx,
    required this.disease,
    required this.symptomTokens,
    required this.reason,
    required this.tests,
    required this.medications,
  });
}

class ChatbotEngine {
  final String csvAsset;
  final String qaJsonAsset;
  final String descriptionCsvAsset;
  final String precautionCsvAsset;
  final String severityCsvAsset;

  ChatbotEngine({
    this.csvAsset = 'assets/chatbot/format_dataset.csv',
    this.qaJsonAsset = 'assets/chatbot/combined_dataset.json',
    this.descriptionCsvAsset = 'assets/chatbot/symptom_Description.csv',
    this.precautionCsvAsset = 'assets/chatbot/symptom_precaution.csv',
    this.severityCsvAsset = 'assets/chatbot/Symptom-severity.csv',
  });

  final List<DiseaseRecord> _records = [];
  final List<Map<String, dynamic>> _examples = [];
  final Map<String, String> _descMap = {};
  final Map<String, List<String>> _precMap = {};
  final Map<String, int> _sevMap = {};

  static const Map<String, String> _synonyms = {
    'stomach': 'abdominal',
    'abdomen': 'abdominal',
    'tummy': 'abdominal',
    'feverish': 'fever',
    'nauseous': 'nausea',
    'vomit': 'vomiting',
    'headaches': 'headache',
    'painful': 'pain',
  };

  static String _normalizeWord(String w) => _synonyms[w] ?? w;

  static Set<String> _tokenize(String text) {
    final regex = RegExp(r'[A-Za-z]+');
    return regex
        .allMatches(text.toLowerCase())
        .map((m) => _normalizeWord(m.group(0)!))
        .where((w) => w.length >= 2)
        .toSet();
  }

  static List<String> _parseList(String raw) {
    try {
      final list = jsonDecode(raw.replaceAll("'", '"')) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static List<String> _splitCsvLine(String line, int expected) {
    final List<String> parts = [];
    bool insideQuotes = false;
    final sb = StringBuffer();
    for (var rune in line.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '"') {
        insideQuotes = !insideQuotes;
      } else if (ch == ',' && !insideQuotes) {
        parts.add(sb.toString());
        sb.clear();
      } else {
        sb.write(ch);
      }
    }
    parts.add(sb.toString());
    while (parts.length < expected) {
      parts.add('');
    }
    return parts;
  }

  Future<void> loadData() async {
    try {
      final csvStr = await rootBundle.loadString(csvAsset);
      final lines = const LineSplitter().convert(csvStr);
      if (lines.isEmpty) return;

      final headers = lines.first.split(',');
      final int idxIdx = headers.indexOf('idx');
      final int diseaseIdx = headers.indexOf('disease');
      final int symptomIdx = headers.indexOf('Symptom');
      final int reasonIdx = headers.indexOf('reason');
      final int testIdx = headers.indexOf('TestsAndProcedures');
      final int medIdx = headers.indexOf('commonMedications');

      for (var i = 1; i < lines.length; i++) {
        final parts = _splitCsvLine(lines[i], headers.length);
        if (parts.length != headers.length) continue;

        final symptomsList = _parseList(parts[symptomIdx]);
        final testsList = _parseList(parts[testIdx]);
        final medsList = _parseList(parts[medIdx]);

        final rec = DiseaseRecord(
          idx: int.tryParse(parts[idxIdx]) ?? i - 1,
          disease: parts[diseaseIdx],
          symptomTokens: symptomsList.expand(_tokenize).toSet(),
          reason: parts[reasonIdx],
          tests: testsList,
          medications: medsList,
        );

        _records.add(rec);
      }

      // Load conversational JSON examples (legacy + extended)
      try {
        final jsonStr = await rootBundle.loadString(qaJsonAsset);
        final List<dynamic> arr = jsonDecode(jsonStr) as List<dynamic>;
        for (final e in arr) {
          if (e is Map<String, dynamic>) {
            final String? inp = (e['input'] ?? e['symptom']) as String?;
            final String? out = (e['output'] ?? e['response']) as String?;
            if (inp != null && out != null) {
              final tokens = _tokenize(inp);
              if (tokens.isNotEmpty) {
                _examples.add({'tokens': tokens, 'output': out});
              }
            }
          }
        }
      } catch (_) {
        // Ignore JSON not found or malformed
      }

      // Load extended Q&A dataset if available
      try {
        final extStr = await rootBundle.loadString('assets/chatbot/medical_chatbot_dataset_1000.json');
        final List<dynamic> arr = jsonDecode(extStr) as List<dynamic>;
        for (final e in arr) {
          if (e is Map<String, dynamic>) {
            final String? inp = (e['input'] ?? e['symptom']) as String?;
            final String? out = (e['output'] ?? e['response']) as String?;
            if (inp != null && out != null) {
              final tokens = _tokenize(inp);
              if (tokens.isNotEmpty) {
                _examples.add({'tokens': tokens, 'output': out});
              }
            }
          }
        }
      } catch (_) {
        // Ignore if asset missing or malformed
      }
    } catch (_) {}
  }

  String generateReply(String userInput) {
    if (_records.isEmpty) {
      return '🤖 Knowledge base not loaded.';
    }
    final userTokens = _tokenize(userInput);
    if (userTokens.isEmpty) {
      return '🤖 I could not understand any symptoms.';
    }
    final ranked = _rankDiseases(userTokens);
    if (ranked.isEmpty) {
      final example = _findBestExample(userTokens);
      if (example != null) return example;
      return '🤖 I am sorry, I could not match your symptoms to my knowledge base.';
    }

    var reply = _formatSuggestions(ranked);
    final example = _findBestExample(userTokens);
    if (example != null) {
      reply += '\n\n💬 Additional info:\n$example';
    }
    return reply;
  }

  List<MapEntry<DiseaseRecord, double>> _rankDiseases(Set<String> userTokens) {
    final List<MapEntry<DiseaseRecord, double>> scored = [];
    for (final rec in _records) {
      if (rec.symptomTokens.isEmpty) continue;
      final overlap = userTokens.intersection(rec.symptomTokens);
      if (overlap.isEmpty) continue;
      final precision = overlap.length / userTokens.length;
      final recall = overlap.length / rec.symptomTokens.length;
      if (precision < 0.3) continue;
      final f1 = 2 * precision * recall / (precision + recall);
      scored.add(MapEntry(rec, f1));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored;
  }

  String? _findBestExample(Set<String> userTokens) {
    double bestScore = 0;
    String? bestOutput;
    for (final ex in _examples) {
      final tokens = ex['tokens'] as Set<String>;
      final overlap = userTokens.intersection(tokens).length;
      if (overlap == 0) continue;
      final score = overlap / tokens.length;
      if (score > bestScore) {
        bestScore = score;
        bestOutput = ex['output'] as String;
      }
    }
    if (bestScore >= 0.1) return bestOutput;
    return null;
  }

  String _formatSuggestions(List<MapEntry<DiseaseRecord, double>> ranked) {
    final primary = ranked.first;
    final sb = StringBuffer();
    sb.writeln('👨‍⚕️ Possible condition: **${primary.key.disease}**');
    if (primary.value < 0.3) {
      sb.writeln('(Low confidence – please seek professional advice.)');
    }
    if (primary.key.reason.isNotEmpty) {
      sb.writeln('\n🧠 ${primary.key.reason}');
    }
    if (primary.key.tests.isNotEmpty) {
      sb.writeln('\n🧪 Recommended Tests:');
      for (final t in primary.key.tests.take(6)) {
        sb.writeln('- $t');
      }
    }
    if (primary.key.medications.isNotEmpty) {
      sb.writeln('\n💊 Common Medications:');
      for (final m in primary.key.medications.take(6)) {
        sb.writeln('- $m');
      }
    }
    final key = primary.key.disease.toLowerCase();
    if (_descMap.containsKey(key)) {
      sb.writeln('\n📝 Description:\n${_descMap[key]}');
    }
    if (_sevMap.containsKey(key)) {
      sb.writeln('\n🚦 Severity (1-5): ${_sevMap[key]}');
    }
    if (_precMap.containsKey(key) && _precMap[key]!.isNotEmpty) {
      sb.writeln('\n💡 Precautions:\n• ${_precMap[key]!.join('\n• ')}');
    }

    final alternatives = ranked
        .skip(1)
        .take(3)
        .where((e) => e.value >= primary.value * 0.7);
    if (alternatives.isNotEmpty) {
      sb.writeln('\n🔎 Other possible conditions:');
      for (final alt in alternatives) {
        sb.writeln(
          '- ${alt.key.disease} (~${(alt.value * 100).round()}% match)',
        );
      }
    }
    sb.writeln(
      '\n⚠️ Please consult a certified physician for confirmation and treatment.',
    );
    return sb.toString();
  }
}
