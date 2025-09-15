import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;

/// Authenticated HTTP client for Gmail API
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

/// Gmail service: login + fetch messages
class GmailService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/gmail.readonly',
    ],
  );

  Future<gmail.GmailApi?> _getGmailApi() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    if (auth.accessToken == null) return null;

    final client = GoogleAuthClient({'Authorization': 'Bearer ${auth.accessToken}'});
    return gmail.GmailApi(client);
  }

  /// Fetch all emails from last 30 days
  Future<List<gmail.Message>> fetchLast30DaysMessages() async {
    final api = await _getGmailApi();
    if (api == null) return [];

    List<gmail.Message> allMessages = [];
    String? pageToken;

    // Compute 30 days ago in YYYY/MM/DD format
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final afterUnix = (thirtyDaysAgo.millisecondsSinceEpoch ~/ 1000);

    // Gmail API query: fetch messages after 30 days ago
    final query = 'after:$afterUnix'; // Gmail accepts Unix timestamp for after:

    do {
      final res = await api.users.messages.list(
        'me',
        q: query,
        pageToken: pageToken,
      );

      if (res.messages != null) allMessages.addAll(res.messages!);
      pageToken = res.nextPageToken;
    } while (pageToken != null);

    return allMessages;
  }

  /// Fetch full message (headers + snippet)
  Future<gmail.Message?> getMessage(String id) async {
    final api = await _getGmailApi();
    if (api == null) return null;

    return await api.users.messages.get('me', id, format: 'full');
  }
}

/// Main widget
class GmailLast30DaysDemo extends StatefulWidget {
  const GmailLast30DaysDemo({super.key});

  @override
  State<GmailLast30DaysDemo> createState() => _GmailLast30DaysDemoState();
}

class _GmailLast30DaysDemoState extends State<GmailLast30DaysDemo> {
  final GmailService gmailService = GmailService();
  List<gmail.Message> messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => loading = true);

    final msgs = await gmailService.fetchLast30DaysMessages();
    setState(() {
      messages = msgs;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gmail: Last 30 Days')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
              ? const Center(child: Text('No emails found in last 30 days'))
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    return ListTile(
                      title: Text(msg.id ?? 'No ID'),
                      subtitle: Text(msg.snippet ?? ''),
                      onTap: () async {
                        final fullMsg = await gmailService.getMessage(msg.id!);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Full Message Snippet'),
                            content: Text(fullMsg?.snippet ?? 'No snippet'),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: _loadMessages,
      ),
    );
  }
}
