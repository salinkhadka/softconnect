import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove default title and use a Row to combine logo + search bar
        toolbarHeight: 100, // Make AppBar taller to fit search bar
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
  radius: 35, // Half of the size (40)
  backgroundImage: AssetImage('assets/images/logo.png'),
  backgroundColor: Colors.transparent,
),
            ),
            // Expanded to fill remaining space with search bar
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Add Post Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add Post'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Example Posts
            _buildPostContainer(
              username: 'Apple',
              content: 'A short trip',
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJoVHanj0bCz4mtX4RSooCmjn23dZV4tRVOA&s',
              likes: 10,
              comments: 2,
            ),
            _buildPostContainer(
              username: 'Banana',
              content: 'I am feeling very very bananainstic',
              likes: 100,
              comments: 23,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContainer({
    required String username,
    required String content,
    String? imageUrl,
    required int likes,
    required int comments,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content),
          const SizedBox(height: 10),
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl),
            ),
          const SizedBox(height: 10),
          Text('$likes likes    $comments comments'),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up),
                label: const Text('Like'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.comment),
                label: const Text('Comment'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
