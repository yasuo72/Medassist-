import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:medassist_plus/services/rag_chat_service.dart';

/// Online Chatbot screen powered by Hugging Face Space RAG backend.
class OnlineChatbotScreen extends StatefulWidget {
  static const String routeName = '/chatbot-online';

  const OnlineChatbotScreen({Key? key}) : super(key: key);

  @override
  State<OnlineChatbotScreen> createState() => _OnlineChatbotScreenState();
}

class _OnlineChatbotScreenState extends State<OnlineChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollCtl = ScrollController();
  final _listKey = GlobalKey<AnimatedListState>();
  final _service = RagChatService();

  final List<_ChatMsg> _messages = []; // maintained by AnimatedList
  bool _loading = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _listKey.currentState?.insertItem(_messages.length,
        duration: const Duration(milliseconds: 300));
    _messages.add(_ChatMsg(text, isUser: true));
    setState(() {
      _loading = true;
    });
    // fetch context snippets early
    final snippetsFuture = _service.passages(text);
    _controller.clear();
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollCtl.animateTo(
      _scrollCtl.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    try {
      // show passages once ready
      snippetsFuture.then((snips) {
        if (snips.isNotEmpty && mounted) {
          final idx = _messages.length;
          _messages.add(_ChatMsg('Context:\n• ${snips.join('\n• ')}', isUser: false));
          _listKey.currentState?.insertItem(idx,
              duration: const Duration(milliseconds: 300));
        }
      });

      final answer = await _service.ask(text);
      final idx = _messages.length;
      _messages.add(_ChatMsg(answer, isUser: false));
      _listKey.currentState?.insertItem(idx,
          duration: const Duration(milliseconds: 300));
    } catch (e) {
      final idx = _messages.length;
      _messages.add(_ChatMsg('Error: $e', isUser: false, isError: true));
      _listKey.currentState?.insertItem(idx,
          duration: const Duration(milliseconds: 300));
    } finally {
      setState(() => _loading = false);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _scrollCtl.animateTo(
          _scrollCtl.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('MedAssist AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const _AnimatedBackdrop(),
          Column(
        children: [
          Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollCtl,
                padding: const EdgeInsets.all(16),
                initialItemCount: _messages.length,
                itemBuilder: (ctx, i, anim) {
                  final m = _messages[i];
                final theme = Theme.of(context);
                  return SizeTransition(
                    sizeFactor: anim,
                    axisAlignment: 0.0,
                    child: Align(
                      alignment:
                          m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                            decoration: BoxDecoration(
                              color: m.isError
                                  ? Colors.redAccent.withOpacity(0.8)
                                  : m.isUser
                                      ? theme.colorScheme.primary.withOpacity(0.75)
                                      : (theme.brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.12)
                                          : Colors.black.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2), width: 1),
                            ),
                            child: SelectableText(
                              m.text,
                              style: TextStyle(
                                color: m.isError
                                    ? Colors.white
                                    : m.isUser
                                        ? Colors.white
                                        : (theme.brightness == Brightness.dark
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black87),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Ask a medical question…',
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.15),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _loading ? null : _send,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  final bool isError;
  const _ChatMsg(this.text, {required this.isUser, this.isError = false});
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
              colors: isDark
                ? [const Color(0xFF4b134f), const Color(0xFF1b2735)]
                : [const Color(0xFFFF9A8B), const Color(0xFFFF6A88)],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}
