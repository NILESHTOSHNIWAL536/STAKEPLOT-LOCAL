import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

class CommunityUserProfileScreen extends StatefulWidget {
  const CommunityUserProfileScreen({Key? key}) : super(key: key);

  @override
  State<CommunityUserProfileScreen> createState() => _CommunityUserProfileScreenState();
}

class _CommunityUserProfileScreenState extends State<CommunityUserProfileScreen> {
  bool _messageRepliesEnabled = true;
  int _selectedNavIndex = 3; // Profile tab selected

  @override
  void initState() {
    super.initState();
    // Set status bar styl
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: SafeArea(child: BottomNavigations(data: 2)),
      backgroundColor: const Color(0xFFB8B5D1), // Light purple background
      body: SafeArea(
        child: Column(
          children: [
           
            _buildHeader(),
            _buildProfileSection(),
            _buildMenuItems(),
            const Spacer(),
           
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/profile_avatar.png', // Replace with your avatar asset
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback avatar if image not found
                    return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFB366),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A68),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildMenuItem('View Profile', hasArrow: true),
            const SizedBox(height: 12),
            _buildMenuItem('Connection', hasArrow: true),
            const SizedBox(height: 12),
            _buildMenuItem('Saved', hasArrow: true),
            const SizedBox(height: 12),
            _buildMenuItem('Update Interest', hasArrow: true),
            const SizedBox(height: 12),
            _buildMenuItem('Message And Replies', hasToggle: true),
            const SizedBox(height: 12),
            _buildMenuItem('Hide Chat'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {bool hasArrow = false, bool hasToggle = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          if (hasArrow)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            )
          else if (hasToggle)
            Switch(
              value: _messageRepliesEnabled,
              onChanged: (value) {
                setState(() {
                  _messageRepliesEnabled = value;
                });
              },
              activeColor: const Color(0xFF4A4A68),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, 1),
          _buildNavItem(Icons.chat_bubble_outline, 2),
          _buildProfileNavItem(),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB8B5D1).withOpacity(0.3) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF4A4A68) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = 3;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFB8B5D1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'MM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
