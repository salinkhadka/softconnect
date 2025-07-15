import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _username = 'Unknown';

  final List<Map<String, String>> posts = [
    {
      'username': 'John Doe',
      'time': '2 hrs ago',
      'description': 'Enjoying a beautiful day at the park!',
    },
    {
      'username': 'Jane Smith',
      'time': '5 hrs ago',
      'description': 'Just baked this delicious cake 🍰',
    },
    {
      'username': 'Alex Johnson',
      'time': '1 day ago',
      'description': 'Started a new job today! Feeling excited 🎉',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Text(
              'Welcome, $_username',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        final post = posts[index - 1];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        _getInitials(post['username'] ?? ''),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['username'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(post['time'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 10),
                Text(post['description'] ?? ''),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPostButton(Icons.thumb_up_alt_outlined, 'Like'),
                    _buildPostButton(Icons.comment_outlined, 'Comment'),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey[700], size: 20),
      label: Text(label, style: TextStyle(color: Colors.grey[700])),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    } else if (parts.isNotEmpty) {
      return parts[0][0];
    }
    return '';
  }
}
