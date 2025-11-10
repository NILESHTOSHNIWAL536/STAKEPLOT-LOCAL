package com.stakeplot.pfa

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.stakeplot.pfa/navigation"
    private val WIDGET_PREFS = "stakeplot_widget_prefs"
    private val WIDGET_FRIENDS_KEY = "friend_list_json"
    private val WIDGET_SELECTED_KEY = "selected_options"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "MethodChannel called: ${call.method}")
            try {
                when (call.method) {
                    "getInitialRoute" -> {
                        val intent = intent
                        val navigateToTab = intent?.getStringExtra("navigate_to_tab")
                        Log.d("MainActivity", "getInitialRoute: navigate_to_tab=$navigateToTab")
                        if (navigateToTab != null) {
                            result.success(mapOf("navigate_to_tab" to navigateToTab))
                        } else {
                            result.success(null)
                        }
                    }

                    // Returns JSON array string of selected items (or "[]")
                    "getLastWidgetSelection" -> {
                        val prefs = applicationContext.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
                        val selectedSet = prefs.getStringSet(WIDGET_SELECTED_KEY, emptySet()) ?: emptySet()
                        val arr = JSONArray()
                        selectedSet.forEach { arr.put(it) }
                        val jsonStr = arr.toString()
                        Log.d("MainActivity", "getLastWidgetSelection -> $jsonStr")
                        result.success(jsonStr)
                    }

                    // Accepts List<String> (from Dart) or a JSON string; stores friend list and updates widget
                    "setWidgetFriends" -> {
                        val args = call.arguments
                        val jsonString: String = when (args) {
                            is String -> args
                            is List<*> -> {
                                val arr = JSONArray()
                                args.forEach { arr.put(it) }
                                arr.toString()
                            }
                            else -> "[]"
                        }

                        val prefs = applicationContext.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
                        prefs.edit().putString(WIDGET_FRIENDS_KEY, jsonString).apply()
                        Log.d("MainActivity", "setWidgetFriends stored: $jsonString")

                        // Force widget update so the labels change immediately
                        try {
                            val appWidgetManager = android.appwidget.AppWidgetManager.getInstance(applicationContext)
                            val thisWidget = android.content.ComponentName(applicationContext.packageName, ClickableWidget::class.java.name)
                            val ids = appWidgetManager.getAppWidgetIds(thisWidget)
                            if (ids.isNotEmpty()) {
                                ClickableWidget().onUpdate(applicationContext, appWidgetManager, ids)
                                Log.d("MainActivity", "Forced widget update for ${ids.size} instance(s)")
                            } else {
                                Log.d("MainActivity", "No widget instances to update")
                            }
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error forcing widget update: ${e.message}", e)
                        }

                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "MethodChannel handler error: ${e.message}", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        Log.d("MainActivity", "onCreate: Intent extras=${intent?.extras?.toString()}")
        intent?.getStringExtra("navigate_to_tab")?.let {
            Log.d("MainActivity", "Received navigate_to_tab: $it")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("navigateToTab", mapOf("tab" to it))
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.d("MainActivity", "onNewIntent: Intent extras=${intent.extras?.toString()}")

        intent.getStringExtra("navigate_to_tab")?.let { tab ->
            Log.d("MainActivity", "New intent navigate_to_tab: $tab")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("navigateToTab", mapOf("tab" to tab))
            }
        }

        intent.getStringExtra("clicked_option")?.let { clicked ->
            Log.d("MainActivity", "New intent clicked_option: $clicked")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("widgetClicked", mapOf("option" to clicked))
            }
        }
    }
}
