import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeTracker with WidgetsBindingObserver {
  static final ScreenTimeTracker _instance = ScreenTimeTracker._internal();
  factory ScreenTimeTracker() {
    return _instance;
  }
  ScreenTimeTracker._internal() {
    initialize();
  }

  DateTime? _sessionStartTime;
  int _totalScreenTimeSeconds = 0;
  Timer? _timer;
  final ValueNotifier<int> screenTimeNotifier = ValueNotifier<int>(0);
  bool _isLoggedIn = false;
  int _dailyAppOpenCount = 0;
  List<String> _appOpenHistory = [];
  List<String> _appEventLog = [];
  DateTime? _lastResumeTime;
  String? _userId;

  Map<String, int> _tabScreenTime = {
    'Home': 0,
    'Finance': 0,
    'Community': 0,
    'Profile': 0,
  };
  String? _currentTab;
  DateTime? _tabStartTime;

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    if (_userId != null) {
      await _loadUserData();
    }
  }

  Future<void> setUser(String userId,[flag=false]) async
   {
    if (_userId != userId || flag)
    {
      await clearUserData(); // Clear previous user data
      _userId = userId;
      await _loadUserData();
      print('Set user: $_userId');
    }
  }

  Future<void> clearUserData() async
  {
    _totalScreenTimeSeconds = 0;
    _dailyAppOpenCount = 0;
    _appOpenHistory = [];
    _appEventLog = [];
    _tabScreenTime = {'Home': 0, 'Finance': 0, 'Community': 0, 'Profile': 0};
    _currentTab = null;
    _tabStartTime = null;
    _isLoggedIn = false;
    screenTimeNotifier.value = 0;
    final pref = await SharedPreferences.getInstance();
    if (_userId != null) {
      await pref.remove('total_screen_time_$_userId');
      await pref.remove('app_open_count_${DateTime.now().toIso8601String().substring(0, 10)}_$_userId');
      await pref.remove('app_open_history_$_userId');
      await pref.remove('app_event_log_$_userId');
      await pref.remove('tab_time_home_$_userId');
      await pref.remove('tab_time_finance_$_userId');
      await pref.remove('tab_time_community_$_userId');
      await pref.remove('tab_time_profile_$_userId');
    }
   
    _userId = null;
  }

  Future<void> _loadUserData() async {
    if (_userId == null) return;
    await _loadTotalScreenTime();
    await _loadAppOpenData();
    await _loadAppEventLog();
    await _loadTabScreenTime();
  }

  Future<void> _loadTotalScreenTime() async {
    final pref = await SharedPreferences.getInstance();
    _totalScreenTimeSeconds = pref.getInt('total_screen_time_$_userId') ?? 0;
    screenTimeNotifier.value = _totalScreenTimeSeconds;
    // print('Loaded total screen time for $_userId: $_totalScreenTimeSeconds seconds');
  }

  Future<void> _saveTotalScreenTime() async {
    if (_userId == null) return;
    final pref = await SharedPreferences.getInstance();
    await pref.setInt('total_screen_time_$_userId', _totalScreenTimeSeconds);
    screenTimeNotifier.value = _totalScreenTimeSeconds;
    // print('Saved total screen time for $_userId: $_totalScreenTimeSeconds seconds');
  }

  Future<void> _loadAppOpenData() async {
    final pref = await SharedPreferences.getInstance();
    final todayKey = 'app_open_count_${DateTime.now().toIso8601String().substring(0, 10)}_$_userId';
    _dailyAppOpenCount = pref.getInt(todayKey) ?? 0;
    _appOpenHistory = pref.getStringList('app_open_history_$_userId') ?? [];
    // print('Loaded app open count for $_userId: $_dailyAppOpenCount, history: $_appOpenHistory');
  }

  Future<void> _saveAppOpenData() async {
    if (_userId == null) return;
    final pref = await SharedPreferences.getInstance();
    final todayKey = 'app_open_count_${DateTime.now().toIso8601String().substring(0, 10)}_$_userId';
    await pref.setInt(todayKey, _dailyAppOpenCount);
    if (_appOpenHistory.any((entry) => entry.startsWith(todayKey))) {
      _appOpenHistory.removeWhere((entry) => entry.startsWith(todayKey));
    }
    _appOpenHistory.add('$todayKey:$_dailyAppOpenCount');
    await pref.setStringList('app_open_history_$_userId', _appOpenHistory);
    // print('Saved app open count for $_userId: $_dailyAppOpenCount, history: $_appOpenHistory');
  }

  Future<void> _loadAppEventLog() async {
    final pref = await SharedPreferences.getInstance();
    _appEventLog = pref.getStringList('app_event_log_$_userId') ?? [];
    // print('Loaded app event log for $_userId: $_appEventLog');
  }

  Future<void> _saveAppEventLog() async {
    if (_userId == null) return;
    final pref = await SharedPreferences.getInstance();
    await pref.setStringList('app_event_log_$_userId', _appEventLog);
    // print('Saved app event log for $_userId: $_appEventLog');
  }

  Future<void> _loadTabScreenTime() async {
    final pref = await SharedPreferences.getInstance();
    _tabScreenTime['Home'] = pref.getInt('tab_time_home_$_userId') ?? 0;
    _tabScreenTime['Finance'] = pref.getInt('tab_time_finance_$_userId') ?? 0;
    _tabScreenTime['Community'] = pref.getInt('tab_time_community_$_userId') ?? 0;
    _tabScreenTime['Profile'] = pref.getInt('tab_time_profile_$_userId') ?? 0;
    // print('Loaded tab screen time for $_userId: $_tabScreenTime');
  }

  Future<void> _saveTabScreenTime() async {
    if (_userId == null) return;
    final pref = await SharedPreferences.getInstance();
    await pref.setInt('tab_time_home_$_userId', _tabScreenTime['Home']!);
    await pref.setInt('tab_time_finance_$_userId', _tabScreenTime['Finance']!);
    await pref.setInt('tab_time_community_$_userId', _tabScreenTime['Community']!);
    await pref.setInt('tab_time_profile_$_userId', _tabScreenTime['Profile']!);
    // print('Saved tab screen time for $_userId: $_tabScreenTime');
  }

  void startSession() {
    if (!_isLoggedIn && _userId != null) {
      _isLoggedIn = true;
      _sessionStartTime = DateTime.now();
      _startTimer();
      // print('Session started at: $_sessionStartTime for $_userId, instance: ${this.hashCode}');
    }
  }

  void endSession() {
    if (_isLoggedIn && _sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      _totalScreenTimeSeconds += duration;
      _updateCurrentTabTime();
      // print('Session ended for $_userId. Duration: $duration seconds. Total: $_totalScreenTimeSeconds seconds, instance: ${this.hashCode}');
      _sessionStartTime = null;
      _currentTab = null;
      _tabStartTime = null;
      _isLoggedIn = false;
      _stopTimer();
      _saveTotalScreenTime();
      _saveTabScreenTime();
    }
  }

  void switchTab(String tab) {
    if (!_isLoggedIn || _userId == null) return;
    _updateCurrentTabTime();
    if (_tabScreenTime.containsKey(tab)) {
      _currentTab = tab;
      _tabStartTime = DateTime.now();
      // print('Switched to tab: $tab at $_tabStartTime for $_userId, instance: ${this.hashCode}');
    } else {
      // print('Invalid tab: $tab for $_userId, instance: ${this.hashCode}');
    }
  }

  void _updateCurrentTabTime() {
    if (_isLoggedIn && _currentTab != null && _tabStartTime != null && _userId != null) {
      final duration = DateTime.now().difference(_tabStartTime!).inSeconds;
      if (duration > 0) {
        _tabScreenTime[_currentTab!] = (_tabScreenTime[_currentTab!] ?? 0) + duration;
        // print('Updated tab time for $_userId: $_currentTab += $duration seconds, total: ${_tabScreenTime[_currentTab!]}, instance: ${this.hashCode}');
      }
      _tabStartTime = DateTime.now(); // Reset to prevent overlap
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isLoggedIn && _sessionStartTime != null) {
        final currentDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;
        final total = _totalScreenTimeSeconds + currentDuration;
        screenTimeNotifier.value = total;
        // print('Timer tick for $_userId: isLoggedIn=$_isLoggedIn, sessionStart=$_sessionStartTime, currentDuration=$currentDuration, total=$total, instance=${this.hashCode}');
      } else {
        // print('Timer stopped for $_userId: isLoggedIn=$_isLoggedIn, sessionStart=$_sessionStartTime, instance=${this.hashCode}');
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    // print('Timer stopped for $_userId, instance: ${this.hashCode}');
  }

  void incrementAppOpenCount() {
    if (_userId == null) return;
    final now = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);
    final todayKey = 'app_open_count_${today}_$_userId';

    if (_appOpenHistory.isEmpty || !_appOpenHistory.any((entry) => entry.startsWith(todayKey))) {
      _dailyAppOpenCount = 0;
    }

    _dailyAppOpenCount++;
    _appEventLog.add('Opened: ${now.toIso8601String()}');
    _saveAppOpenData();
    _saveAppEventLog();
    // print('App opened for $_userId. Count: $_dailyAppOpenCount, event: Opened at ${now.toIso8601String()}, instance: ${this.hashCode}');
  }

  void logAppClose() {
    if (_userId == null) return;
    final now = DateTime.now();
    _appEventLog.add('Closed: ${now.toIso8601String()}');
    _saveAppEventLog();
    // print('App closed at: ${now.toIso8601String()} for $_userId, instance: ${this.hashCode}');
  }

  int getDailyAppOpenCount() {
    if (_userId == null) return 0;
    return _dailyAppOpenCount;
  }

  List<String> getAppOpenHistory() {
    return _appOpenHistory;
  }

  List<String> getAppEventLog() {
    return _appEventLog;
  }

  Map<String, int> getTabScreenTime() {
    _updateCurrentTabTime();
    return Map.from(_tabScreenTime);
  }

  int getTotalScreenTime() {
    final currentDuration = _isLoggedIn && _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;
    return _totalScreenTimeSeconds + currentDuration;
  }

  String formatScreenTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print('AppLifecycleState: $state, isLoggedIn=$_isLoggedIn, userId=$_userId, instance: ${this.hashCode}');
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastResumeTime == null || now.difference(_lastResumeTime!).inSeconds > 2) {
        incrementAppOpenCount();
        _lastResumeTime = now;
      }
      if (_isLoggedIn && _sessionStartTime == null && _userId != null) {
        _sessionStartTime = DateTime.now();
        _startTimer();
        // print('Session resumed at: $_sessionStartTime for $_userId, instance: ${this.hashCode}');
      }
    } else if (state == AppLifecycleState.paused) {
      logAppClose();
      _updateCurrentTabTime();
      if (_isLoggedIn && _sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
        _totalScreenTimeSeconds += duration;
        _sessionStartTime = null;
        _tabStartTime = null;
        _stopTimer();
        _saveTotalScreenTime();
        _saveTabScreenTime();
        // print('Session paused for $_userId. Duration: $duration seconds. Total: $_totalScreenTimeSeconds seconds, instance: ${this.hashCode}');
      }
    }
  }

  void dispose() {
    _stopTimer();
    endSession();
    WidgetsBinding.instance.removeObserver(this);
    screenTimeNotifier.dispose();
    // print('ScreenTimeTracker disposed for $_userId, instance: ${this.hashCode}');
  }
}