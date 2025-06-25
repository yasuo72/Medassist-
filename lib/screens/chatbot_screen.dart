import 'package:flutter/material.dart';
import '../chatbot/chatbot_engine.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class ChatbotScreen extends StatefulWidget {
  static const String routeName = '/chatbot';

  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotEngine _engine = ChatbotEngine();
  final List<_ChatMsg> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loadingKB = true;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    await _engine.loadData();
    setState(() => _loadingKB = false);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _loadingKB) return;
    _controller.clear();
    setState(() {
      _messages.add(_ChatMsg(text, isUser: true));
    });
    final reply = _engine.generateReply(text);
    setState(() {
      _messages.add(_ChatMsg(reply, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('MedAssist AI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CupertinoSlidingSegmentedControl<String>(
              thumbColor: Colors.white.withOpacity(0.15),
              groupValue: 'Offline',
              backgroundColor: Colors.white.withOpacity(0.05),
              children: const {
                'Offline': Text('Offline', style: TextStyle(color: Colors.white)),
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
                Expanded(
                  child: _loadingKB
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            final msg = _messages[i];
                            final align =
                                msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
                            final bubbleColor = msg.isUser
                                ? theme.colorScheme.primary.withOpacity(0.25)
                                : Colors.white.withOpacity(0.12);
                            final borderRadius = BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: msg.isUser
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: msg.isUser
                                  ? Radius.zero
                                  : const Radius.circular(16),
                            );
                            return Align(
                              alignment: align,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.8),
                                decoration: BoxDecoration(
                                  color: bubbleColor,
                                  borderRadius: borderRadius,
                                  border: Border.all(color: Colors.white24, width: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                child: SelectableText(
                                  msg.text,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white30, width: 0.8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms…',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _send,
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
              stops: const [0.0, 0.5, 1.0],
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
