import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yapchat/models/message.dart';
import 'package:yapchat/models/profile.dart';
import 'package:yapchat/themeAndConstants/constants.dart';
import 'package:yapchat/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};
  final Map<String, String> _usernameCache = {};

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    final myUserId = supabase.auth.currentUser!.id;
    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .order('message_created_at')
        .map((maps) {
          return maps.map((map) {
            final message = Message.fromMap(map: map, myUserId: myUserId);
            _loadProfileCache(message.profileId);
            return message;
          }).toList();
        });
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] == null) {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('profile_id', profileId)
          .single();
      final profile = Profile.fromMap(data);
      setState(() {
        _profileCache[profileId] = profile;
        _usernameCache[profileId] = profile.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final themeMode = ref.watch(themeNotifierProvider);
      final themeNotifier = ref.read(themeNotifierProvider.notifier);
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          actions: [
            Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) => themeNotifier.toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refresh,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            )
          ],
        ),
        body: StreamBuilder<List<Message>>(
          stream: _messagesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text('Estas en la sala de chat, ¡Expresate!'),
                    ),
                  ),
                  _MessageBar(),
                ],
              );
            }

            final messages = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final displayUsername =
                          _usernameCache[message.profileId] ?? 'Cargando...';
                      return _ChatBubble(
                          message: message, username: displayUsername);
                    },
                  ),
                ),
                const _MessageBar(),
              ],
            );
          },
        ),
      );
    });
  }

  Future refresh() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ChatPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar({Key? key}) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey[300],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: _submitMessage,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    try {
      await supabase.from('messages').insert({
        'message_profile_id': myUserId,
        'message_content': text,
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
    required this.username,
  }) : super(key: key);

  final Message message;
  final String username;

  @override
  Widget build(BuildContext context) {
    const IconData person = IconData(0xe491, fontFamily: 'MaterialIcons');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMine)
            const CircleAvatar(
              child: Icon(person),
            ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: message.isMine
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.isMine ? "Yo" : username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: message.isMine ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMine ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(format(message.createdAt, locale: 'es_short'),
                      style: TextStyle(
                        color: message.isMine ? Colors.white : Colors.black,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
