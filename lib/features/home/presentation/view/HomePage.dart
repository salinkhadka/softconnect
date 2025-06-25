import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeTab(),
    Center(child: Text('Friends', style: TextStyle(fontSize: 24))),
    Center(child: Text('Messages', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Home tab with static posts
class _HomeTab extends StatelessWidget {
  final List<Map<String, String>> posts = [
    {
      'username': 'John Doe',
      'time': '2 hrs ago',
      'description': 'Enjoying a beautiful day at the park!',
      // 'postImage': 'assets/images/post1.jpg',
    },
    {
      'username': 'Jane Smith',
      'time': '5 hrs ago',
      'description': 'Just baked this delicious cake 🍰',
      // 'postImage': 'assets/images/post2.jpg',
    },
    {
      'username': 'Alex Johnson',
      'time': '1 day ago',
      'description': 'Started a new job today! Feeling excited 🎉',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['username'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(post['time'] ?? '',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz),
                  ],
                ),
                SizedBox(height: 10),

                // Description
                Text(post['description'] ?? ''),

                // Post Image (if available)
                // if (post['postImage'] != null) ...[
                //   SizedBox(height: 10),
                //   ClipRRect(
                //     borderRadius: BorderRadius.circular(8),
                //     child: Image.asset(post['postImage']!, fit: BoxFit.cover),
                //   ),
                // ],

                SizedBox(height: 10),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPostButton(Icons.thumb_up_alt_outlined, 'Like'),
                    _buildPostButton(Icons.comment_outlined, 'Comment'),
                    // _buildPostButton(Icons.share_outlined, 'Share'),
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
