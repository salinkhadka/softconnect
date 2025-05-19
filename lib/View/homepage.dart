import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Homepage', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {},
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.black,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Friends'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.message),
                label: Text('Message'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          // Main content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        radius: 20,
                        child: Text('SC', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 3,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerLeft,
                          child: const Text('Search'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 10),
                      const Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Add Post Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text('S'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "What's on your mind?",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(Icons.image, color: Colors.grey),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                              child: const Text('Add Post',style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Posts
                  postCard(
                    avatarText: 'A',
                    name: 'Apple',
                    desc: 'A short trip',
                    imagePath: 'assets/images/logo.png',
                    likes: 10,
                    comments: 2,
                  ),
                  postCard(
                    avatarText: 'B',
                    name: 'Banana',
                    desc: 'I am feeling very very banananistic',
                    imagePath: null,
                    likes: 100,
                    comments: 23,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget postCard({
    required String avatarText,
    required String name,
    required String desc,
    String? imagePath,
    required int likes,
    required int comments,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarText == 'A' ? Colors.blue : Colors.yellow[700],
                child: Text(avatarText, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc),
          const SizedBox(height: 8),
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$likes likes  $comments comments'),
              const Spacer(),
              const Text('👍Like'),
              const SizedBox(width: 10),
              const Text('💬Comment'),
            ],
          ),
        ],
      ),
    );
  }
}
