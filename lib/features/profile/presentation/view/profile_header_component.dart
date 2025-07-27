import 'package:flutter/material.dart';

class ProfileHeaderComponent extends StatelessWidget {
  final dynamic user;
  final String Function(String?) getFullImageUrl;

  const ProfileHeaderComponent({
    super.key,
    required this.user,
    required this.getFullImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = getFullImageUrl(user.profilePhoto);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF37225C).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32.0 : 20.0,
          vertical: isTablet ? 32.0 : 24.0,
        ),
        child: Column(
          children: [
            // Profile Image with decorative ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Decorative ring
                Container(
                  width: isTablet ? 140 : 120,
                  height: isTablet ? 140 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF37225C).withOpacity(0.3),
                        const Color(0xFFB8A6E6).withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Profile image
                Container(
                  width: isTablet ? 130 : 110,
                  height: isTablet ? 130 : 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF37225C).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: isTablet ? 63 : 53,
                    backgroundColor: const Color(0xFFB8A6E6).withOpacity(0.3),
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: isTablet ? 60 : 50,
                            color: const Color(0xFF37225C),
                          )
                        : null,
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 24 : 20),

            // Username with enhanced styling
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF37225C).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFB8A6E6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                user.username,
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF37225C),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isTablet ? 12 : 8),

            // Handle with subtle styling
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFB8A6E6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '@${user.username}',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: const Color(0xFF37225C).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Bio section with enhanced presentation
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              SizedBox(height: isTablet ? 20 : 16),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : 350,
                ),
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF37225C).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFB8A6E6).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Bio label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: isTablet ? 20 : 16,
                          color: const Color(0xFFB8A6E6),
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF37225C).withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: isTablet ? 8 : 6),
                        Icon(
                          Icons.format_quote,
                          size: isTablet ? 20 : 16,
                          color: const Color(0xFFB8A6E6),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    // Bio text
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        height: 1.5,
                        color: const Color(0xFF37225C).withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: isTablet ? 16 : 12),

            // Decorative divider
            Container(
              width: isTablet ? 100 : 80,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF37225C),
                    Color(0xFFB8A6E6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
