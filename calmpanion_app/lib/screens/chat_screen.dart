import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'dart:ui';
import 'meditation_screen.dart';
import 'package:get_storage/get_storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final _storage = GetStorage();
  static const String _chatKey = 'chat_messages';
  bool _isLoading = false;
  bool _showQuickPrompts = true;
  bool _isDarkMode = false;
  late AnimationController _animationController;
  final List<String> _quickPrompts = [
    "I'm feeling anxious today",
    "How can I improve my sleep?",
    "Help me with stress management",
    "I need motivation"
  ];

  // Theme colors
  Color get _primaryColor =>
      _isDarkMode ? Color.fromARGB(255, 63, 222, 183) : const Color(0xFF15B38B);
  Color get _secondaryColor => _isDarkMode
      ? Color.fromARGB(255, 63, 222, 183).withOpacity(0.8)
      : const Color(0xFF15B38B).withOpacity(0.8);
  Color get _backgroundColor =>
      _isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF0F4FF);
  Color get _surfaceColor => _isDarkMode
      ? const Color(0xFF1A1A1A).withOpacity(0.8)
      : Colors.white.withOpacity(0.9);
  Color get _textColor => _isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
  Color get _secondaryTextColor =>
      _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  Color get _inputBackgroundColor => _isDarkMode
      ? const Color(0xFF2A2A2A).withOpacity(0.8)
      : const Color(0xFFF0F4FF);
  Color get _accentColor =>
      _isDarkMode ? Color.fromARGB(255, 63, 222, 183) : const Color(0xFF15B38B);
  Color get _neonGlow => _isDarkMode
      ? Color.fromARGB(255, 63, 222, 183).withOpacity(0.3)
      : const Color(0xFF15B38B).withOpacity(0.2);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadMessages();
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text:
              "Hello! I'm Calmpanion, your mental health companion. How are you feeling today?",
          isUser: false,
          timestamp: DateTime.now(),
          hasBeenRead: true,
        ),
      );
      _saveMessages();
    }

    Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
  }

  void _loadMessages() {
    final List<dynamic>? savedMessages = _storage.read(_chatKey);
    if (savedMessages != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          savedMessages.map((msg) => ChatMessage(
                text: msg['text'],
                isUser: msg['isUser'],
                timestamp: DateTime.parse(msg['timestamp']),
                hasBeenRead: msg['hasBeenRead'] ?? true,
              )),
        );
      });
    }
  }

  void _saveMessages() {
    final List<Map<String, dynamic>> messagesToSave = _messages
        .map((msg) => {
              'text': msg.text,
              'isUser': msg.isUser,
              'timestamp': msg.timestamp.toIso8601String(),
              'hasBeenRead': msg.hasBeenRead,
            })
        .toList();
    _storage.write(_chatKey, messagesToSave);
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    setState(() {
      _showQuickPrompts = false;
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
          hasBeenRead: true,
        ),
      );
      _isLoading = true;
    });

    _saveMessages();
    _scrollToBottom();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final response = await _chatService.sendMessage(text);
      setState(() {
        _messages.add(
          ChatMessage(
            text: response['response'] ??
                'I apologize, but I could not process your message.',
            isUser: false,
            timestamp: DateTime.now(),
            hasBeenRead: false,
          ),
        );
        _isLoading = false;
      });

      _saveMessages();

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.last = ChatMessage(
              text: _messages.last.text,
              isUser: false,
              timestamp: _messages.last.timestamp,
              hasBeenRead: true,
            );
            _saveMessages();
          });
        }
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
            hasBeenRead: true,
          ),
        );
        _isLoading = false;
      });
      _saveMessages();
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getFormattedTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                opacity: _isDarkMode ? 0.1 : 0.05,
                isDarkMode: _isDarkMode,
              ),
            ),
          ),
          // Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDarkMode
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2A2A2A),
                          const Color(0xFF1A1A1A),
                        ]
                      : [
                          const Color(0xFF98D8C8).withOpacity(0.1),
                          const Color(0xFFB4E4D9).withOpacity(0.1),
                          const Color(0xFFC5E1D5).withOpacity(0.1),
                        ],
                ),
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              AppBar(
                elevation: 0,
                backgroundColor: _surfaceColor,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: _surfaceColor,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: PulsePainter(
                              color: _primaryColor,
                              animationValue: _animationController.value,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.psychology_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calmpanion',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4BD37B),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4BD37B)
                                            .withOpacity(0.3 +
                                                0.2 *
                                                    _animationController.value),
                                        blurRadius:
                                            4 + 2 * _animationController.value,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Available Now',
                              style: TextStyle(
                                color: const Color(0xFF4BD37B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.self_improvement,
                      color: _textColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeditationScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: _textColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz, color: _textColor),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: _secondaryTextColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.delete_outline,
                                        color: _primaryColor),
                                  ),
                                  title: Text(
                                    'Clear Chat',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _messages.clear();
                                      _messages.add(
                                        ChatMessage(
                                          text:
                                              "Hello! I'm Calmpanion, your mental health companion. How are you feeling today?",
                                          isUser: false,
                                          timestamp: DateTime.now(),
                                          hasBeenRead: true,
                                        ),
                                      );
                                      _showQuickPrompts = true;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.info_outline,
                                        color: _primaryColor),
                                  ),
                                  title: Text(
                                    'About',
                                    style: TextStyle(
                                      color: _textColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5, sigmaY: 5),
                                        child: Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          elevation: 0,
                                          backgroundColor: _surfaceColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        _primaryColor,
                                                        _secondaryColor
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.psychology_alt,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'About Calmpanion',
                                                  style: TextStyle(
                                                    color: _textColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Calmpanion is your AI-powered mental health companion, designed to provide support, guidance, and coping strategies through meaningful conversation.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: _secondaryTextColor,
                                                    height: 1.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        _primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: Text(
                                                    'Close',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? const Color(0xFF3D3D3D)
                      : const Color(0xFFEEF1F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: _secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                        child: _TypingIndicator(
                          isDarkMode: _isDarkMode,
                          primaryColor: _primaryColor,
                          secondaryColor: _secondaryColor,
                        ),
                      );
                    }

                    final message = _messages[index];
                    final showTimestamp = index == 0 ||
                        message.timestamp
                                .difference(_messages[index - 1].timestamp)
                                .inMinutes >
                            5 ||
                        message.isUser != _messages[index - 1].isUser;

                    return Column(
                      crossAxisAlignment: message.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showTimestamp) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: 4,
                              left: message.isUser ? 0 : 48,
                              right: message.isUser ? 48 : 0,
                            ),
                            child: Text(
                              _getFormattedTime(message.timestamp),
                              style: TextStyle(
                                color: _secondaryTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                        MessageBubble(
                          message: message,
                          isDarkMode: _isDarkMode,
                          primaryColor: _primaryColor,
                          secondaryColor: _secondaryColor,
                          textColor: _textColor,
                        ),
                      ],
                    );
                  },
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _showQuickPrompts
                    ? Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickPrompts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    _handleSubmitted(_quickPrompts[index]),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _surfaceColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: _isDarkMode
                                            ? const Color(0xFF4D4D4D)
                                            : const Color(0xFFE1E5EB)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _quickPrompts[index],
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(height: 0),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _inputBackgroundColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Send a message...',
                              hintStyle: TextStyle(
                                color: _secondaryTextColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 16,
                            ),
                            maxLines: 3,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: _handleSubmitted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _handleSubmitted(_messageController.text),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primaryColor, _secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasBeenRead;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.hasBeenRead,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isDarkMode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.psychology_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isUser
                    ? null
                    : (isDarkMode ? const Color(0xFF3D3D3D) : Colors.white),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  topRight: const Radius.circular(20),
                  topLeft: const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (message.isUser ? primaryColor : Colors.black)
                        .withOpacity(message.isUser ? 0.2 : 0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : textColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: message.hasBeenRead
                  ? Icon(
                      Icons.done_all,
                      size: 16,
                      color: primaryColor,
                    )
                  : Icon(
                      Icons.done,
                      size: 16,
                      color: isDarkMode
                          ? const Color(0xFF666666)
                          : const Color(0xFF8F99A8),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryColor;

  const _TypingIndicator({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animations = List.generate(3, (index) {
      final delay = index * 0.2;
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.0),
          weight: 0.5,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            delay,
            delay + 0.6,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.primaryColor, widget.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.psychology_alt,
                color: Colors.white,
                size: 20,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF3D3D3D) : Colors.white,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomLeft: const Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        widget.isDarkMode
                            ? const Color(0xFF666666)
                            : const Color(0xFFE1E5EB),
                        widget.primaryColor,
                        _animations[index].value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}

class PulsePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  PulsePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 1.5;

    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - animationValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      center,
      maxRadius * animationValue + size.width / 2.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(PulsePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final double opacity;
  final bool isDarkMode;

  BackgroundPatternPainter({
    required this.opacity,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.03 * opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
