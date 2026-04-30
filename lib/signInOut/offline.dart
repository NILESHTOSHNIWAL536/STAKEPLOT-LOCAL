import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/bottomNavigations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../Constants/core/app_padding_sizes.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

/// Example page using the offline-aware scaffold
class Connections extends StatelessWidget {
  Connections({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigations(data: 1),

      // title: 'Dashboard',
      // onBack: () => Navigator.maybePop(context),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: List.generate(
          6,
          (i) => Card(
            elevation: 0,
            color: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: Text('Item ${i + 1}'),
              subtitle: const Text('Beautiful card with soft corners'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable scaffold that shows:
/// - App bar with back button
/// - Bottom status bar indicating internet status
/// - Full-screen beautiful "No Internet" content when offline
class OfflineAwareScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final VoidCallback? onBack;

  const OfflineAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
  });

  @override
  State<OfflineAwareScaffold> createState() => _OfflineAwareScaffoldState();
}

class _OfflineAwareScaffoldState extends State<OfflineAwareScaffold> {
  late final StreamSubscription _connSub;
  late final StreamSubscription _internetSub;

  bool _isInternetConnected = true; // final truth (ping-based)
  ConnectivityResult _connectivity = ConnectivityResult.mobile;

  bool get _isCompletelyOffline =>
      !_isInternetConnected || _connectivity == ConnectivityResult.none;

  @override
  void initState() {
    super.initState();

    // Initial checks
    _bootstrap();

    // Listen network type (wifi/mobile/none)
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      setState(() => _connectivity = result as ConnectivityResult);
      _recheckInternet(shortDelay: true);
    });

    // Listen true internet (DNS ping)
    _internetSub = InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 3),
      checkInterval: const Duration(seconds: 4),
    ).onStatusChange.listen((status) {
      setState(() =>
          _isInternetConnected = status == InternetConnectionStatus.connected);
    });
  }

  Future<void> _bootstrap() async {
    final initial = await Connectivity().checkConnectivity();
    final hasNet = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    setState(() {
      _connectivity = initial as ConnectivityResult;
      _isInternetConnected = hasNet;
    });
  }

  Future<void> _recheckInternet({bool shortDelay = false}) async {
    if (shortDelay) await Future.delayed(const Duration(milliseconds: 300));
    final ok = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    setState(() => _isInternetConnected = ok);
  }

  @override
  void dispose() {
    _connSub.cancel();
    _internetSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBottomBar =
        !_isInternetConnected || _connectivity == ConnectivityResult.none;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        centerTitle: true,
      ),

      // If fully offline, show a gorgeous offline page; otherwise show content.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child:
            _isCompletelyOffline ? const _OfflineBeautifulState() : widget.body,
      ),

      // No Stack used: we use bottomNavigationBar to host the status bar.
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: showBottomBar ? 58 : 0,
        decoration: BoxDecoration(
          color: showBottomBar
              ? const Color(0xFF202335)
              : AppColors.transparentColor,
          boxShadow: showBottomBar
              ? [
                  BoxShadow(
                    color: Color.fromARGB(31, 0, 0, 0),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  )
                ]
              : null,
        ),
        child: showBottomBar
            ? SafeArea(
                top: false,
                minimum: const EdgeInsets.symmetric(horizontal: AppSizes.p14),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: AppColors.whiteOpacity07),
                    SizedBox(width: AppSizes.w10),
                    Expanded(
                      child: Text(
                        'You’re offline. Some features may be unavailable.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.backgroundColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppSizes.w10),
                    TextButton(
                      onPressed: _recheckInternet,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.backgroundColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Full-screen beautiful offline state
class _OfflineBeautifulState extends StatelessWidget {
  const _OfflineBeautifulState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Smooth, modern gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2540),
            Color(0xFF2D3566),
            Color(0xFF3D3C8E),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decorative ring + icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Colors.white24,
                      Colors.white10,
                      Colors.white24,
                      Colors.white10,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(64, 0, 0, 0),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.wifi_off_rounded,
                      size: 64, color: AppColors.backgroundColor),
                ),
              ),
              SizedBox(height: AppSizes.h28),
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.backgroundColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
              ),
              SizedBox(height: AppSizes.h10),
              Text(
                'Please check your Wi-Fi or mobile data. You can retry or open network settings.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
              ),
              SizedBox(height: AppSizes.h24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FilledActionButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: () async {
                      // Trigger a manual recheck by rebuilding parent (if needed you can lift a callback)
                      // Here we just use a simple rebuild hint: Navigator pop/push or use a callback.
                      // For demo purposes, we show a snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Checking connection...')),
                      );
                    },
                  ),
                  SizedBox(width: AppSizes.w12),
                  _OutlineActionButton(
                    label: 'Settings',
                    icon: Icons.settings_rounded,
                    onPressed: () async {
                      // Open platform network settings (you can use app_settings package if you want)
                      // For now, show a hint.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Open device network settings')),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary filled button (rounded + modern)
class _FilledActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _FilledActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: AppSizes.p14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Secondary outline button
class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.backgroundColor),
      label: Text(label,
          style: FontManager()
              .getTextStyle(context, color: AppColors.backgroundColor)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white54, width: 1.2),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: AppSizes.p14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
