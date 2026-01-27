import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<_Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      _Message(
          text: 'Hi Doc, I have a headache.',
          isMe: true,
          time: DateTime.now().subtract(const Duration(minutes: 5))),
      _Message(
          text:
              'Take 2 tabs of Paracetamol 500 mg now and repeat after 6 h if needed.',
          isMe: false,
          time: DateTime.now().subtract(const Duration(minutes: 3))),
    ]);
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(
          text: _controller.text.trim(), isMe: true, time: DateTime.now()));
      _controller.clear();
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_Message(
              text:
                  'Prescription: Paracetamol 500 mg\nTake 2 tabs now, then 2 tabs q6h PRN.',
              isMe: false,
              time: DateTime.now()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Chat with Doctor'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_pharmacy),
            onPressed: () => _showPrescription(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _messageBubble(_messages[i], theme),
            ),
          ),
          _inputBar(theme),
        ],
      ),
    );
  }

  Widget _messageBubble(_Message msg, ThemeData theme) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isMe
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  color: isMe
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(msg.time),
                style: TextStyle(
                  fontSize: 10,
                  color: (isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface)
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar(ThemeData theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message or prescription...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      );

  void _showPrescription(BuildContext context) {
    Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Prescription'),
        content: const Text(
          'Paracetamol 500 mg\nTake 2 tablets now, then 2 tablets every 6 hours as needed for headache.\n\nDoctor: Online Medical Lab',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;
  final DateTime time;

  _Message({required this.text, required this.isMe, required this.time});
}
