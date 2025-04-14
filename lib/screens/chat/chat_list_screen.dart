import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import 'chat_detail_screen.dart';
import '../../providers/user_provider.dart';

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    // Only load users based on the current user's role
    if (UserProvider.user?.roleType == 'DOCTOR') {
      // Doctors see patients
      return _chatService.getUsers()
          .then((users) => users.where((u) => u['roleType'] == 'PATIENT').toList());
    } else {
      // Patients see doctors
      return _chatService.getUsers()
          .then((users) => users.where((u) => u['roleType'] == 'DOCTOR').toList());
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: _refreshUsers,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final users = snapshot.data ?? [];
            
            if (users.isEmpty) {
              return Center(
                child: Text('No users found'),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user['firstname']?[0] ?? '?'),
                  ),
                  title: Text('${user['firstname']} ${user['lastname']}'),
                  subtitle: Text(user['email']),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userId: user['id'].toString(),
                          userName: '${user['firstname']} ${user['lastname']}',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
