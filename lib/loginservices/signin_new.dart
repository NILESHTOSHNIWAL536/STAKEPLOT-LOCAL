import 'package:flutter/material.dart';

class ResponsiveLoginScreen extends StatelessWidget {
  const ResponsiveLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.07,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E7FAA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder, color: Colors.white, size: 34),
                ),
              ),
              const Text(
                'Sign in to continue to your account',
                style: TextStyle(
                  color: Color(0xFFB8B6A9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),
              // Floating icons & folder SVGs (Replace with your own assets or icons)
              Center(
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                     ..._floatingIcons(),  
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 110,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB1B0D1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.folder_open, color: Colors.white, size: 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 46),
              // Email input
              const Text(
                'enter your mail',
                style: TextStyle(
                  color: Color(0xFFB8B6A9),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  filled: false,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD8D4C7)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD8D4C7)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB1B0D1)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintText: '',
                ),
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 22),
              // Send OTP button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E7FAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text('or', style: TextStyle(color: Color(0xFFB8B6A9))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google button
                  _socialButton(
                    icon: Icons.g_mobiledata,
                    color: Colors.white,
                    borderColor: const Color(0xFFD8D4C7),
                  ),
                  const SizedBox(width: 20),
                  // Apple button
                  _socialButton(
                    icon: Icons.apple,
                    color: Colors.black,
                    borderColor: Colors.transparent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _floatingIcons() {
    // Custom positions based on your image
    final icons = [
      Icons.lock,
      Icons.analytics,
      Icons.file_copy,
      Icons.cloud,
      Icons.wallet_giftcard,
      Icons.account_balance_wallet,
      Icons.verified_user,
      Icons.pie_chart,
    ];
    final positions = [
      const Offset(-70, -40),
      const Offset(-35, -60),
      const Offset(0, -70),
      const Offset(35, -60),
      const Offset(70, -40),
      const Offset(-50, 0),
      const Offset(50, 0),
      const Offset(0, -20),
    ];

    return List<Widget>.generate(
      icons.length,
      (i) => Positioned(
        left: 90 + positions[i].dx,
        top: 60 + positions[i].dy,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icons[i], size: 22, color: Color(0xFF7E7FAA)),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required Color color, required Color borderColor}) {
    return Container(
      width: 80,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Icon(icon, size: 30, color: color == Colors.white ? Colors.black : Colors.white),
    );
  }
}
