// // ─── main.dart ────────────────────────────────────────────────────────────────
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'utils/app_theme.dart';
// import 'screens/trip_dashboard_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ),
//   );
//   runApp(const TripSplitApp());
// }

// class TripSplitApp extends StatelessWidget {
//   const TripSplitApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Trip Split',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.theme,
//       home: const TripDashboardScreen(),
//     );
//   }
// }
