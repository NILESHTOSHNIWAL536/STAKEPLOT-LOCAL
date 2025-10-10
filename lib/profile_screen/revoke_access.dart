import 'package:flutter/material.dart';
import '../Constants/font_manager.dart';
import '../backed_connections/apis_connect.dart';
import '../backed_connections/backServices.dart/email-services.dart';

class RevokeAccessScreen extends StatelessWidget {

  const RevokeAccessScreen({super.key});

  void _confirmRevoke(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Revoke Google Access",
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Are you sure you want to revoke Google access?\n\n"
          "This will disconnect your account, invalidate your refresh token, "
          "and remove email/Gmail permissions. You may need to sign in again "
          "to continue using Google services with this app.",
          style: FontManager().getTextStyle(context, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: FontManager().getTextStyle(context, lWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Revoke",
              style: FontManager().getTextStyle(context, lWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) 
    {
      // 🔥 Call your revoke API here
      await deleteEmailAccess(context);
      Navigator.of(context).pop(); // close screen after revoke
    }
  }

  @override
Widget build(BuildContext context) {
  final fm = FontManager();
  final theme = Theme.of(context);

  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.redAccent,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        "Google Account Access",
        style: fm.getTextStyle(context, lWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      ),
    ),
    body: Container(
      alignment: Alignment.topCenter,
      color: theme.colorScheme.surface.withOpacity(0.025),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 46, color: Colors.red[400]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Connected Account",
                            style: fm.getTextStyle(context, lWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userController.email.value,
                            style: fm.getTextStyle(context, lWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: Colors.red[100]),
                          const SizedBox(height: 12),
                          Text(
                            "This app currently has access to:",
                            style: fm.getTextStyle(context, lWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          _accessRow(theme, fm, "Your Google account email",context),
                          _accessRow(theme, fm, "Your basic profile info",context),
                          _accessRow(theme, fm, "Gmail (readonly access)",context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              "Revoking access will disconnect your Google account. "
              "You will no longer be able to use Google login or view Gmail data "
              "until you sign in again.",
              style: fm.getTextStyle(context, fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 38),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  "Revoke Access",
                  style: fm.getTextStyle(context, lWeight: FontWeight.w600, color: Colors.white),
                ),
                onPressed: () => _confirmRevoke(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _accessRow(ThemeData theme, FontManager fm, String text,BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 17, color: theme.colorScheme.secondary),
        const SizedBox(width: 7),
        Expanded(child: Text(text, style: fm.getTextStyle(context, fontSize: 13))),
      ],
    ),
  );
}

}
