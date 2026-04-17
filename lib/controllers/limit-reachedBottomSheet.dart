import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class LimitReachedBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 👈 important for gradient
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            gradient: LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF2A2A40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔘 Top Drag Handle
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔒 Icon with Circle Glow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.orangeAccent],
                  ),
                ),
                child: const Icon(Icons.lock, size: 40, color: Colors.white),
              ),

              const SizedBox(height: 16),

              /// 🧠 Title
              const Text(
                "Limit Reached 😬",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              /// 📄 Subtitle
              const Text(
                "You've reached your collection limit.\n"
                "Invite friends & unlock more collections 🚀",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),

              const SizedBox(height: 20),

              /// 🎁 Reward Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.card_giftcard, color: Colors.amber),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Invite 3 friends & get +2 collection limit 🎉",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 🚀 Invite Button (Gradient)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  shareReferral("AX9L023");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Invite Friends 🚀",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// ❌ Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Maybe Later",
                  style: TextStyle(color: Colors.white54),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static Future<void> shareReferral(String refCode) async {
    final link = generateReferralLinkLocal(refCode);

    final message = """
        Hey! I'm using Stakeplot 🚀

        Join using my referral:
        $link
        """;
    await Share.share(message);
  }

  static String generateReferralLink(String refCode) {
    return "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
        "?pid=User_invite"
        "&c=referral"
        "&deep_link_value=signup"
        "&deep_link_sub1=$refCode";
  }

  static String generateReferralLinkLocal(String refCode) {
    return "https://unexhilarating-vihaan-nosogeographical.ngrok-free.dev/invite?ref=AX9L023&path=home";
  }
}
