import 'package:share_plus/share_plus.dart';

import '../repository/referral_repository.dart';

class ShareReferalLink {
  static Future<void> shareReferral([String? refCode]) async {
    String finalCode = refCode ?? '';

    if (finalCode.trim().isEmpty) {
      final response = await ReferralRepository.getShareReferralCode();
      finalCode = response['code']?.toString() ?? '';
    }

    if (finalCode.trim().isEmpty) {
      throw Exception('Referral code not available');
    }

    final link = generateReferralLinkLocal(finalCode);
    final message = """
Hey! I'm using Stakeplot.

Join using my referral:
$link
""";

    await Share.share(message);
  }

  static String generateReferralLink(String refCode) {
    return "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
        "?pid=User_invite"
        "&c=referral"
        "&deep_link_value=home"
        "&deep_link_sub1=$refCode";
  }

  static String generateReferralLinkFinal(String refCode) {
    final encodedRef = Uri.encodeComponent(refCode);

    return "https://stagingstakeplot.onelink.me/vf5p/8m41djpj"
        "?pid=User_invite"
        "&c=referral"
        "&deep_link_value=home"
        "&deep_link_sub1=$encodedRef"
        "&af_dp=stakeplot://invite?ref=$encodedRef&path=home"
        "&af_web_dp=https://staging.stakeplot.in/invite?ref=$encodedRef&path=home"
        "&af_android_url=https://play.google.com/store/apps/details?id=com.stakeplot.pfa"
        "&af_ios_url=https://apps.apple.com/app/idYOUR_APP_ID";
  }

  static String generateReferralLinkLocal(String refCode) {
    return "https://staging.stakeplot.in/invite?ref=$refCode&path=code";
  }
}
