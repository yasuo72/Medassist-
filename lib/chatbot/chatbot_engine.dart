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
  final Map<String, double> _tokenSeverity = {};
  final List<String> _rawPrompts = [];

  static const Map<String, String> _redFlagSymptomLabels = {
    'chest': 'chest pain or pressure',
    'breathlessness': 'trouble breathing or shortness of breath',
    'shortness': 'shortness of breath',
    'fainting': 'fainting or loss of consciousness',
    'weakness': 'sudden weakness (especially on one side)',
    'confusion': 'confusion or difficulty speaking',
    'bleeding': 'severe bleeding',
    'blood': 'vomiting or coughing blood',
    'headache': 'sudden severe headache',
    'fever': 'very high or persistent fever',
    'pregnancy': 'severe pain during pregnancy',
  };

  static const Map<String, String> _synonyms = {
    'stomach': 'abdominal',
    'abdomen': 'abdominal',
    'tummy': 'abdominal',
    'belly': 'abdominal',
    'stomachache': 'abdominal',
    'feverish': 'fever',
    'high': 'high',
    'temperature': 'fever',
    'nauseous': 'nausea',
    'vomit': 'vomiting',
    'vomiting': 'vomiting',
    'throwing': 'vomiting',
    'headaches': 'headache',
    'painful': 'pain',
    'tired': 'fatigue',
    'tiredness': 'fatigue',
    'exhausted': 'fatigue',
    'exhaustion': 'fatigue',
    'weak': 'weakness',
    'weaknesses': 'weakness',
    'dizzy': 'dizziness',
    'lightheaded': 'dizziness',
    'lightheadedness': 'dizziness',
    'breathing': 'breath',
    'breathless': 'breathlessness',
    'short': 'shortness',
    'poop': 'stool',
    'pooping': 'stool',
    'stools': 'stool',
    'pee': 'urine',
    'peeing': 'urination',
    'urinating': 'urination',
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
                _rawPrompts.add(inp.trim());
              }
            }
          }
        }
      } catch (_) {
        // Ignore JSON not found or malformed
      }

      // Load extended Q&A dataset if available
      try {
        final extStr = await rootBundle.loadString(
          'assets/chatbot/medical_chatbot_dataset_1000.json',
        );
        final List<dynamic> arr = jsonDecode(extStr) as List<dynamic>;
        for (final e in arr) {
          if (e is Map<String, dynamic>) {
            final String? inp = (e['input'] ?? e['symptom']) as String?;
            final String? out = (e['output'] ?? e['response']) as String?;
            if (inp != null && out != null) {
              final tokens = _tokenize(inp);
              if (tokens.isNotEmpty) {
                _examples.add({'tokens': tokens, 'output': out});
                _rawPrompts.add(inp.trim());
              }
            }
          }
        }
      } catch (_) {
        // Ignore if asset missing or malformed
      }

      // Load disease descriptions (if available)
      try {
        final descStr = await rootBundle.loadString(descriptionCsvAsset);
        final descLines = const LineSplitter().convert(descStr);
        for (var i = 1; i < descLines.length; i++) {
          final line = descLines[i].trim();
          if (line.isEmpty) continue;
          final parts = _splitCsvLine(line, 2);
          if (parts.length < 2) continue;
          final disease = parts[0].trim();
          final desc = parts[1].trim();
          if (disease.isEmpty || desc.isEmpty) continue;
          _descMap[disease.toLowerCase()] = desc;
        }
      } catch (_) {
        // Ignore if asset missing or malformed
      }

      // Load disease precautions (if available)
      try {
        final precStr = await rootBundle.loadString(precautionCsvAsset);
        final precLines = const LineSplitter().convert(precStr);
        for (var i = 1; i < precLines.length; i++) {
          final line = precLines[i].trim();
          if (line.isEmpty) continue;
          final parts = _splitCsvLine(line, 5);
          if (parts.isEmpty) continue;
          final disease = parts[0].trim();
          if (disease.isEmpty) continue;
          final key = disease.toLowerCase();
          final List<String> items = [];
          for (var j = 1; j < parts.length; j++) {
            final p = parts[j].trim();
            if (p.isNotEmpty) {
              items.add(p);
            }
          }
          if (items.isNotEmpty) {
            _precMap[key] = items;
          }
        }
      } catch (_) {
        // Ignore if asset missing or malformed
      }

      // Load symptom severity CSV and derive token-level weights (if available)
      try {
        final sevStr = await rootBundle.loadString(severityCsvAsset);
        final sevLines = const LineSplitter().convert(sevStr);
        for (var i = 1; i < sevLines.length; i++) {
          final line = sevLines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.length < 2) continue;
          final rawSymptom = parts[0].trim();
          final weight = int.tryParse(parts[1].trim());
          if (rawSymptom.isEmpty || weight == null) continue;
          final symptomTokens = rawSymptom.split('_');
          for (final raw in symptomTokens) {
            final token = _normalizeWord(raw.toLowerCase());
            if (token.length < 2) continue;
            final current = _tokenSeverity[token] ?? 0.0;
            if (weight > current) {
              _tokenSeverity[token] = weight.toDouble();
            }
          }
        }
      } catch (_) {
        // Ignore if asset missing or malformed
      }

      // Approximate overall disease severity (1-5) from its symptom tokens
      if (_tokenSeverity.isNotEmpty) {
        for (final rec in _records) {
          double sum = 0;
          for (final t in rec.symptomTokens) {
            final w = _tokenSeverity[t];
            if (w != null) sum += w;
          }
          if (sum <= 0) continue;
          final avg = sum / rec.symptomTokens.length;
          var sev = avg.round();
          if (sev < 1) sev = 1;
          if (sev > 5) sev = 5;
          _sevMap[rec.disease.toLowerCase()] = sev;
        }
      }
      // Debug: log how many records and prompts were loaded
      // (These prints are for development and can be removed or guarded later.)
      // ignore: avoid_print
      print(
        '[ChatbotEngine.loadData] records: \'${_records.length}\', prompts: \'${_rawPrompts.length}\'',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ChatbotEngine.loadData] ERROR: $e');
    }
  }

  List<String> getSuggestedPrompts([int maxCount = 200]) {
    final seen = <String>{};
    final result = <String>[];

    // Prompts from JSON Q&A datasets (combined_dataset + medical_chatbot_dataset_1000)
    final List<String> qaPrompts = _rawPrompts;

    // Prompts synthesized from the structured CSV disease records (symptom tokens)
    final List<String> csvPrompts = [];
    for (final rec in _records) {
      if (rec.symptomTokens.isEmpty) continue;
      // Build a short phrase from up to 4 key symptom tokens
      final topTokens = rec.symptomTokens.take(4).map(_prettifyToken).toList();
      if (topTokens.isEmpty) continue;
      final phrase = topTokens.join(', ');
      csvPrompts.add(phrase);
    }

    if (qaPrompts.isEmpty && csvPrompts.isEmpty) {
      // ignore: avoid_print
      print('[ChatbotEngine.getSuggestedPrompts] No prompts available');
      return const [];
    }

    // Interleave prompts from both sources so all datasets contribute
    final int maxLen =
        qaPrompts.length > csvPrompts.length
            ? qaPrompts.length
            : csvPrompts.length;

    for (var i = 0; i < maxLen && result.length < maxCount; i++) {
      if (i < qaPrompts.length) {
        final p = qaPrompts[i].trim();
        if (p.isNotEmpty && seen.add(p.toLowerCase())) {
          result.add(p);
          if (result.length >= maxCount) break;
        }
      }
      if (i < csvPrompts.length) {
        final p = csvPrompts[i].trim();
        if (p.isNotEmpty && seen.add(p.toLowerCase())) {
          result.add(p);
          if (result.length >= maxCount) break;
        }
      }
    }

    return result;
  }

  String generateReply(String userInput) {
    if (_records.isEmpty) {
      return '🤖 Knowledge base not loaded.';
    }
    final userTokens = _tokenize(userInput);
    if (userTokens.isEmpty) {
      return '🤖 I could not understand any symptoms.';
    }
    // Find best matching Q&A example (from both JSON datasets)
    final qaMatch = _findBestExampleWithScore(userTokens);
    final String? exampleText = qaMatch?.key;
    final double exampleScore = qaMatch?.value ?? 0;

    // Rank diseases using the structured CSV dataset
    final ranked = _rankDiseases(userTokens);
    final double topDiseaseScore = ranked.isNotEmpty ? ranked.first.value : 0;

    // If we have no disease match at all, fall back to the best Q&A example
    if (ranked.isEmpty) {
      if (exampleText != null && exampleScore >= 0.1) {
        final redFlag = _buildRedFlagWarning(userTokens);
        if (redFlag != null) {
          return '$redFlag\n\n$exampleText';
        }
        return exampleText;
      }
      return '🤖 I am sorry, I could not match your symptoms to my knowledge base.';
    }

    // If Q&A match is very strong but disease confidence is low, answer from Q&A first
    if (exampleText != null && exampleScore >= 0.6 && topDiseaseScore < 0.25) {
      var reply = '💬 Answer based on a similar case:\n$exampleText';
      // Still show structured disease-based summary as supporting info
      reply += '\n\n——\n\n${_formatSuggestions(ranked)}';

      final redFlag = _buildRedFlagWarning(userTokens);
      if (redFlag != null) {
        reply = '$redFlag\n\n$reply';
      }
      return reply;
    }

    // Default path: disease-based explanation first, Q&A as additional info
    var reply = _formatSuggestions(ranked);

    // Add clarifying question if scores are close
    final clarifying = _buildClarifyingQuestion(ranked);
    if (clarifying != null) {
      reply += '\n\n$clarifying';
    }

    // Add example-based extra info if available
    if (exampleText != null && exampleScore >= 0.1) {
      reply += '\n\n💬 Additional info:\n$exampleText';
    }

    // Prepend red-flag warning if dangerous symptoms detected
    final redFlag = _buildRedFlagWarning(userTokens);
    if (redFlag != null) {
      reply = '$redFlag\n\n$reply';
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

      // Boost score slightly if overlapping symptoms are marked as more severe
      double severityScore = 0;
      for (final t in overlap) {
        final w = _tokenSeverity[t];
        if (w != null) {
          severityScore += w;
        }
      }
      double boost = 1.0;
      if (severityScore > 0) {
        final norm = (severityScore / 10.0).clamp(0.0, 2.0);
        boost += 0.3 * norm;
      }

      final score = f1 * boost;
      scored.add(MapEntry(rec, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored;
  }

  MapEntry<String, double>? _findBestExampleWithScore(Set<String> userTokens) {
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
    if (bestOutput == null) return null;
    return MapEntry(bestOutput, bestScore);
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

  String? _buildRedFlagWarning(Set<String> userTokens) {
    final highlighted = <String>{};
    for (final t in userTokens) {
      final label = _redFlagSymptomLabels[t];
      if (label != null) {
        highlighted.add(label);
      }
    }
    if (highlighted.isEmpty) return null;
    final sample = highlighted.take(3).join(', ');
    return '🚨 Warning: Some of the symptoms you mentioned can be serious '
        '(for example: $sample). If you feel very unwell, your symptoms are '
        'suddenly worsening, or you have trouble breathing, chest pain, or '
        'confusion, please seek emergency medical care immediately.';
  }

  String? _buildClarifyingQuestion(
    List<MapEntry<DiseaseRecord, double>> ranked,
  ) {
    if (ranked.length < 2) return null;

    final primary = ranked[0];
    final alt = ranked[1];
    final pScore = primary.value;
    final aScore = alt.value;

    // Only ask if scores are close and not extremely low confidence
    if (pScore <= 0) return null;
    if (aScore < pScore * 0.8) return null;
    if (pScore < 0.25) return null;

    final primaryTokens = primary.key.symptomTokens;
    final altTokens = alt.key.symptomTokens;
    final primaryOnly = primaryTokens.difference(altTokens);
    final altOnly = altTokens.difference(primaryTokens);

    final focus = <String>[];
    focus.addAll(_pickTopTokens(primaryOnly, maxCount: 2));
    focus.addAll(_pickTopTokens(altOnly, maxCount: 2));

    if (focus.isEmpty) return null;
    final readable = focus.map(_prettifyToken).toSet().toList();
    if (readable.isEmpty) return null;

    return '🤔 Your symptoms could overlap with '
        '${primary.key.disease} or ${alt.key.disease}. '
        'To refine this, do you also notice any of: ${readable.join(', ')}?';
  }

  List<String> _pickTopTokens(Iterable<String> tokens, {int maxCount = 2}) {
    final list = tokens.where((t) => t.length >= 3).toList();
    if (list.isEmpty) return const [];
    list.sort((a, b) {
      final wa = _tokenSeverity[a] ?? 0;
      final wb = _tokenSeverity[b] ?? 0;
      return wb.compareTo(wa);
    });
    return list.take(maxCount).toList();
  }

  String _prettifyToken(String token) {
    if (token.isEmpty) return token;
    final base = token.replaceAll('_', ' ');
    return base[0].toUpperCase() + base.substring(1);
  }
}
