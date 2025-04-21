package com.stakeplot.adnan.dev

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.stakeplot.adnan.dev/navigation"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "MethodChannel called: ${call.method}")
            if (call.method == "getInitialRoute") {
                val intent = intent
                val navigateToTab = intent?.getStringExtra("navigate_to_tab")
                Log.d("MainActivity", "getInitialRoute: navigate_to_tab=$navigateToTab")
                if (navigateToTab != null) {
                    result.success(mapOf("navigate_to_tab" to navigateToTab))
                } else {
                    result.success(null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        Log.d("MainActivity", "onCreate: Intent extras=${intent?.extras?.toString()}")
        intent?.getStringExtra("navigate_to_tab")?.let {
            Log.d("MainActivity", "Received navigate_to_tab: $it")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.d("MainActivity", "onNewIntent: Intent extras=${intent.extras?.toString()}")
        intent.getStringExtra("navigate_to_tab")?.let {
            Log.d("MainActivity", "New intent navigate_to_tab: $it")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("navigateToFinance", null)
            }
        }
    }
}