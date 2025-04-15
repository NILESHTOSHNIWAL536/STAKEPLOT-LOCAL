// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class UserStatsScreen extends StatelessWidget {
//   UserStatsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final tracker = ScreenTimeTracker();
//     // print('UserStatsScreen using tracker instance: ${tracker.hashCode}');

//     return Scaffold(
//       appBar: AppBar(title: const Text('User Stats')),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _getUserStats(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final dailyLoginCount = snapshot.data?['daily_login_count'] ?? 0;
//           final loginHistory = snapshot.data?['login_history'] ?? [];
//           final dailyAppOpenCount = tracker.getDailyAppOpenCount();
//           final appOpenHistory = tracker.getAppOpenHistory();
//           final appEventLog = tracker.getAppEventLog();

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Today\'s Login Count: $dailyLoginCount',
//                       style: const TextStyle(fontSize: 20)),
//                   const SizedBox(height: 20),
//                   Text('Today\'s App Open Count: $dailyAppOpenCount',
//                       style: const TextStyle(fontSize: 20)),
//                   const SizedBox(height: 20),
//                   ValueListenableBuilder<int>(
//                     valueListenable: tracker.screenTimeNotifier,
//                     builder: (context, screenTime, child) {
//                       print('Screen time notifier updated: $screenTime');
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Total Screen Time: ${tracker.formatScreenTime(screenTime)}',
//                             style: const TextStyle(fontSize: 20),
//                           ),
//                           Text(
//                             'Raw Seconds: $screenTime',
//                             style: const TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   const Text('Login History:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(
//                     height: 150,
//                     child: ListView.builder(
//                       itemCount: loginHistory.length,
//                       itemBuilder: (context, index) {
//                         final entry = loginHistory[index];
//                         final parts = entry.split(':');
//                         final date = parts[0].replaceAll('login_count_', '');
//                         final count = parts[1];
//                         return ListTile(
//                           title: Text('Date: $date'),
//                           subtitle: Text('Logins: $count'),
//                         );
//                       },
//                     ),
//                   ),
//                  // const SizedBox(height: 20),
//                   const Text('App Open History:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(
//                     height: 100,
//                     child: ListView.builder(
//                       itemCount: appOpenHistory.length,
//                       itemBuilder: (context, index) {
//                         final entry = appOpenHistory[index];
//                         final parts = entry.split(':');
//                         final date = parts[0].replaceAll('app_open_count_', '');
//                         final count = parts[1];
//                         return ListTile(
//                           title: Text('Date: $date'),
//                           subtitle: Text('App Opens: $count'),
//                         );
//                       },
//                     ),
//                   ),
                 
//                   const Text('App Open/Close Events:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   SizedBox(
//                     height: 200,
//                     child: ListView.builder(
//                       itemCount: appEventLog.length,
//                       itemBuilder: (context, index) {
//                         final entry = appEventLog[index];
//                         return ListTile(
//                           title: Text(entry),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<Map<String, dynamic>> _getUserStats() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     final String todayKey = 'login_count_${DateTime.now().toIso8601String().substring(0, 10)}';
//     return {
//       'daily_login_count': pref.getInt(todayKey) ?? 0,
//       'login_history': pref.getStringList('login_history') ?? [],
//     };
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/screenTime.dart';
// import 'package:flutter_application_code_stakeplot/screen_time_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // For sizeRoom

class UserStatsScreen extends StatelessWidget {
  UserStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tracker = ScreenTimeTracker();
    print('UserStatsScreen using tracker instance: ${tracker.hashCode}');

    return Scaffold(
      appBar: AppBar(title: const Text('User Stats')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final dailyLoginCount = snapshot.data?['daily_login_count'] ?? 0;
          final loginHistory = snapshot.data?['login_history'] ?? [];
          final dailyAppOpenCount = tracker.getDailyAppOpenCount();
          final appOpenHistory = tracker.getAppOpenHistory();
          final appEventLog = tracker.getAppEventLog();
          final tabScreenTime = tracker.getTabScreenTime();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Login Count: $dailyLoginCount',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  Text('Today\'s App Open Count: $dailyAppOpenCount',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<int>(
                    valueListenable: tracker.screenTimeNotifier,
                    builder: (context, screenTime, child) {
                      print('Screen time notifier updated: $screenTime');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Screen Time: ${tracker.formatScreenTime(screenTime)}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'Raw Seconds: $screenTime',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Tab Screen Time:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: tabScreenTime.entries
                        .where((entry) => entry.key != 'Room' || sizeRoom)
                        .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: ${tracker.formatScreenTime(entry.value)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Login History:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: loginHistory.length,
                      itemBuilder: (context, index) {
                        final entry = loginHistory[index];
                        final parts = entry.split(':');
                        final date = parts[0].replaceAll('login_count_', '');
                        final count = parts[1];
                        return ListTile(
                          title: Text('Date: $date'),
                          subtitle: Text('Logins: $count'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('App Open History:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: appOpenHistory.length,
                      itemBuilder: (context, index) {
                        final entry = appOpenHistory[index];
                        final parts = entry.split(':');
                        final date = parts[0].replaceAll('app_open_count_', '');
                        final count = parts[1];
                        return ListTile(
                          title: Text('Date: $date'),
                          subtitle: Text('App Opens: $count'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('App Open/Close Events:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: appEventLog.length,
                      itemBuilder: (context, index) {
                        final entry = appEventLog[index];
                        return ListTile(
                          title: Text(entry),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserStats() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String todayKey = 'login_count_${DateTime.now().toIso8601String().substring(0, 10)}';
    return {
      'daily_login_count': pref.getInt(todayKey) ?? 0,
      'login_history': pref.getStringList('login_history') ?? [],
    };
  }
}