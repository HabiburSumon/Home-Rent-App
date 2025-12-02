import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final List<Map<String, dynamic>> demoChats = [
    {
      'id': 'c1',
      'name': 'Rahim (Owner)',
      'lastMessage': 'Hi! Are you available to visit tomorrow?',
      'time': '10:24 AM',
      'unread': 1,
      'avatar': null,
      'messages': [
        {'fromMe': false, 'text': 'Hi! Is this place still available?'},
        {'fromMe': true, 'text': 'Yes, it is available. When can you visit?'},
        {'fromMe': false, 'text': 'Tomorrow at 11 AM works for me.'}
      ]
    },
    {
      'id': 'c2',
      'name': 'Salma (Renter)',
      'lastMessage': 'I placed a bid for 12,000 BDT',
      'time': 'Yesterday',
      'unread': 0,
      'avatar': null,
      'messages': [
        {'fromMe': false, 'text': 'I placed a bid for 12,000 BDT'},
        {'fromMe': true, 'text': 'Thanks, I will review it.'}
      ]
    },
    {
      'id': 'c3',
      'name': 'Property Support',
      'lastMessage': 'Your listing has been approved ✅',
      'time': '2d',
      'unread': 0,
      'avatar': null,
      'messages': [
        {'fromMe': false, 'text': 'Your listing has been approved ✅'}
      ]
    },
  ];

  String search = '';

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = demoChats.where((c) {
      final q = search.toLowerCase();
      return c['name'].toLowerCase().contains(q) || c['lastMessage'].toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats or messages...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chat = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                          child: Text(
                            _initials(chat['name']),
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          chat['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(chat['time'], style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                            const SizedBox(height: 6),
                            if ((chat['unread'] ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${chat['unread']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                name: chat['name'],
                                messages: List<Map<String, dynamic>>.from(chat['messages']),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // new chat demo: show simple add dialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Start Demo Chat'),
              content: const Text('This will add a demo conversation to the list.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      demoChats.insert(0, {
                        'id': 'c${demoChats.length + 1}',
                        'name': 'New Demo User',
                        'lastMessage': 'Hey, I am interested.',
                        'time': 'Now',
                        'unread': 1,
                        'avatar': null,
                        'messages': [
                          {'fromMe': false, 'text': 'Hey, I am interested.'}
                        ]
                      });
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class ChatDetailPage extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> messages;

  const ChatDetailPage({super.key, required this.name, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool fromMe = msg['fromMe'] == true;
                return Align(
                  alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: fromMe ? Theme.of(context).primaryColor : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: fromMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {},
                    child: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}