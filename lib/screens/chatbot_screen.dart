import 'package:flutter/material.dart';
import '../../chatbot/chatbot_engine.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends StatefulWidget {
  static const String routeName = '/chatbot';

  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static final List<_ChatMsg> _persistentMessages = [];
  static final List<String> _queryHistory = [];

  static const String _prefsMessagesKey = 'offline_chat_messages_v1';
  static const String _prefsHistoryKey = 'offline_chat_history_v1';

  final ChatbotEngine _engine = ChatbotEngine();
  final List<_ChatMsg> _messages = _persistentMessages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loadingKB = true;
  List<String> _suggestedPrompts = [];
  String _promptFilter = '';

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
    _initEngine();
    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _initEngine() async {
    await _engine.loadData();
    final prompts = _engine.getSuggestedPrompts(250);
    setState(() {
      _loadingKB = false;
      _suggestedPrompts = prompts;
    });
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final msgStr = prefs.getString(_prefsMessagesKey);
      final histStr = prefs.getString(_prefsHistoryKey);

      if (msgStr != null) {
        final List<dynamic> arr = jsonDecode(msgStr) as List<dynamic>;
        _persistentMessages.clear();
        for (final e in arr) {
          if (e is Map<String, dynamic>) {
            final text = e['t'] as String? ?? e['text'] as String?;
            final isUser = e['u'] as bool? ?? e['isUser'] as bool? ?? true;
            if (text != null && text.isNotEmpty) {
              _persistentMessages.add(_ChatMsg(text, isUser: isUser));
            }
          }
        }
      }

      if (histStr != null) {
        final List<dynamic> arr = jsonDecode(histStr) as List<dynamic>;
        _queryHistory
          ..clear()
          ..addAll(arr.whereType<String>());
      }

      if (mounted) {
        setState(() {});
        if (_messages.isNotEmpty) {
          _scrollToBottom();
        }
      }
    } catch (_) {
      // Ignore corrupt prefs
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _loadingKB) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMsg(text, isUser: true));
      _promptFilter = '';
    });
    _queryHistory.add(text);
    final reply = _engine.generateReply(text);
    setState(() {
      _messages.add(_ChatMsg(reply, isUser: false));
    });
    _persistState();
    _scrollToBottom();
  }

  void _sendPrompt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _loadingKB) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMsg(trimmed, isUser: true));
      _promptFilter = '';
    });
    _queryHistory.add(trimmed);
    final reply = _engine.generateReply(trimmed);
    setState(() {
      _messages.add(_ChatMsg(reply, isUser: false));
    });
    _persistState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final msgPayload =
          _persistentMessages
              .map((m) => <String, dynamic>{'t': m.text, 'u': m.isUser})
              .toList();
      final histPayload = _queryHistory.toList();
      await prefs.setString(_prefsMessagesKey, jsonEncode(msgPayload));
      await prefs.setString(_prefsHistoryKey, jsonEncode(histPayload));
    } catch (_) {
      // Ignore persistence errors in UI
    }
  }

  void _showHistory() {
    if (_queryHistory.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('History'),
            content: const Text('No previous queries yet.'),
          );
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Search history',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Expanded(
                  child: ListView.separated(
                    itemCount: _queryHistory.length,
                    separatorBuilder:
                        (_, __) =>
                            const Divider(height: 1, color: Colors.white12),
                    itemBuilder: (ctx, index) {
                      final query =
                          _queryHistory[_queryHistory.length - 1 - index];
                      return ListTile(
                        title: Text(
                          query,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _sendPrompt(query);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MedAssist AI',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Offline symptom assistant',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Search history',
            onPressed: _showHistory,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CupertinoSlidingSegmentedControl<String>(
              thumbColor: Colors.white.withOpacity(0.15),
              groupValue: 'Offline',
              backgroundColor: Colors.white.withOpacity(0.05),
              children: const {
                'Offline': Text(
                  'Offline',
                  style: TextStyle(color: Colors.white),
                ),
                'Online': Text('Online', style: TextStyle(color: Colors.white)),
              },
              onValueChanged: (val) {
                if (val == 'Online') {
                  Navigator.pushReplacementNamed(context, '/chatbot-online');
                }
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const _AnimatedBackdrop(),
          SafeArea(
            child: Column(
              children: [
                if (!_loadingKB && _suggestedPrompts.isNotEmpty)
                  _buildPromptList(theme),
                Expanded(
                  child:
                      _loadingKB
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, i) {
                              final msg = _messages[i];
                              final isDark =
                                  theme.brightness == Brightness.dark;
                              final align =
                                  msg.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft;
                              // User messages: bright blue bubble; Bot: light (white) in light mode, near-black in dark mode
                              final bubbleColor =
                                  msg.isUser
                                      ? (isDark
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF1D4ED8))
                                      : (isDark
                                          ? const Color(0xFF020617)
                                          : Colors.white);
                              final borderRadius = BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft:
                                    msg.isUser
                                        ? const Radius.circular(16)
                                        : Radius.zero,
                                bottomRight:
                                    msg.isUser
                                        ? Radius.zero
                                        : const Radius.circular(16),
                              );
                              return Align(
                                alignment: align,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: borderRadius,
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                      width: 0.6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          isDark ? 0.5 : 0.15,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: SelectableText(
                                    msg.text,
                                    style: TextStyle(
                                      color:
                                          msg.isUser
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                _buildInputBar(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptList(ThemeData theme) {
    final filter = _promptFilter.trim().toLowerCase();
    final List<String> prompts =
        filter.isEmpty
            ? _suggestedPrompts
            : _suggestedPrompts
                .where((p) => p.toLowerCase().contains(filter))
                .toList();
    if (prompts.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.colorScheme.surfaceVariant.withOpacity(0.95)
                : theme.colorScheme.surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Quick symptom prompts',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  final text = prompts[index];
                  final baseStyle = TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  );
                  final f = filter;
                  Widget label;
                  if (f.isEmpty) {
                    label = Text(text, style: baseStyle);
                  } else {
                    final lower = text.toLowerCase();
                    final idx = lower.indexOf(f);
                    if (idx < 0) {
                      label = Text(text, style: baseStyle);
                    } else {
                      final end = idx + f.length;
                      label = RichText(
                        text: TextSpan(
                          style: baseStyle,
                          children: [
                            if (idx > 0) TextSpan(text: text.substring(0, idx)),
                            TextSpan(
                              text: text.substring(idx, end),
                              style: baseStyle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            if (end < text.length)
                              TextSpan(text: text.substring(end)),
                          ],
                        ),
                      );
                    }
                  }
                  return InkWell(
                    onTap: () => _sendPrompt(text),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: label),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.colorScheme.surfaceVariant.withOpacity(0.95)
                : theme.colorScheme.surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Describe your symptoms or tap a suggestion…',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black45,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _promptFilter = value;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop({Key? key}) : super(key: key);

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Light: soft white -> blue, Dark: black -> bright blue
              colors:
                  isDark
                      ? [const Color(0xFF000000), const Color(0xFF2563EB)]
                      : [const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg(this.text, {required this.isUser});
}
